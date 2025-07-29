#!/bin/bash

# DMG 创建修复脚本
# 解决 macOS 上 create-dmg 的兼容性问题

set -e

VERSION=$1
APP_PATH=$2

if [ -z "$VERSION" ] || [ -z "$APP_PATH" ]; then
    echo "使用方法: ./scripts/fix-dmg.sh <version> <app_path>"
    echo "例如: ./scripts/fix-dmg.sh 1.0.0 GameAssetCreator.app"
    exit 1
fi

echo "🔧 开始修复 DMG 创建问题..."

# 检查应用是否存在
if [ ! -d "$APP_PATH" ]; then
    echo "❌ 应用不存在: $APP_PATH"
    exit 1
fi

DMG_NAME="GameAssetCreator-v$VERSION-macos.dmg"

echo "📦 方法 1: 使用系统 hdiutil 命令"
echo "=================="

# 使用系统自带的 hdiutil 创建 DMG
if hdiutil create -volname "GameAssetCreator v$VERSION" -srcfolder "$APP_PATH" -ov -format UDZO "$DMG_NAME" 2>/dev/null; then
    echo "✅ DMG 创建成功: $DMG_NAME"
    echo "📏 DMG 大小: $(du -h "$DMG_NAME" | cut -f1)"
    exit 0
else
    echo "❌ hdiutil 创建失败"
fi

echo ""
echo "📦 方法 2: 使用 create-dmg 简化选项"
echo "=================="

# 检查 create-dmg 是否安装
if ! command -v create-dmg &> /dev/null; then
    echo "❌ create-dmg 未安装"
    echo "💡 安装命令: brew install create-dmg"
    exit 1
fi

# 使用 create-dmg 简化选项
if create-dmg \
    --volname "GameAssetCreator v$VERSION" \
    --window-pos 200 120 \
    --window-size 600 300 \
    --icon-size 80 \
    --icon "$APP_PATH" 150 150 \
    --hide-extension "$APP_PATH" \
    --app-drop-link 450 150 \
    --skip-jenkins \
    --no-internet-enable \
    --no-find-replace \
    "$DMG_NAME" \
    "$APP_PATH" 2>/dev/null; then
    echo "✅ DMG 创建成功: $DMG_NAME"
    echo "📏 DMG 大小: $(du -h "$DMG_NAME" | cut -f1)"
    exit 0
else
    echo "❌ create-dmg 创建失败"
fi

echo ""
echo "📦 方法 3: 手动创建 DMG"
echo "=================="

echo "💡 手动创建 DMG 步骤:"
echo "1. 打开磁盘工具 (Disk Utility)"
echo "2. 创建新的空白 DMG 映像"
echo "3. 将应用拖拽到 DMG 中"
echo "4. 设置 DMG 属性"
echo "5. 保存为: $DMG_NAME"

echo ""
echo "🔧 其他解决方案:"
echo "1. 更新 create-dmg: brew upgrade create-dmg"
echo "2. 检查 macOS 版本兼容性"
echo "3. 使用 PKG 格式替代 DMG"
echo "4. 检查应用签名和权限"

exit 1 