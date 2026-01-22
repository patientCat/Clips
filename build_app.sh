#!/bin/bash

# Clips macOS App 构建脚本
# 使用方法: ./build_app.sh

set -e

echo "🔨 开始构建 Clips.app..."

# 进入项目目录
cd "$(dirname "$0")/Clips"

# 构建 Swift 项目
echo "📦 编译 Swift 项目..."
swift build -c release

# 创建 App Bundle 目录结构
echo "📁 创建 App Bundle 结构..."
rm -rf ../Clips.app
mkdir -p ../Clips.app/Contents/{MacOS,Resources}

# 复制可执行文件
echo "📋 复制可执行文件..."
cp .build/release/Clips ../Clips.app/Contents/MacOS/ClipsApp || cp ClipsApp ../Clips.app/Contents/MacOS/ClipsApp
chmod +x ../Clips.app/Contents/MacOS/ClipsApp

# 创建 Info.plist
echo "⚙️  创建 Info.plist..."
cat > ../Clips.app/Contents/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>ClipsApp</string>
    <key>CFBundleIdentifier</key>
    <string>com.luke.Clips</string>
    <key>CFBundleName</key>
    <string>Clips</string>
    <key>CFBundleDisplayName</key>
    <string>Clips</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2024. All rights reserved.</string>
</dict>
</plist>
EOF

# 验证 App Bundle
echo "✅ 验证 App Bundle..."
plutil -lint ../Clips.app/Contents/Info.plist
file ../Clips.app/Contents/MacOS/ClipsApp

echo "🎉 构建完成！"
echo "📍 应用位置: $(pwd)/../Clips.app"
echo ""
echo "使用方法:"
echo "1. 双击 Clips.app 运行应用"
echo "2. 或者在终端中运行: open ../Clips.app"
echo "3. 应用会在菜单栏显示一个剪贴板图标"