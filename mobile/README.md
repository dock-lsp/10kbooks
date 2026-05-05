# 万卷书苑 Flutter 移动端项目

## 项目简介

万卷书苑移动端是基于Flutter框架开发的跨平台数字阅读应用，支持Android和iOS系统。

## 版本信息

- **版本**: 1.1.0
- **构建号**: 11
- **最低Android版本**: API 21 (Android 5.0)
- **目标Android版本**: API 34 (Android 14)

## 技术栈

- **框架**: Flutter 3.16+
- **语言**: Dart 3.0+
- **状态管理**: flutter_bloc
- **路由**: go_router
- **依赖注入**: get_it
- **网络请求**: dio
- **本地存储**: shared_preferences, flutter_secure_storage
- **国际化**: flutter_localizations

## 项目结构

```
mobile/
├── android/                    # Android原生配置
│   ├── app/
│   │   ├── build.gradle       # App模块构建配置
│   │   ├── proguard-rules.pro # ProGuard规则
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       ├── kotlin/        # Kotlin原生代码
│   │       └── res/           # Android资源文件
│   ├── build.gradle           # 根构建配置
│   ├── gradle.properties      # Gradle配置
│   └── settings.gradle        # Gradle设置
│
├── lib/                       # Flutter Dart代码
│   ├── main.dart              # 应用入口
│   ├── core/                  # 核心配置
│   │   ├── config/           # 配置文件
│   │   ├── di/               # 依赖注入
│   │   ├── network/          # 网络相关
│   │   └── router/           # 路由配置
│   ├── features/             # 功能模块
│   │   ├── auth/            # 认证模块
│   │   ├── books/           # 书籍模块
│   │   ├── reader/          # 阅读器模块
│   │   ├── social/           # 社交模块
│   │   └── user/            # 用户模块
│   └── shared/               # 共享代码
│       ├── models/           # 数据模型
│       ├── services/         # 业务服务
│       └── widgets/          # 通用组件
│
├── assets/                    # 静态资源
│   ├── images/              # 图片资源
│   ├── icons/               # 图标资源
│   ├── animations/          # 动画资源
│   └── fonts/               # 字体资源
│
├── pubspec.yaml              # Flutter依赖配置
└── README.md                # 项目说明
```

## 环境要求

### Flutter SDK
- Flutter SDK >= 3.16.0
- Dart SDK >= 3.0.0

### Android开发环境
- Android Studio Hedgehog (2023.1.1) 或更高版本
- Android SDK API 34
- Java 17

### iOS开发环境（可选）
- Xcode 15.0 或更高版本
- CocoaPods 1.14.0 或更高版本

## 快速开始

### 1. 安装Flutter SDK

访问 [Flutter官网](https://flutter.dev/docs/get-started/install) 下载并安装Flutter SDK。

### 2. 配置环境变量

将Flutter添加到系统PATH：
```bash
export PATH="$PATH:`pwd`/flutter/bin"
```

### 3. 安装依赖

```bash
cd mobile
flutter pub get
```

### 4. 运行应用

#### Android
```bash
# 开发模式
flutter run

# 发布模式
flutter build apk --release
```

#### iOS（仅macOS）
```bash
# 开发模式
flutter run -d <device_id>

# 发布模式
flutter build ipa --release
```

## 构建说明

### Android构建

#### Debug构建
```bash
flutter build apk --debug
```
输出位置: `build/app/outputs/flutter-apk/app-debug.apk`

#### Release构建
```bash
flutter build apk --release
```
输出位置: `build/app/outputs/flutter-apk/app-release.apk`

#### 构建不同环境

```bash
# 开发环境
flutter build apk --release -t flavor development

# 预发布环境
flutter build apk --release -t flavor staging

# 生产环境
flutter build apk --release -t flavor production
```

### iOS构建

#### Debug构建
```bash
flutter build ios --debug
```

#### Release构建
```bash
flutter build ios --release
```

## 功能模块

### 首页
- Banner轮播图
- 分类浏览入口
- 推荐书籍展示
- 热门书籍展示

### 书籍详情
- 书籍信息展示
- 章节目录
- 用户评论
- 阅读/购买入口

### 阅读器
- 多种阅读模式（翻页、滚动）
- 夜间模式
- 字体大小调节
- 行间距调节
- 阅读进度同步
- AI辅助功能

### 用户中心
- 个人信息管理
- 书架管理
- 订单历史
- VIP会员管理
- 设置

### 作者中心
- 作品管理
- 章节管理
- 数据统计
- 收益管理

## 多语言支持

支持的语种：
- 简体中文 (zh-CN)
- 英语 (en)
- 西班牙语 (es)
- 法语 (fr)
- 德语 (de)
- 俄语 (ru)
- 阿拉伯语 (ar)

## 许可证

本项目仅供学习和参考使用。

## 联系方式

技术支持: support@10kbooks.com
