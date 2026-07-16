# Xiaomi 14 Kernel (SM8650) - Gunyah 修复

为小米14（骁龙8 Gen 3 / SM8650）构建的内核，修复了 Gunyah 虚拟机内存分配问题。

## 问题描述

骁龙8 Gen 3 设备存在 Gunyah 内存分配问题，导致虚拟机无法正常启动：
- 错误：`failed to initialize virtual machine No such device (os error 19)`
- 日志：`RM rejected message 56000004. Error: 2` 和 `Failed to start VM: -19`

参考：[CVE-2026-43347](https://nvd.nist.gov/vuln/detail/CVE-2026-43347)

## 修复方案

通过在设备树中正确预留 Gunyah 元数据区域（512 KiB）解决此问题。

## 使用方法

### 方法一：GitHub Actions（推荐）

1. **Fork 本仓库**
2. **启用 Actions**：进入仓库 → Actions → 启用工作流
3. **触发构建**：
   - 选择 `Build Xiaomi 14 Kernel (SM8650)`
   - 点击 `Run workflow`
   - 选择参数（推荐：内核版本 `6.1`，KernelSU `SukiSU`，启用 Gunyah 修复）
   - 点击 `Run workflow`
4. **下载产物**：构建完成后在 Artifacts 或 Releases 中下载

### 方法二：本地构建

```bash
# 克隆仓库
git clone https://github.com/你的用户名/Xiaomi14-Kernel-SM8650.git
cd Xiaomi14-Kernel-SM8650

# 运行构建脚本
./scripts/build.sh

# 或使用自定义参数
./scripts/build.sh --kernel-version 6.1 --ksu-variant SukiSU
```

## 文件结构

```
Xiaomi14-Kernel-SM8650/
├── patches/
│   ├── 0001-arm64-dts-qcom-sm8650-reserve-gunyah-metadata.patch
│   └── 0002-arm64-dts-qcom-sm8650-fix-gunyah-memory-region.patch
├── .github/workflows/
│   └── build.yml
├── scripts/
│   └── build.sh
└── README.md
```

## 构建参数

| 参数 | 说明 | 推荐值 |
|------|------|--------|
| 内核版本 | 内核版本 | 6.1 |
| KernelSU | Root 方案 | SukiSU |
| Gunyah 修复 | 应用内存修复补丁 | 是 |

## 刷入内核

### 使用 fastboot

```bash
adb reboot bootloader
fastboot flash boot Image
fastboot reboot
```

### 使用 TWRP

1. 将内核镜像传输到手机
2. 重启到 TWRP
3. 选择"安装" → 选择镜像 → 刷入
4. 重启设备

## 注意事项

1. **风险提示**：刷入自定义内核有风险，建议先备份 Boot 镜像
2. **兼容性**：适用于所有 SM8650 设备，但以小米14为主要目标
3. **补丁来源**：基于 CVE-2026-43347 修复方案

## 参考链接

- [DroidVM Issue #4](https://github.com/Droid-VM/DroidVM/issues/4)
- [ABK 项目](https://github.com/xingguangcuican6666/ABK)
- [KernelSU](https://github.com/tiann/KernelSU)
- [SukiSU](https://github.com/ShirkNeko/SukiSU_patch)

## 许可证

GPL-3.0