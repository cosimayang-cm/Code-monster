#!/bin/bash

# 🚗 Feature Toggle 車輛系統 - 快速啟動指南

echo "🚗 Feature Toggle 車輛系統 - 快速啟動"
echo "======================================"
echo ""

# 檢查 Swift 是否已安裝
if ! command -v swift &> /dev/null; then
    echo "❌ 未找到 Swift，請先安裝 Swift"
    exit 1
fi

echo "✅ Swift 版本："
swift --version
echo ""

# 進入項目目錄
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$PROJECT_DIR"

# 構建項目
echo "🔨 正在構建項目..."
if swift build; then
    echo "✅ 構建成功！"
    echo ""
    
    # 提供選項
    echo "選擇要運行的程序："
    echo "1. 運行簡單示例 (main)"
    echo "2. 運行完整測試 (tests)"
    echo "3. 兩者都運行"
    echo ""
    read -p "請選擇 (1-3): " choice
    
    case $choice in
        1)
            echo ""
            echo "--- 運行簡單示例 ---"
            ./.build/debug/car-main
            ;;
        2)
            echo ""
            echo "--- 運行完整測試 ---"
            ./.build/debug/car-tests
            ;;
        3)
            echo ""
            echo "--- 運行簡單示例 ---"
            ./.build/debug/car-main
            echo ""
            echo "--- 運行完整測試 ---"
            ./.build/debug/car-tests
            ;;
        *)
            echo "❌ 無效選擇"
            exit 1
            ;;
    esac
else
    echo "❌ 構建失敗"
    exit 1
fi

echo ""
echo "✅ 完成！"
