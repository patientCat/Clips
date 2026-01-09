#!/bin/bash

echo "🔍 测试 Clips 应用状态..."

# 检查进程
echo "1. 检查应用进程:"
ps aux | grep -i clips | grep -v grep | grep -v test_app

# 检查可执行文件
echo -e "\n2. 检查可执行文件:"
file /Users/luke/rust/clips/Clips.app/Contents/MacOS/ClipsApp

# 检查 Info.plist
echo -e "\n3. 验证 Info.plist:"
plutil -lint /Users/luke/rust/clips/Clips.app/Contents/Info.plist

# 尝试重启应用
echo -e "\n4. 重启应用..."
pkill -f ClipsApp
sleep 1
open /Users/luke/rust/clips/Clips.app
sleep 2

echo -e "\n5. 检查重启后的进程:"
ps aux | grep -i clips | grep -v grep | grep -v test_app

echo -e "\n✅ 测试完成！"
echo "如果应用正在运行但看不到图标，请检查:"
echo "- 菜单栏右上角是否有剪贴板图标或📋符号"
echo "- 控制中心中是否有隐藏的图标"
echo "- 系统偏好设置 > 安全性与隐私 > 辅助功能中是否需要授权"