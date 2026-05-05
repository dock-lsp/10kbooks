#!/bin/bash
#==========================================
# 万卷书苑后端一键部署脚本 v2.0
# 适用于阿里云ECS (Ubuntu 22.04)
# 服务器: 47.92.220.102
#==========================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then 
    log_error "请使用root用户运行此脚本"
    exit 1
fi

echo ""
echo "=========================================="
echo "     万卷书苑后端一键部署脚本 v2.0"
echo "=========================================="
echo ""

# 变量配置
APP_DIR="/var/www/10kbooks"
APP_USER="www-data"
APP_PORT=3001
DB_NAME="tenkbooks"
DB_USER="tenkbooks"
DB_PASS="Tenkbooks_db_2024_Secure"
REDIS_PASS="Redis_10kbooks_2024"
DOMAIN="47.92.220.102"
GITHUB_REPO="https://github.com/dock-lsp/10kbooks.git"

# 1. 系统更新
log_step "1/18: 更新系统..."
apt update -qq && apt upgrade -y -qq > /dev/null 2>&1
log_info "系统更新完成"

# 2. 安装Node.js 18
log_step "2/18: 安装Node.js 18..."
if ! command -v node &> /dev/null || [[ $(node -v) != v18* ]]; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - > /dev/null 2>&1
    apt-get install -y nodejs > /dev/null 2>&1
fi
log_info "Node.js $(node -v) 安装完成"

# 3. 安装PostgreSQL
log_step "3/18: 安装PostgreSQL 14..."
apt-get install -y postgresql postgresql-contrib > /dev/null 2>&1
systemctl start postgresql
systemctl enable postgresql
log_info "PostgreSQL 安装完成"

# 4. 配置PostgreSQL
log_step "4/18: 配置PostgreSQL数据库..."
sudo -u postgres psql << EOF 2>/dev/null || true
DO \$body\$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = '$DB_USER') THEN
      CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';
   END IF;
END
\$body\$;

CREATE DATABASE $DB_NAME OWNER $DB_USER;
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
ALTER USER $DB_USER WITH SUPERUSER;
EOF
log_info "数据库 $DB_NAME 和用户 $DB_USER 创建完成"

# 5. 安装Redis
log_step "5/18: 安装Redis..."
apt-get install -y redis-server > /dev/null 2>&1
sed -i "s/# requirepass.*/requirepass $REDIS_PASS/" /etc/redis/redis.conf
sed -i "s/protected-mode yes/protected-mode no/" /etc/redis/redis.conf
systemctl restart redis-server
systemctl enable redis-server
log_info "Redis 安装完成"

# 6. 安装Nginx
log_step "6/18: 安装Nginx..."
apt-get install -y nginx > /dev/null 2>&1
systemctl start nginx
systemctl enable nginx
log_info "Nginx 安装完成"

# 7. 安装PM2
log_step "7/18: 安装PM2..."
npm install -g pm2 > /dev/null 2>&1
pm2 install pm2-logrotate > /dev/null 2>&1
log_info "PM2 安装完成"

# 8. 创建应用目录
log_step "8/18: 创建应用目录..."
mkdir -p $APP_DIR
mkdir -p /var/log/10kbooks
id -u $APP_USER &>/dev/null || useradd -r -m -s /bin/false $APP_USER
log_info "目录创建完成"

# 9. 克隆代码
log_step "9/18: 从GitHub克隆代码..."
cd $APP_DIR
if [ ! -f "package.json" ]; then
    git clone --depth 1 $GITHUB_REPO . 2>/dev/null || {
        log_warn "Git克隆失败，尝试使用备份URL..."
        git clone --depth 1 https://github.com/dock-lsp/10kbooks.git . 2>/dev/null || true
    }
fi
cd $APP_DIR
[ -d "server" ] && cd server || cd .
APP_SERVER_DIR=$(pwd)
log_info "代码已克隆到 $APP_SERVER_DIR"

# 10. 配置环境变量
log_step "10/18: 配置环境变量..."
JWT_SECRET="Tenkbooks_JWT_$(head -c 32 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | head -c 32)"
cat > .env << EOF
NODE_ENV=production
PORT=$APP_PORT

# 数据库配置
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=$DB_USER
DATABASE_PASSWORD=$DB_PASS
DATABASE_NAME=$DB_NAME
DATABASE_URL=postgresql://$DB_USER:$DB_PASS@localhost:5432/$DB_NAME

# Redis配置
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=$REDIS_PASS
REDIS_URL=redis://:$REDIS_PASS@localhost:6379

# JWT配置
JWT_SECRET=$JWT_SECRET
JWT_EXPIRES_IN=7d

# CORS配置
CORS_ORIGINS=http://localhost:3000,http://$DOMAIN,http://$DOMAIN:3000

# 邮件配置（可选）
# MAIL_HOST=smtp.example.com
# MAIL_PORT=587
# MAIL_USER=noreply@10kbooks.com
# MAIL_PASSWORD=your_password
# MAIL_FROM=noreply@10kbooks.com
EOF
log_info "环境变量配置完成"

# 11. 安装依赖
log_step "11/18: 安装Node.js依赖..."
npm install --silent 2>&1 | tail -5
log_info "依赖安装完成"

# 12. 生成Prisma客户端
log_step "12/18: 生成Prisma客户端..."
npx prisma generate > /dev/null 2>&1
log_info "Prisma客户端生成完成"

# 13. 数据库初始化
log_step "13/18: 初始化数据库..."
npx prisma db push > /dev/null 2>&1 || log_warn "数据库初始化可能已存在"
log_info "数据库初始化完成"

# 14. 构建应用
log_step "14/18: 构建NestJS应用..."
npm run build 2>&1 | tail -10
log_info "应用构建完成"

# 15. 配置权限
log_step "15/18: 配置目录权限..."
chown -R $APP_USER:$APP_USER $APP_SERVER_DIR
chown -R $APP_USER:$APP_USER /var/log/10kbooks
log_info "权限配置完成"

# 16. 启动应用
log_step "16/18: 启动PM2服务..."
su - $APP_USER -s /bin/bash << EOF
cd $APP_SERVER_DIR
pm2 delete 10kbooks-server 2>/dev/null || true
pm2 start dist/main.js --name 10kbooks-server
pm2 save
EOF
sleep 3
pm2 status 2>/dev/null || true
log_info "PM2服务启动完成"

# 17. 配置PM2开机自启
log_step "17/18: 配置开机自启..."
env PATH=$PATH:/usr/bin pm2 startup systemd -u $APP_USER --hp $APP_DIR 2>/dev/null || true
log_info "开机自启配置完成"

# 18. 配置Nginx反向代理
log_step "18/18: 配置Nginx反向代理..."
cat > /etc/nginx/sites-available/10kbooks-api << 'EOF'
server {
    listen 80;
    server_name _;

    client_max_body_size 100M;
    client_body_timeout 300s;
    proxy_read_timeout 300s;

    # API代理
    location / {
        proxy_pass http://127.0.0.1:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # 静态文件（可选）
    location /uploads/ {
        alias /var/www/10kbooks/server/uploads/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# 启用站点
ln -sf /etc/nginx/sites-available/10kbooks-api /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default 2>/dev/null || true
nginx -t && systemctl reload nginx
log_info "Nginx配置完成"

# 配置防火墙
ufw --force enable 2>/dev/null || true
ufw allow 22/tcp 2>/dev/null || true
ufw allow 80/tcp 2>/dev/null || true
ufw allow 443/tcp 2>/dev/null || true

# 显示部署结果
echo ""
echo "=========================================="
echo -e "${GREEN}     部署完成！${NC}"
echo "=========================================="
echo ""
echo -e "${GREEN}API地址:${NC} http://$DOMAIN/api"
echo -e "${GREEN}健康检查:${NC} http://$DOMAIN/api/health"
echo ""
echo "数据库信息:"
echo "  - 主机: localhost"
echo "  - 端口: 5432"
echo "  - 数据库: $DB_NAME"
echo "  - 用户: $DB_USER"
echo ""
echo "Redis信息:"
echo "  - 主机: localhost"
echo "  - 端口: 6379"
echo ""
echo "常用命令:"
echo "  - 查看日志: pm2 logs 10kbooks-server"
echo "  - 重启服务: pm2 restart 10kbooks-server"
echo "  - 查看状态: pm2 status"
echo "  - 数据库: sudo -u postgres psql -d $DB_NAME"
echo ""
echo "=========================================="
echo ""

# 测试API
echo "测试API..."
sleep 2
curl -s --max-time 10 http://localhost:$APP_PORT/api/health || echo "API测试中，请稍后重试"
echo ""
