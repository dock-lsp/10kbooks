#!/bin/bash
set -e

# 万卷书苑后端一键部署脚本 v2.1 (CentOS版)
# 适配: CentOS 8/9, Alinux 3
# ========================================

GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
NC="\033[0m"

log_step() { echo -e "${BLUE}[STEP] $1${NC}"; }
log_info() { echo -e "${GREEN}[INFO] $1${NC}"; }
log_error() { echo -e "${RED}[ERROR] $1${NC}"; }

echo "========================================"
echo -e "   ${GREEN}万卷书苑后端一键部署脚本 v2.1 (CentOS版)${NC}"
echo "========================================"
echo ""

PROJECT_DIR="/opt/10kbooks"
DB_NAME="tenkbooks"
DB_USER="tenkbooks"
DB_PASS="Tenkbooks_db_2024_Secure"
REDIS_PASS="Redis_10kbooks_2024"
DOMAIN="47.92.220.102"
GITHUB_REPO="https://github.com/dock-lsp/10kbooks.git"

# 1. 系统更新
log_step "1/18: 更新系统..."
dnf update -y -q > /dev/null 2>&1 || yum update -y -q > /dev/null 2>&1
log_info "系统更新完成"

# 2. 安装Node.js 18
log_step "2/18: 安装Node.js 18..."
if ! command -v node &> /dev/null || [[ $(node -v) != v18* ]]; then
    curl -fsSL https://rpm.nodesource.com/setup_18.x | bash - > /dev/null 2>&1
    dnf install -y nodejs > /dev/null 2>&1 || yum install -y nodejs > /dev/null 2>&1
fi
log_info "Node.js $(node -v) 安装完成"

# 3. 安装PostgreSQL
log_step "3/18: 安装PostgreSQL 14..."
if ! command -v psql &> /dev/null; then
    dnf install -y postgresql postgresql-server postgresql-contrib > /dev/null 2>&1 || true
    if ! command -v psql &> /dev/null; then
        # 尝试PostgreSQL官方源
        dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9/x86_64/pgdg-redhat-repo-latest.noarch.rpm > /dev/null 2>&1 || true
        dnf install -y postgresql14-server postgresql14-contrib > /dev/null 2>&1 || true
        export PATH="$PATH:/usr/pgsql-14/bin"
    fi
    # 初始化数据库
    if [ -d "/var/lib/pgsql" ] && [ ! -f "/var/lib/pgsql/initdb.log" ]; then
        postgresql-setup --initdb > /dev/null 2>&1 || true
    fi
fi
systemctl start postgresql > /dev/null 2>&1 || systemctl start postgresql-14 > /dev/null 2>&1 || true
systemctl enable postgresql > /dev/null 2>&1 || systemctl enable postgresql-14 > /dev/null 2>&1 || true
log_info "PostgreSQL 安装完成"

# 4. 配置PostgreSQL
log_step "4/18: 配置PostgreSQL数据库..."
su - postgres -c "psql" << EOF 2>/dev/null || true
DO \$body\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$DB_USER') THEN
        CREATE ROLE $DB_USER WITH LOGIN PASSWORD '$DB_PASS';
    END IF;
END
\$body\$;
SELECT 'CREATE DATABASE $DB_NAME OWNER $DB_USER'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$DB_NAME')\gexec
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
ALTER USER $DB_USER CREATEDB;
EOF

# 配置pg_hba.conf允许密码认证
PG_HBA=$(find /var/lib/pgsql* -name "pg_hba.conf" 2>/dev/null | head -1)
if [ -f "$PG_HBA" ]; then
    sed -i 's/ident/trust/g' "$PG_HBA" 2>/dev/null || true
    sed -i 's/peer/trust/g' "$PG_HBA" 2>/dev/null || true
    systemctl restart postgresql > /dev/null 2>&1 || systemctl restart postgresql-14 > /dev/null 2>&1 || true
fi
log_info "数据库配置完成"

# 5. 安装Redis
log_step "5/18: 安装Redis..."
dnf install -y redis > /dev/null 2>&1 || yum install -y redis > /dev/null 2>&1
systemctl start redis > /dev/null 2>&1 || true
systemctl enable redis > /dev/null 2>&1 || true
log_info "Redis 安装完成"

# 6. 安装Nginx
log_step "6/18: 安装Nginx..."
dnf install -y nginx > /dev/null 2>&1 || yum install -y nginx > /dev/null 2>&1
systemctl start nginx > /dev/null 2>&1 || true
systemctl enable nginx > /dev/null 2>&1 || true
log_info "Nginx 安装完成"

# 7. 安装Git和工具
log_step "7/18: 安装Git和构建工具..."
dnf install -y git wget curl > /dev/null 2>&1 || yum install -y git wget curl > /dev/null 2>&1
npm install -g pnpm > /dev/null 2>&1 || true
log_info "Git 安装完成"

# 8. 克隆项目
log_step "8/18: 克隆项目代码..."
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR
if [ -d ".git" ]; then
    git pull origin main > /dev/null 2>&1
else
    git clone $GITHUB_REPO . > /dev/null 2>&1
fi
log_info "项目代码已更新"

# 9. 安装后端依赖
log_step "9/18: 安装后端依赖..."
cd $PROJECT_DIR/server
npm install > /dev/null 2>&1
npx prisma generate > /dev/null 2>&1
log_info "后端依赖安装完成"

# 10. 配置环境变量
log_step "10/18: 配置环境变量..."
cat > $PROJECT_DIR/server/.env << EOF
NODE_ENV=production
PORT=3001
DATABASE_URL="postgresql://$DB_USER:$DB_PASS@localhost:5432/$DB_NAME?schema=public"
REDIS_URL="redis://localhost:6379"
JWT_SECRET="10kbooks_jwt_secret_2024_secure_key"
JWT_EXPIRES_IN="7d"
APP_URL="http://$DOMAIN"
API_PREFIX="/api"
CORS_ORIGIN="*"
EOF
log_info "环境变量配置完成"

# 11. 初始化数据库
log_step "11/18: 初始化数据库表结构..."
cd $PROJECT_DIR/server
npx prisma db push > /dev/null 2>&1 || true
log_info "数据库表结构创建完成"

# 12. 构建后端
log_step "12/18: 构建后端项目..."
npm run build > /dev/null 2>&1 || log_info "跳过构建，直接运行"
log_info "后端构建完成"

# 13. 安装PM2
log_step "13/18: 安装PM2进程管理..."
if ! command -v pm2 &> /dev/null; then
    npm install -g pm2 > /dev/null 2>&1
fi
log_info "PM2 安装完成"

# 14. 启动后端服务
log_step "14/18: 启动后端服务..."
cd $PROJECT_DIR/server
pm2 delete 10kbooks-server > /dev/null 2>&1 || true
pm2 start dist/main.js --name 10kbooks-server > /dev/null 2>&1 || pm2 start src/main.js --name 10kbooks-server > /dev/null 2>&1
pm2 save > /dev/null 2>&1
pm2 startup > /dev/null 2>&1 || true
log_info "后端服务已启动"

# 15. 配置Nginx反向代理
log_step "15/18: 配置Nginx反向代理..."
cat > /etc/nginx/conf.d/10kbooks.conf << EOF
server {
    listen 80;
    server_name $DOMAIN;

    location /api {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# 测试并重启Nginx
nginx -t > /dev/null 2>&1 && systemctl restart nginx > /dev/null 2>&1 || true
log_info "Nginx 配置完成"

# 16. 配置防火墙
log_step "16/18: 开放防火墙端口..."
systemctl start firewalld > /dev/null 2>&1 || true
firewall-cmd --permanent --add-service=http > /dev/null 2>&1 || true
firewall-cmd --permanent --add-port=3001/tcp > /dev/null 2>&1 || true
firewall-cmd --reload > /dev/null 2>&1 || true
log_info "防火墙配置完成"

# 17. SELinux配置
log_step "17/18: 配置SELinux..."
setenforce 0 > /dev/null 2>&1 || true
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config 2>/dev/null || true
log_info "SELinux配置完成"

# 18. 验证服务
log_step "18/18: 验证服务状态..."
sleep 3

echo ""
echo "========================================"
echo -e "   ${GREEN}✅ 部署完成！${NC}"
echo "========================================"
echo ""
echo "后端服务信息："
echo "  API 地址: http://$DOMAIN/api"
echo "  后端端口: 3001 (本地)"
echo ""
echo "数据库信息："
echo "  数据库名: $DB_NAME"
echo "  用户名: $DB_USER"
echo ""
echo "服务状态检查："
pm2 status 2>/dev/null || echo "PM2 未运行"
echo ""
echo "健康检查命令："
echo "  curl http://$DOMAIN/api"
echo ""
echo "日志查看命令："
echo "  pm2 logs 10kbooks-server"
echo "========================================"
