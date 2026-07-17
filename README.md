# Xiaomi 14 (SM8650) Gunyah VMID 修复内核

## 项目说明

本项目基于 [ABK (AnyBase Kernel)](https://github.com/xingguangcuican6666/ABK) 的完整构建流程，为小米14 (SM8650 / 骁龙8 Gen 3) 编译带有 **Gunyah VMID 修复** 的 GKI 内核。

## 问题描述

骁龙8 Gen 3 (SM8650) 的 Gunyah 虚拟机管理程序存在 VMID 映射问题：
- SM8650 上 RM（Resource Manager）运行在独立 VM，VMID 大于 `QCOM_SCM_MAX_MANAGED_VMID (0x3F)`
- 原始内核代码硬编码 HLOS VMID，导致 SCM 调用拒绝，虚拟机无法启动
- 表现为 DroidVM 等虚拟化应用报错：`No such device (os error 19)` 或 `Out of memory (os error 12)`

> **注意**：骁龙8 Elite (SM8750) 及以后的芯片已重构 Gunyah 代码，不存在此问题。

## 快速开始

### 直接使用本仓库（推荐）

1. **Fork 本仓库**
2. 进入 **Actions** 选项卡，启用 GitHub Actions
3. 选择 **kernel-custom** 工作流，点击 **Run workflow**
4. 参数保持默认即可（`use_gunyah=true`）
5. 等待构建完成（约1-2小时），下载 Artifacts 中的内核包
6. 通过 TWRP 或 fastboot 刷入

### 构建参数说明

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `android_version` | android14 | Android 版本 |
| `kernel_version` | 6.1 | 内核版本 |
| `sub_level` | 138 | 内核子版本号 |
| `os_patch_level` | 2025-06 | 安全补丁级别 |
| `kernelsu_variant` | Official | KernelSU 变体 |
| `kernelsu_branch` | Stable(标准) | KernelSU 分支 |
| `use_gunyah` | true | 启用 Gunyah VMID 修复 |
| `use_ntsync` | false | 启用 NTsync 补丁 |
| `cancel_susfs` | true | 禁用 SUSFS |
| `virtualization_support` | 678 | DroidSpaces 虚拟化槽位 |

## 内核包含的修复

### Gunyah VMID 修复（核心）

在内核编译时修改 `gunyah_qcom.c` 中的 VMID 处理逻辑：
- 通过 `qcom_scm_map_vmid()` 查询真实 VMID 映射
- 当 VMID 超过 `QCOM_SCM_MAX_MANAGED_VMID (0x3F)` 时，使用正确的 SCM 调用路径
- 使用 `DEFINE_MUTEX` 保护 VMID 查询的并发安全

### KernelSU

集成 [KernelSU](https://github.com/tiann/KernelSU)，提供内核级 root 支持。

### DroidSpaces 虚拟化支持（可选）

通过 `virtualization_support` 参数启用 [DroidSpaces](https://github.com/ravindu644/Droidspaces-OSS) 补丁，增强虚拟化能力。

## 已知限制

- **单 VM 内存上限约 2GB**：SM8650 的 Gunyah 固件（EL2 层）对单个虚拟机有约 2GB 的内存限制，这是固件层面的硬限制，内核补丁无法绕过
- 如需更大内存，可考虑开多个较小的 VM

## 项目结构

```
.github/
  workflows/
    build.yml          # 核心构建流程（基于 ABK，含 Gunyah VMID 修复）
    kernel-custom.yml   # 自定义构建触发器
    get-manager.yml     # KernelSU Manager 下载
  scripts/
    resolve-ksu-ref.sh  # KernelSU 分支解析
    download-manager-from-actions.sh  # Manager APK 下载
config/
    config              # stock defconfig
    zram.config         # zram 配置
```

## 相关链接

- [ABK 项目](https://github.com/xingguangcuican6666/ABK)
- [DroidVM](https://github.com/Droid-VM/DroidVM)
- [DroidVM Wiki - SM8650 已知问题](https://droidvm.github.io/en/wiki/troubleshooting/common-issues.html)
- [KernelSU](https://github.com/tiann/KernelSU)
- [gh-hugepage-reserve 模块](https://github.com/Droid-VM/gh-hugepage-reserve)

## 许可证

本项目基于 GPL-2.0 许可证开源。
