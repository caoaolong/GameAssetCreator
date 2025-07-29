#!/bin/bash

# GameAssetCreator GitHub 上传脚本
# 使用方法: ./scripts/upload.sh <version> [--draft]
# 例如: ./scripts/upload.sh 1.0.0 --draft

set -e

VERSION=$1
DRAFT_MODE=false

# 检查参数
if [ -z "$VERSION" ]; then
    echo "请提供版本号"
    echo "使用方法: ./scripts/upload.sh <version> [--draft]"
    echo "例如: ./scripts/upload.sh 1.0.0 --draft"
    exit 1
fi

# 检查是否为草稿模式
if [ "$2" = "--draft" ]; then
    DRAFT_MODE=true
    echo "📝 将创建草稿版本"
fi

echo "🚀 开始上传 GameAssetCreator v$VERSION 到 GitHub Releases"

# 检查 GitHub CLI
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) 未安装"
    echo "💡 安装命令: https://cli.github.com/"
    echo "   或使用: brew install gh"
    exit 1
fi

# 检查是否已登录 GitHub
if ! gh auth status &> /dev/null; then
    echo "❌ 请先登录 GitHub CLI"
    echo "💡 运行: gh auth login"
    exit 1
fi

# 检查发布目录
RELEASE_DIR="releases/v$VERSION"
if [ ! -d "$RELEASE_DIR" ]; then
    echo "❌ 发布目录不存在: $RELEASE_DIR"
    echo "💡 请先运行: ./scripts/package.sh $VERSION"
    exit 1
fi

# 检查是否有安装包文件
INSTALLER_FILES=$(find "$RELEASE_DIR" -name "*.dmg" -o -name "*.pkg" -o -name "*.AppImage" -o -name "*.deb" -o -name "*.exe" 2>/dev/null | wc -l)

if [ "$INSTALLER_FILES" -eq 0 ]; then
    echo "❌ 未找到安装包文件"
    echo "💡 请先运行: ./scripts/package.sh $VERSION"
    exit 1
fi

echo "📦 找到 $INSTALLER_FILES 个安装包文件"

# 创建发布说明
echo "📄 生成发布说明..."
CHANGELOG_FILE="$RELEASE_DIR/CHANGELOG.md"
if [ -f "$CHANGELOG_FILE" ]; then
    RELEASE_NOTES=$(cat "$CHANGELOG_FILE")
else
    # 生成默认发布说明
    RELEASE_NOTES="# GameAssetCreator v$VERSION

## 🎉 新版本发布

### ✨ 新功能
- 序列帧分离功能
- 深色主题支持
- 现代化界面设计
- GitHub 链接功能

### 🐛 修复
- 优化用户体验
- 提升性能表现
- 修复跨平台兼容性问题

### 📦 下载
- Windows: GameAssetCreator-Setup.exe
- macOS: GameAssetCreator.dmg
- Linux: GameAssetCreator.AppImage

## 📋 安装说明
1. 下载对应平台的安装程序
2. 运行安装程序
3. 按照提示完成安装

## 🆘 问题反馈
如有问题，请在 GitHub Issues 中反馈。"
fi

# 检查是否已存在该版本的 Release
if gh release view "v$VERSION" &> /dev/null; then
    echo "⚠️  版本 v$VERSION 已存在"
    read -p "是否要删除现有版本并重新创建? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️  删除现有版本..."
        gh release delete "v$VERSION" --yes
    else
        echo "❌ 取消上传"
        exit 1
    fi
fi

# 准备上传参数
DRAFT_FLAG=""
if [ "$DRAFT_MODE" = true ]; then
    DRAFT_FLAG="--draft"
fi

# 创建 Release
echo "📦 创建 GitHub Release..."
gh release create "v$VERSION" \
    --title "GameAssetCreator v$VERSION" \
    --notes "$RELEASE_NOTES" \
    $DRAFT_FLAG

# 上传安装包文件
echo "📤 上传安装包文件..."
for file in "$RELEASE_DIR"/*.{dmg,pkg,AppImage,deb,exe}; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "📤 上传: $filename"
        gh release upload "v$VERSION" "$file" --clobber
    fi
done

# 上传其他文件
echo "📤 上传其他文件..."
for file in "$RELEASE_DIR"/*.{md,txt,json}; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "📤 上传: $filename"
        gh release upload "v$VERSION" "$file" --clobber
    fi
done

# 显示上传结果
echo ""
echo "✅ 上传完成！"
echo "=================="
echo "🔗 Release URL: https://github.com/caoaolong/GameAssetCreator/releases/tag/v$VERSION"

# 显示上传的文件
echo ""
echo "📦 已上传的文件:"
gh release view "v$VERSION" --json assets --jq '.assets[].name'

# 显示下一步操作
echo ""
echo "🎯 下一步:"
if [ "$DRAFT_MODE" = true ]; then
    echo "1. 检查草稿版本: https://github.com/caoaolong/GameAssetCreator/releases/tag/v$VERSION"
    echo "2. 编辑发布说明"
    echo "3. 发布正式版本"
else
    echo "1. 检查发布版本: https://github.com/caoaolong/GameAssetCreator/releases/tag/v$VERSION"
    echo "2. 测试安装包"
    echo "3. 更新文档"
    echo "4. 发布公告"
fi

echo ""
echo "📚 安装包说明:"
echo "- DMG: macOS 标准安装包，双击挂载后拖拽到 Applications 文件夹"
echo "- PKG: macOS 系统级安装包，双击运行安装向导"
echo "- AppImage: Linux 便携式应用，双击即可运行"
echo "- DEB: Ubuntu/Debian 系统安装包，使用 dpkg -i 安装"
echo "- EXE: Windows 安装程序，双击运行安装向导" 