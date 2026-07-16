#!/bin/bash
# Gunyah 内存修复补丁应用脚本
# 用于在 ABK 项目基础上应用 Gunyah 补丁

set -e

echo "=== Gunyah 内存修复补丁应用脚本 ==="
echo ""

# 检查是否在内核源码目录
if [ ! -f "Makefile" ] || [ ! -d "arch/arm64" ]; then
    echo "错误：请在内核源码根目录运行此脚本"
    exit 1
fi

# 检查补丁文件是否存在
PATCH_DIR="$(dirname "$0")/../patches"
if [ ! -d "$PATCH_DIR" ]; then
    echo "错误：找不到补丁目录: $PATCH_DIR"
    exit 1
fi

# 应用补丁
echo "正在应用 Gunyah 补丁..."
for patch in "$PATCH_DIR"/*.patch; do
    if [ -f "$patch" ]; then
        echo "应用补丁: $(basename "$patch")"
        if git apply --check "$patch" 2>/dev/null; then
            git apply "$patch"
            echo "✓ 补丁应用成功"
        else
            echo "⚠ 补丁可能已经应用或存在冲突，跳过"
        fi
    fi
done

echo ""
echo "=== 补丁应用完成 ==="
echo ""
echo "重要提示："
echo "1. 此补丁修复的是设备树层面的内存预留问题"
echo "2. 需要重新编译内核才能生效"
echo "3. 参考：CVE-2026-43347"
echo ""
echo "如果需要集成 KernelSU，请在 ABK 构建时选择："
echo "  - KernelSU 变体：ReSukiSU 或 SukiSU"
echo "  - 构建全部版本：true"
echo ""
echo "更多信息请查看 README.md"