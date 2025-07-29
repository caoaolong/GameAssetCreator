#!/bin/bash

# GameAssetCreator 打包工具安装脚本
# 使用方法: ./scripts/install-tools.sh

echo "🔧 安装 GameAssetCreator 打包工具"

# 检测操作系统
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 检测到 macOS 系统"
    
    # 检查 Homebrew
    if ! command -v brew &> /dev/null; then
        echo "❌ Homebrew 未安装，请先安装 Homebrew"
        echo "安装命令: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    
    echo "📦 安装 macOS 打包工具..."
    
    # 安装 create-dmg
    if ! command -v create-dmg &> /dev/null; then
        echo "📦 安装 create-dmg..."
        brew install create-dmg
    else
        echo "✅ create-dmg 已安装"
    fi
    
    # 安装 GitHub CLI
    if ! command -v gh &> /dev/null; then
        echo "📦 安装 GitHub CLI..."
        brew install gh
    else
        echo "✅ GitHub CLI 已安装"
    fi
    
    echo "✅ macOS 打包工具安装完成"
    
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "🐧 检测到 Linux 系统"
    
    # 检测包管理器
    if command -v apt &> /dev/null; then
        echo "📦 使用 apt 安装工具..."
        
        # 安装 AppImage 工具
        if ! command -v appimagetool &> /dev/null; then
            echo "📦 安装 AppImage 工具..."
            wget -O appimagetool "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage"
            chmod +x appimagetool
            sudo mv appimagetool /usr/local/bin/
        else
            echo "✅ AppImage 工具已安装"
        fi
        
        # 安装 GitHub CLI
        if ! command -v gh &> /dev/null; then
            echo "📦 安装 GitHub CLI..."
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt update
            sudo apt install gh
        else
            echo "✅ GitHub CLI 已安装"
        fi
        
    elif command -v yum &> /dev/null; then
        echo "📦 使用 yum 安装工具..."
        
        # 安装 GitHub CLI
        if ! command -v gh &> /dev/null; then
            echo "📦 安装 GitHub CLI..."
            sudo yum install 'dnf-command(config-manager)'
            sudo yum config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
            sudo yum install gh
        else
            echo "✅ GitHub CLI 已安装"
        fi
        
    else
        echo "⚠️  不支持的包管理器，请手动安装工具"
    fi
    
    echo "✅ Linux 打包工具安装完成"
    
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    echo "🪟 检测到 Windows 系统"
    
    echo "📦 Windows 打包工具需要手动安装:"
    echo ""
    echo "1. NSIS (Nullsoft Scriptable Install System):"
    echo "   - 下载: https://nsis.sourceforge.io/Download"
    echo "   - 安装后确保 makensis 在 PATH 中"
    echo ""
    echo "2. Inno Setup:"
    echo "   - 下载: https://jrsoftware.org/isinfo.php"
    echo "   - 安装后确保 iscc 在 PATH 中"
    echo ""
    echo "3. GitHub CLI:"
    echo "   - 下载: https://cli.github.com/"
    echo "   - 或使用 winget: winget install GitHub.cli"
    echo ""
    echo "✅ Windows 打包工具安装说明已显示"
    
else
    echo "❓ 未知的操作系统: $OSTYPE"
    echo "请手动安装相应的打包工具"
fi

echo ""
echo "🎯 安装完成后，可以运行以下命令创建安装程序:"
echo "   ./scripts/create-installers.sh 1.0.0"
echo ""
echo "📚 工具说明:"
echo "- create-dmg: macOS DMG 安装程序创建"
echo "- appimagetool: Linux AppImage 创建"
echo "- makensis: Windows NSIS 安装程序创建"
echo "- iscc: Windows Inno Setup 安装程序创建"
echo "- gh: GitHub CLI，用于上传到 GitHub Releases" 