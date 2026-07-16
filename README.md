# Xiaomi 14 (SM8650) 骁龙8Gen3 Gunyah内存修复内核

## 项目说明

本项目基于 [ABK (AnyBase Kernel)](https://github.com/xingguangcuican6666/ABK) 构建，专门用于修复小米14 (SM8650) 的 Gunyah 内存分配问题。

## 问题描述

骁龙8 Gen 3 (SM8650) 设备存在 Gunyah 虚拟机管理程序内存分配问题，导致：
- 虚拟机启动失败
- 错误代码：`No such device (os error 19)`
- 参考：[CVE-2026-43347](https://nvd.nist.gov/vuln/detail/CVE-2026-43347)

## 快速开始

### 方法一：直接使用ABK（推荐）

1. **Fork ABK项目**
   ```bash
   # 访问 https://github.com/xingguangcuican6666/ABK
   # 点击 "Fork" 按钮
   ```

2. **启用 Actions**
   - 进入你 Fork 的仓库
   - 点击 **Actions** 选项卡
   - 点击 "I understand my workflows, go ahead and enable them"

3. **触发构建**
   - 选择 **"构建内核"** 工作流
   - 点击 **"Run workflow"**
   - 选择参数：
     - KernelSU 变体：`ReSukiSU` 或 `SukiSU`
     - 构建全部版本：`true`
   - 点击 **"Run workflow"**

4. **下载内核**
   - 构建完成后在 **Actions** 页面下载 **Artifacts**
   - 或在 **Releases** 页面下载发布版本

### 方法二：使用本项目的Gunyah补丁

如果你想保留Gunyah修复补丁，可以：

1. **Fork本项目**
2. **按照上述步骤触发构建**
3. **构建会自动应用Gunyah补丁**

## 补丁说明

### Gunyah 内存修复补丁

- **补丁1**: `0001-arm64-dts-qcom-sm8650-reserve-gunyah-metadata.patch`
  - 在设备树中预留 Gunyah 元数据区域（512 KiB）

- **补丁2**: `0002-arm64-dts-qcom-sm8650-fix-gunyah-memory-region.patch`
  - 优化补丁，避免内存区域重叠

### 技术细节

根据 [CVE-2026-43347](https://nvd.nist.gov/vuln/detail/CVE-2026-43347)：
- 高通 Gunyah 虚拟机管理程序声称拥有 `0x91a80000` 处的 512KB 内存区域
- UEFI 固件只预留了 288KB
- 内核分配器使用了这些被虚拟机管理程序占用的内存页
- 导致同步外部中止异常，系统崩溃

## 注意事项

1. **风险提示**：刷入自定义内核属于高风险操作，建议先备份 Boot 镜像
2. **兼容性**：本补丁适用于所有 SM8650 设备
3. **骁龙8 Elite**：8 Elite (SM8750) 及以后的芯片已经重构了 Gunyah 代码，不存在此问题

## 相关链接

- [ABK项目](https://github.com/xingguangcuican6666/ABK)
- [DroidVM Issue #4](https://github.com/Droid-VM/DroidVM/issues/4)
- [CVE-2026-43347](https://nvd.nist.gov/vuln/detail/CVE-2026-43347)
- [KernelSU Official](https://github.com/tiann/KernelSU)
- [SukiSU](https://github.com/SukiSU-Ultra/SukiSU-Ultra)
- [ReSukiSU](https://github.com/ReSukiSU/ReSukiSU)

## 许可证

本项目基于 GPL-2.0 许可证开源。