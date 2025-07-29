#!/bin/bash

# GameAssetCreator 构建和打包脚本
# 使用方法: ./scripts/package.sh [version]
# 例如: ./scripts/package.sh 1.0.0

set -e

VERSION=${1:-"dev"}

echo "🚀 开始 GameAssetCreator v$VERSION 构建和打包流程"

# 检查 wails
if ! command -v wails &> /dev/null; then
    echo "❌ wails 未安装，请先安装 wails"
    echo "安装命令: go install github.com/wailsapp/wails/v2/cmd/wails@latest"
    exit 1
fi

# 检查必要的工具
echo "📋 检查打包工具..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v create-dmg &> /dev/null; then
        echo "⚠️  create-dmg 未安装，将跳过 DMG 创建"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if ! command -v appimagetool &> /dev/null; then
        echo "⚠️  appimagetool 未安装，将跳过 AppImage 创建"
    fi
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    if ! command -v makensis &> /dev/null; then
        echo "⚠️  makensis 未安装，将跳过 NSIS EXE 创建"
    fi
    if ! command -v iscc &> /dev/null; then
        echo "⚠️  iscc 未安装，将跳过 Inno Setup EXE 创建"
    fi
fi

# 更新版本号
echo "📝 更新版本号..."
echo "$VERSION" > .version

# 更新 wails.json 中的版本信息
if [ -f "wails.json" ]; then
    sed -i.bak "s/\"productVersion\": \"[^\"]*\"/\"productVersion\": \"$VERSION\"/" wails.json
    rm -f wails.json.bak
    echo "✅ 版本号已更新为 v$VERSION"
fi

if [ -d "releases/v$VERSION" ]; then
    echo "🧹 清理之前的发布..."
    rm -rf "releases/v$VERSION"
fi

# 检查应用图标
echo "📋 使用默认应用图标"

# 构建应用
echo "🔨 构建应用..."
wails build

# 替换应用图标
echo "🖼️  替换应用图标..."

# 复制 icns 图标文件
if [ -f "appicon.icns" ]; then
    # 确保目标目录存在
    mkdir -p "build/appicon"
    cp appicon.icns build/appicon/icon.icns
    echo "✅ icns 应用图标已替换"
else
    echo "⚠️  根目录中未找到 appicon.icns，跳过图标替换"
fi

# 复制 png 图标文件
if [ -f "appicon.png" ]; then
    cp appicon.png build/appicon.png
    echo "✅ png 应用图标已替换"
else
    echo "⚠️  根目录中未找到 appicon.png，跳过图标替换"
fi

echo "✅ 构建完成！"

# 创建发布目录
echo "📁 创建发布目录..."
mkdir -p "releases/v$VERSION"

# 复制构建文件
echo "📋 复制构建文件..."
if [ -d "build/bin" ]; then
    cp -r build/bin/* "releases/v$VERSION/"
    echo "✅ 构建文件已复制"
else
    echo "❌ 构建目录不存在，跳过复制"
    exit 1
fi

# 创建发布说明
echo "📄 创建发布说明..."
cat > "releases/v$VERSION/CHANGELOG.md" << EOF
# GameAssetCreator v$VERSION

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
如有问题，请在 GitHub Issues 中反馈。
EOF

echo "✅ 发布说明已创建"

# 创建安装程序
echo "📦 创建安装程序..."

# macOS 安装程序
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "📦 创建 macOS 安装程序..."
    
    # 创建 DMG 安装程序
    if command -v create-dmg &> /dev/null; then
        echo "📦 创建 DMG 安装程序..."
        cd "releases/v$VERSION"
        
        # 检查是否有 .app 文件
        if [ -d "GameAssetCreator.app" ]; then
            create-dmg \
                --volname "GameAssetCreator v$VERSION" \
                --window-pos 200 120 \
                --window-size 800 400 \
                --icon-size 100 \
                --volicon "../../appicon.icns" \
                --icon "GameAssetCreator.app" 200 190 \
                --hide-extension "GameAssetCreator.app" \
                --app-drop-link 600 185 \
                "GameAssetCreator-v$VERSION-macos.dmg" \
                "GameAssetCreator.app"
            echo "✅ DMG 安装程序已创建"
        else
            echo "⚠️  未找到 GameAssetCreator.app，跳过 DMG 创建"
        fi
        cd ../..
    else
        echo "⚠️  create-dmg 未安装，跳过 DMG 创建"
    fi
fi

# Linux 安装程序
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "📦 创建 Linux 安装程序..."
    
    # 创建 AppImage
    if command -v appimagetool &> /dev/null; then
        echo "📦 创建 AppImage..."
        if [ -f "GameAssetCreator" ]; then
            appimagetool . "GameAssetCreator-v$VERSION-linux.AppImage"
            echo "✅ AppImage 已创建"
        else
            echo "⚠️  未找到 GameAssetCreator 可执行文件，跳过 AppImage 创建"
        fi
    else
        echo "⚠️  appimagetool 未安装，跳过 AppImage 创建"
    fi
fi

# Windows 安装程序
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    echo "📦 创建 Windows 安装程序..."
    
    # 创建 NSIS 安装程序
    if command -v makensis &> /dev/null; then
        echo "📦 创建 NSIS 安装程序..."
        # 这里需要 NSIS 脚本文件
        echo "⚠️  NSIS 安装程序需要脚本文件，暂时跳过"
    else
        echo "⚠️  makensis 未安装，跳过 NSIS 创建"
    fi
    
    # 创建 Inno Setup 安装程序
    if command -v iscc &> /dev/null; then
        echo "📦 创建 Inno Setup 安装程序..."
        # 这里需要 Inno Setup 脚本文件
        echo "⚠️  Inno Setup 安装程序需要脚本文件，暂时跳过"
    else
        echo "⚠️  iscc 未安装，跳过 Inno Setup 创建"
    fi
fi

echo "✅ 安装程序创建完成！"
echo "📁 安装程序位置: releases/v$VERSION/"

# 显示可用的安装程序
echo ""
echo "📦 可用的安装程序:"
ls -la "releases/v$VERSION/" | grep -E "\.(dmg|pkg|AppImage|deb|exe)$" || echo "   (无安装程序文件)"

echo ""
echo "🎯 下一步:"
echo "1. 测试安装程序"
echo "2. 上传到 GitHub Releases: ./scripts/release.sh $VERSION" 