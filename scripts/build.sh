#!/bin/bash

# Xiaomi 14 (SM8650) 内核构建脚本

set -euo pipefail

# 默认配置
KERNEL_VERSION="6.1"
KSU_VARIANT="SukiSU"
APPLY_GUNYAH_PATCH="true"

# 解析命令行参数
while [[ $# -gt 0 ]]; do
  case $1 in
    --kernel-version)
      KERNEL_VERSION="$2"
      shift 2
      ;;
    --ksu-variant)
      KSU_VARIANT="$2"
      shift 2
      ;;
    --no-gunyah-patch)
      APPLY_GUNYAH_PATCH="false"
      shift
      ;;
    --help)
      echo "用法: $0 [选项]"
      echo ""
      echo "选项:"
      echo "  --kernel-version VERSION    内核版本 (默认: 6.1)"
      echo "  --ksu-variant VARIANT       KernelSU 变体 (默认: SukiSU)"
      echo "  --no-gunyah-patch           不应用 Gunyah 补丁"
      echo "  --help                      显示此帮助信息"
      exit 0
      ;;
    *)
      echo "未知选项: $1"
      exit 1
      ;;
  esac
done

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 检查依赖
check_deps() {
  print_info "检查依赖..."
  local missing=()
  for cmd in git repo make aarch64-linux-gnu-gcc; do
    if ! command -v "$cmd" &>/dev/null; then
      missing+=("$cmd")
    fi
  done
  if [ ${#missing[@]} -gt 0 ]; then
    print_error "缺少依赖: ${missing[*]}"
    exit 1
  fi
  print_info "依赖检查通过"
}

# 设置目录
WORKSPACE="$(pwd)/build"
KERNEL_ROOT="$WORKSPACE/kernel_platform"
OUTPUT_DIR="$WORKSPACE/output"

# 创建工作目录
create_workspace() {
  print_info "创建工作目录..."
  rm -rf "$WORKSPACE"
  mkdir -p "$WORKSPACE" "$OUTPUT_DIR"
}

# 同步内核源码
sync_source() {
  print_info "同步内核源码..."
  cd "$WORKSPACE"
  repo init -u https://github.com/Xiaomichael/kernel_manifest.git \
    -b "refs/heads/oneplus/sm8650" \
    -m "oneplus_12_b.xml" \
    --depth=1
  repo sync -c -j"$(nproc --all)" --no-tags --no-clone-bundle --force-sync
  print_info "源码同步完成"
}

# 应用补丁
apply_patches() {
  if [ "$APPLY_GUNYAH_PATCH" = "true" ]; then
    print_info "应用 Gunyah 补丁..."
    cd "$KERNEL_ROOT/common"
    local patch_dir="$(cd "$(dirname "$0")/.." && pwd)/patches"
    for patch in "$patch_dir"/*.patch; do
      if [ -f "$patch" ]; then
        print_info "应用: $(basename "$patch")"
        git apply --check "$patch" 2>/dev/null || true
        git apply "$patch" || print_warn "补丁失败: $(basename "$patch")"
      fi
    done
    print_info "补丁应用完成"
  fi
}

# 设置 KernelSU
setup_ksu() {
  print_info "设置 KernelSU ($KSU_VARIANT)..."
  cd "$KERNEL_ROOT"
  case "$KSU_VARIANT" in
    "SukiSU")
      curl -fsSL https://raw.githubusercontent.com/ShirkNeko/SukiSU_patch/main/setup.sh -o setup.sh
      chmod +x setup.sh
      ./setup.sh || print_warn "SukiSU 设置失败"
      ;;
    "Official")
      curl -fsSL https://raw.githubusercontent.com/tiann/KernelSU/main/setup.sh -o setup.sh
      chmod +x setup.sh
      ./setup.sh || print_warn "KernelSU 设置失败"
      ;;
    "None")
      print_info "跳过 KernelSU"
      ;;
  esac
}

# 配置内核
configure_kernel() {
  print_info "配置内核..."
  cd "$KERNEL_ROOT"
  export ARCH=arm64
  export SUBARCH=arm64
  export CROSS_COMPILE=aarch64-linux-gnu-

  make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- gki_defconfig

  if [ "$APPLY_GUNYAH_PATCH" = "true" ]; then
    echo "CONFIG_GUNYAH=y" >> .config
    echo "CONFIG_GUNYAH_PLATFORM_HOOKS=y" >> .config
    echo "CONFIG_GUNYAH_QCOM_PLATFORM=y" >> .config
  fi

  make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- olddefconfig
  print_info "配置完成"
}

# 编译内核
build_kernel() {
  print_info "编译内核..."
  cd "$KERNEL_ROOT"
  export ARCH=arm64
  export SUBARCH=arm64
  export CROSS_COMPILE=aarch64-linux-gnu-

  make -j"$(nproc --all)" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image

  if [ -f arch/arm64/boot/Image ]; then
    print_info "编译成功！"
    ls -lh arch/arm64/boot/Image
  else
    print_error "编译失败"
    exit 1
  fi
}

# 打包产物
package_output() {
  print_info "打包产物..."
  cp "$KERNEL_ROOT/arch/arm64/boot/Image" "$OUTPUT_DIR/"
  print_info "产物目录: $OUTPUT_DIR"
  ls -lh "$OUTPUT_DIR"
}

# 主函数
main() {
  print_info "Xiaomi 14 (SM8650) 内核构建"
  print_info "内核版本: $KERNEL_VERSION"
  print_info "KernelSU: $KSU_VARIANT"
  print_info "Gunyah 补丁: $APPLY_GUNYAH_PATCH"

  check_deps
  create_workspace
  sync_source
  apply_patches
  setup_ksu
  configure_kernel
  build_kernel
  package_output

  print_info "构建完成！"
  print_info "内核镜像: $OUTPUT_DIR/Image"
}

main