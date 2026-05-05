---
AIGC:
    ContentProducer: Minimax Agent AI
    ContentPropagator: Minimax Agent AI
    Label: AIGC
    ProduceID: "00000000000000000000000000000000"
    PropagateID: "00000000000000000000000000000000"
    ReservedCode1: 304402207d7ed2f78bfc66a964b19b138ce3273b7438068aebf957a2be920229df329f32022071b2325345f1442f4ff7a0aaf5b8c837fae05cf36e0a30f18803b1cf0fdfef53
    ReservedCode2: 3044022027835b8d91ce15148f050a5d2b035e7d66f287a04332763e76e91261205d5df202200e9bc98793b3ff84198fa49c10e1491a6b430304fa3aaabf2e4eb959c7edf7dc
---

# 万卷书苑 10kbooks

数字阅读与创作平台 - 完整工程源码

## 项目简介

万卷书苑（10kbooks）是一个功能完善的数字阅读与创作平台，支持多端访问（Web、移动端），提供从书籍创作、发布、阅读到社交互动的全流程服务。平台融合了先进的AI能力（写作辅助、摘要、翻译、问答等），并内置完整的会员体系、支付系统及审核机制。

**当前版本**: v1.1
**发布日期**: 2026年3月13日
**主要更新**: 多语言切换功能（支持简体中文、英语、西班牙语、法语、德语、俄语、阿拉伯语）

## 技术架构

| 模块 | 技术栈 | 说明 |
|------|--------|------|
| Web前端 | Next.js (React) + TypeScript | SSR支持，SEO友好，响应式设计 |
| 移动端 | Flutter (Dart) | 同时支持iOS和Android |
| 后端 | NestJS (Node.js) + TypeScript | 模块化架构，RESTful API + GraphQL |
| 数据库 | PostgreSQL + Prisma ORM | 关系型数据库 |
| 缓存 | Redis | 会话管理、高频数据缓存 |
| 文件存储 | AWS S3 / 阿里云OSS | 存储书籍PDF、用户头像 |
| 搜索引擎 | Elasticsearch | 全文检索、AI知识库 |
| 消息队列 | RabbitMQ | 异步处理通知、审核任务 |
| AI服务 | OpenAI API / PyTorch | 写作辅助、翻译、摘要 |

## 项目结构

```
10kbooks/
├── web/                    # Web前端项目
│   ├── src/
│   │   ├── app/           # Next.js App Router页面
│   │   ├── components/    # React组件
│   │   ├── hooks/         # 自定义Hooks
│   │   ├── services/      # API服务层
│   │   ├── stores/        # 状态管理
│   │   ├── types/         # TypeScript类型定义
│   │   ├── i18n/          # 国际化配置
│   │   └── utils/         # 工具函数
│   ├── public/            # 静态资源
│   └── package.json
│
├── mobile/                 # Flutter移动端项目
│   ├── lib/
│   │   ├── core/          # 核心配置与工具
│   │   ├── features/     # 功能模块
│   │   └── shared/       # 共享组件与服务
│   ├── android/          # Android平台配置
│   ├── ios/              # iOS平台配置
│   └── pubspec.yaml
│
├── server/                 # NestJS后端服务
│   ├── src/
│   │   ├── modules/      # 功能模块
│   │   │   ├── auth/     # 认证模块
│   │   │   ├── user/     # 用户模块
│   │   │   ├── book/     # 书籍模块
│   │   │   ├── chapter/  # 章节模块
│   │   │   ├── order/    # 订单模块
│   │   │   ├── payment/  # 支付模块
│   │   │   ├── ai/       # AI服务模块
│   │   │   ├── notification/ # 通知模块
│   │   │   └── admin/    # 后台管理模块
│   │   ├── config/       # 配置文件
│   │   ├── database/     # 数据库配置与迁移
│   │   └── common/       # 公共模块
│   └── package.json
│
├── docker/                 # Docker部署配置
│   ├── docker-compose.yml
│   ├── Dockerfile.web
│   ├── Dockerfile.server
│   └── nginx.conf
│
└── docs/                   # 项目文档
    └── SPEC.md
```

## 快速开始

### 环境要求

- Node.js >= 18.0.0
- Python >= 3.10
- Flutter >= 3.0
- PostgreSQL >= 14
- Redis >= 6
- Docker >= 20.10

### Web前端

```bash
cd web
npm install
npm run dev
# 访问 http://localhost:3000
```

### 移动端

```bash
cd mobile
flutter pub get
flutter run
```

### 后端服务

```bash
cd server
npm install
npx prisma generate
npx prisma db push
npm run start:dev
# 服务运行在 http://localhost:3001
```

### Docker部署

```bash
cd docker
docker-compose up -d
```

## 功能模块

### 用户系统
- 注册/登录（手机号/邮箱 + 密码/验证码）
- 实名认证（身份证、护照）
- 邀请码机制
- 个人信息管理

### 作者系统
- 作者主页与作品展示
- 书籍管理（创建、编辑、分类、标签）
- 章节管理（在线写作、存稿、发布、定时发布）
- AI写作辅助（续写、润色、灵感生成）

### 书籍系统
- PDF上传与在线写作双模式
- 章节收费设置（免费、单章购买、整本购买）
- 书籍赠送功能
- 版权保护与水印

### 阅读器系统
- 多种阅读模式（翻页、滚动、夜间模式）
- 多端阅读进度同步
- AI辅助阅读（翻译、摘要、问答）
- 防盗版水印

### 社交系统
- 关注作者/读者
- 动态发布与互动
- 评论与评分
- 书单功能

### VIP会员系统
- 会员等级（普通/VIP）
- 会员类型（月度、年度、永久）
- 会员特权
- 自动续费管理

### 支付与提现
- 多币种支持（CNY/USD）
- Stripe、PayPal支付集成
- 平台抽佣（15%）
- 作者提现（T+7周期）

### AI系统
- 智能摘要
- 知识问答
- 多语言翻译
- 写作辅助
- 知识检索

### 多语言支持
- 简体中文、英语、西班牙语、法语、德语、俄语、阿拉伯语
- 界面语言自动适配
- 书籍多语言版本

## 许可证

本项目仅供学习和参考使用，商业使用需获得授权。

## 联系方式

技术支持: support@10kbooks.com
商务合作: business@10kbooks.com

---

**10kbooks Technology Team**
