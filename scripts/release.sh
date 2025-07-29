#!/bin/bash

# GameAssetCreator 专业发布脚本
# 使用方法: ./scripts/professional-release.sh <version> [--upload]
# 例如: ./scripts/professional-release.sh 1.0.0 --upload

set -e

VERSION=$1
UPLOAD_TO_GITHUB=false

# 检查参数
if [ -z "$VERSION" ]; then
    echo "请提供版本号"
    echo "使用方法: ./scripts/release.sh <version> [--upload]"
    echo "例如: ./scripts/release.sh 1.0.0 --upload"
    exit 1
fi

# 检查是否要上传到 GitHub
if [ "$2" = "--upload" ]; then
    UPLOAD_TO_GITHUB=true
    echo "🔗 将上传到 GitHub Releases"
fi

echo "🚀 开始 GameAssetCreator v$VERSION 专业发布流程"

# 步骤1: 检查工具
echo ""
echo "📋 步骤 1: 检查打包工具"
echo "=================="
./scripts/install-tools.sh

# 步骤2: 构建和打包应用
echo ""
echo "📋 步骤 2: 构建和打包应用"
echo "=================="
./scripts/package.sh $VERSION

# 步骤3: 显示安装程序信息
echo ""
echo "📋 步骤 3: 安装程序信息"
echo "=================="
if [ -d "releases/v$VERSION" ]; then
    echo "📦 安装程序列表:"
    ls -la releases/v$VERSION/
    echo ""
    echo "📁 安装程序位置: releases/v$VERSION/"
    
    # 显示各平台的安装程序
    echo ""
    echo "🎯 各平台安装程序:"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if [ -f "releases/v$VERSION/GameAssetCreator-v$VERSION-macos.dmg" ]; then
            echo "🍎 macOS DMG: GameAssetCreator-v$VERSION-macos.dmg"
        fi
        if [ -f "releases/v$VERSION/GameAssetCreator-v$VERSION-macos.pkg" ]; then
            echo "🍎 macOS PKG: GameAssetCreator-v$VERSION-macos.pkg"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f "releases/v$VERSION/GameAssetCreator-v$VERSION-linux-amd64.AppImage" ]; then
            echo "🐧 Linux AppImage: GameAssetCreator-v$VERSION-linux-amd64.AppImage"
        fi
        if [ -f "releases/v$VERSION/GameAssetCreator-v$VERSION-linux-amd64.deb" ]; then
            echo "🐧 Linux DEB: GameAssetCreator-v$VERSION-linux-amd64.deb"
        fi
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        if [ -f "releases/v$VERSION/GameAssetCreator-v$VERSION-windows-setup.exe" ]; then
            echo "🪟 Windows Setup: GameAssetCreator-v$VERSION-windows-setup.exe"
        fi
    fi
else
    echo "❌ 安装程序目录不存在"
    exit 1
fi

# 步骤4: 上传到 GitHub (可选)
if [ "$UPLOAD_TO_GITHUB" = true ]; then
    echo ""
    echo "📋 步骤 4: 上传到 GitHub Releases"
    echo "=================="
    
    # 检查 GitHub CLI
    if ! command -v gh &> /dev/null; then
        echo "❌ GitHub CLI (gh) 未安装，跳过上传"
        echo "安装命令: https://cli.github.com/"
    else
        # 检查是否已登录 GitHub
        if ! gh auth status &> /dev/null; then
            echo "❌ 请先登录 GitHub CLI"
            echo "运行: gh auth login"
        else
            ./scripts/upload.sh $VERSION
        fi
    fi
else
    echo ""
    echo "📋 步骤 4: 跳过上传"
    echo "=================="
    echo "💡 如需上传，请运行: ./scripts/upload.sh $VERSION"
fi

# 完成
echo ""
echo "🎉 专业发布流程完成！"
echo "=================="
echo "📁 构建文件: build/bin/"
echo "📦 安装程序: releases/v$VERSION/"
echo ""
echo "🎯 下一步:"
echo "1. 测试安装程序"
echo "2. 验证功能正常"
echo "3. 更新文档"
echo "4. 发布公告"
echo ""
echo "🔗 GitHub Release: https://github.com/caoaolong/GameAssetCreator/releases/tag/v$VERSION"
echo ""
echo "📚 安装程序说明:"
echo "- DMG: macOS 标准安装包，双击挂载后拖拽到 Applications 文件夹"
echo "- PKG: macOS 系统级安装包，双击运行安装向导"
echo "- AppImage: Linux 便携式应用，双击即可运行"
echo "- DEB: Ubuntu/Debian 系统安装包，使用 dpkg -i 安装"
echo "- EXE: Windows 安装程序，双击运行安装向导" 