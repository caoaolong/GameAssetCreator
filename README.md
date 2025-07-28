# 🎮 GameAssetCreator

> 专注于打造独立开发者的瑞士军刀！

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/your-username/GameAssetCreator)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-cross--platform-orange.svg)](https://wails.io)

一个专为独立游戏开发者设计的跨平台桌面应用，提供强大的游戏资源处理工具。基于现代技术栈构建，界面简洁美观，功能强大实用。

## ✨ 功能特色

### 🎬 序列帧分离
- **GIF 动画分离**：快速将 GIF 动画分离为序列帧图片
- **智能跳帧**：支持自定义跳帧数量，优化处理效率
- **批量导出**：一键导出所有分离的帧图片
- **实时预览**：分离过程中实时预览每一帧
- **删除管理**：支持删除不需要的帧，支持撤销操作

### 🎨 界面设计
- **现代化 UI**：基于 Element Plus 的优雅界面设计
- **深色模式**：支持浅色/深色主题切换，跟随系统设置
- **响应式布局**：适配不同屏幕尺寸，提供最佳体验
- **动画效果**：流畅的交互动画，提升用户体验

### 🛠️ 技术优势
- **跨平台支持**：Windows、macOS、Linux 全平台支持
- **高性能处理**：基于 Go 语言的高效图像处理
- **现代前端**：Vue 3 + TypeScript 构建
- **原生体验**：Wails 框架提供原生桌面应用体验

## 🚀 快速开始

### 系统要求
- Windows 10+ / macOS 10.15+ / Linux (Ubuntu 18.04+)
- 至少 4GB RAM
- 500MB 可用磁盘空间

### 下载安装

#### 方式一：直接下载
1. 访问 [Releases](https://github.com/your-username/GameAssetCreator/releases) 页面
2. 下载对应平台的安装包
3. 运行安装程序

#### 方式二：源码编译
```bash
# 克隆项目
git clone https://github.com/your-username/GameAssetCreator.git
cd GameAssetCreator

# 安装依赖
go mod download
cd frontend && npm install

# 编译运行
wails dev
```

## 📖 使用指南

### 序列帧分离

1. **选择 GIF 文件**
   - 点击"选择 GIF 文件"按钮
   - 选择要处理的 GIF 动画文件

2. **配置参数**
   - **输出目录**：选择保存分离帧的文件夹
   - **跳帧数量**：设置跳帧数量（默认 12）
   - **帧名称**：设置导出文件的命名格式

3. **开始分离**
   - 点击"开始分离"按钮
   - 等待处理完成，查看预览效果

4. **管理帧图片**
   - 预览所有分离的帧
   - 删除不需要的帧（支持撤销）
   - 调整帧的顺序

5. **导出结果**
   - 点击"导出所有帧"按钮
   - 选择保存位置
   - 完成导出

## 🛠️ 技术栈

### 后端
- **Go 1.21+** - 高性能后端语言
- **Wails v2** - 跨平台桌面应用框架
- **image/gif** - GIF 图像处理
- **image/png** - PNG 图像编码
- **image/draw** - 图像合成处理

### 前端
- **Vue 3** - 渐进式 JavaScript 框架
- **TypeScript** - 类型安全的 JavaScript
- **Element Plus** - Vue 3 组件库
- **Vite** - 现代前端构建工具

### 开发工具
- **Wails CLI** - 应用开发工具
- **ESLint** - 代码质量检查
- **Prettier** - 代码格式化

## 📁 项目结构

```
GameAssetCreator/
├── app.go                 # 后端主逻辑
├── main.go               # 应用入口
├── wails.json           # Wails 配置
├── go.mod               # Go 模块配置
├── frontend/            # 前端代码
│   ├── src/
│   │   ├── views/      # 页面组件
│   │   ├── components/ # 通用组件
│   │   ├── assets/     # 静态资源
│   │   └── composables/# 组合式函数
│   ├── public/         # 公共资源
│   └── package.json    # 前端依赖
└── README.md           # 项目说明
```

## 🎯 开发计划

### 即将推出
- [ ] 图片格式转换工具
- [ ] 精灵图制作工具
- [ ] 音频处理工具
- [ ] 批量重命名功能
- [ ] 插件系统支持

### 长期规划
- [ ] 云端资源管理
- [ ] 团队协作功能
- [ ] 自动化工作流
- [ ] 更多格式支持

## 🤝 贡献指南

我们欢迎所有形式的贡献！

### 如何贡献
1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 开发环境设置
```bash
# 安装 Go 1.21+
# 安装 Node.js 18+
# 安装 Wails CLI
go install github.com/wailsapp/wails/v2/cmd/wails@latest

# 克隆项目
git clone https://github.com/your-username/GameAssetCreator.git
cd GameAssetCreator

# 安装依赖
go mod download
cd frontend && npm install

# 启动开发服务器
wails dev
```

## 📄 许可证

本项目采用 [MIT 许可证](LICENSE) - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

- [Wails](https://wails.io) - 跨平台桌面应用框架
- [Vue.js](https://vuejs.org) - 渐进式 JavaScript 框架
- [Element Plus](https://element-plus.org) - Vue 3 组件库
- [Go](https://golang.org) - 高性能编程语言

## 📞 联系我们

- **GitHub Issues**: [报告问题](https://github.com/your-username/GameAssetCreator/issues)
- **Discussions**: [参与讨论](https://github.com/your-username/GameAssetCreator/discussions)
- **Email**: your-email@example.com

---

<div align="center">

**如果这个工具对你有帮助，请给个 ⭐️ 支持一下！**

[![GitHub stars](https://img.shields.io/github/stars/your-username/GameAssetCreator?style=social)](https://github.com/your-username/GameAssetCreator)
[![GitHub forks](https://img.shields.io/github/forks/your-username/GameAssetCreator?style=social)](https://github.com/your-username/GameAssetCreator)

</div>
