#!/bin/bash

# GameAssetCreator 发布脚本
# 使用方法: ./scripts/release.sh <version>
# 例如: ./scripts/release.sh 1.0.0

set -e

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "请提供版本号"
    echo "使用方法: ./scripts/release.sh <version>"
    echo "例如: ./scripts/release.sh 1.0.0"
    exit 1
fi

echo "🚀 开始发布 GameAssetCreator v$VERSION"

# 1. 更新版本号
echo "📝 更新版本号..."
echo "$VERSION" > .version

# 2. 构建应用
echo "🔨 构建应用..."
wails build

# 3. 创建发布目录
echo "📁 创建发布目录..."
mkdir -p releases/v$VERSION

# 4. 复制构建文件
echo "📋 复制构建文件..."
cp -r build/bin/* releases/v$VERSION/

# 5. 创建发布说明
echo "📄 创建发布说明..."
cat > releases/v$VERSION/CHANGELOG.md << EOF
# GameAssetCreator v$VERSION

## 🎉 新版本发布

### ✨ 新功能
- 序列帧分离功能
- 深色主题支持
- 现代化界面设计

### 🐛 修复
- 优化用户体验
- 提升性能表现

### 📦 下载
- Windows: GameAssetCreator.exe
- macOS: GameAssetCreator
- Linux: GameAssetCreator

## 📋 安装说明
1. 下载对应平台的安装包
2. 解压到任意目录
3. 运行可执行文件

## 🆘 问题反馈
如有问题，请在 GitHub Issues 中反馈。
EOF

# 6. 创建压缩包
echo "📦 创建压缩包..."
cd releases/v$VERSION
tar -czf GameAssetCreator-v$VERSION-linux-amd64.tar.gz GameAssetCreator
zip -r GameAssetCreator-v$VERSION-windows-amd64.zip GameAssetCreator.exe
tar -czf GameAssetCreator-v$VERSION-macos-amd64.tar.gz GameAssetCreator

# 7. 显示发布信息
echo ""
echo "✅ 发布完成！"
echo "📁 发布文件位置: releases/v$VERSION/"
echo ""
echo "📦 可用的安装包:"
ls -la *.tar.gz *.zip 2>/dev/null || true
echo ""
echo "🎯 下一步:"
echo "1. 在 GitHub 上创建 Release"
echo "2. 上传构建文件到 Release"
echo "3. 更新 README.md 中的下载链接"
echo ""
echo "🔗 GitHub Release 链接:"
echo "https://github.com/caoaolong/GameAssetCreator/releases/new" 