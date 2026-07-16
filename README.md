# Xiaomi 14 (SM8650) 骁龙8Gen3 Gunyah内存修复内核

## 项目说明

本项目提供 Gunyah 内存修复补丁，用于修复小米14 (SM8650) 的 Gunyah 内存分配问题。补丁可以集成到 [ABK (AnyBase Kernel)](https://github.com/xingguangcuican6666/ABK) 项目中使用。

## 问题描述

骁龙8 Gen 3 (SM8650) 设备存在 Gunyah 虚拟机管理程序内存分配问题，导致：
- 虚拟机启动失败
- 错误代码：`No such device (os error 19)`
- 参考：[CVE-2026-43347](https://nvd.nist.gov/vuln/detail/CVE-2026-43347)

## 快速开始

### 步骤一：Fork ABK项目

1. 访问 https://github.com/xingguangcuican6666/ABK
2. 点击右上角的 **"Fork"** 按钮
3. 等待 Fork 完成

### 步骤二：应用 Gunyah 补丁

#### 方法A：手动应用补丁（推荐）

1. **克隆你 Fork 的 ABK 仓库**
   ```bash
   git clone https://github.com/你的用户名/ABK.git
   cd ABK
   ```

2. **下载本项目的补丁文件**
   ```bash
   # 从本仓库下载补丁
   wget https://raw.githubusercontent.com/Yizhou147/Xiaomi14-8Gen3-Gunyah-Fix/master/patches/0001-arm64-dts-qcom-sm8650-reserve-gunyah-metadata.patch
   wget https://raw.githubusercontent.com/Yizhou147/Xiaomi14-8Gen3-Gunyah-Fix/master/patches/0002-arm64-dts-qcom-sm8650-fix-gunyah-memory-region.patch
   ```

3. **应用补丁到内核源码**
   ```bash
   # 在 ABK 项目根目录运行
   git apply 0001-arm64-dts-qcom-sm8650-reserve-gunyah-metadata.patch
   git apply 0002-arm64-dts-qcom-sm8650-fix-gunyah-memory-region.patch
   ```

4. **提交更改**
   ```bash
   git add .
   git commit -m "Apply Gunyah memory fix for SM8650 (CVE-2026-43347)"
   git push
   ```

#### 方法B：使用集成脚本

1. **下载本项目**
   ```bash
   git clone https://github.com/Yizhou147/Xiaomi14-8Gen3-Gunyah-Fix.git
   cd Xiaomi14-8Gen3-Gunyah-Fix
   ```

2. **运行集成脚本**
   ```bash
   ./scripts/apply-gunyah-patch.sh /path/to/ABK/kernel/source
   ```

### 步骤三：启用 GitHub Actions

1. 进入你 Fork 的 ABK 仓库
2. 点击 **Actions** 选项卡
3. 如果看到 "Actions isn't enabled for this repository"，点击 **"I understand my workflows, go ahead and enable them"**

### 步骤四：触发构建

1. 选择 **"构建内核"** 工作流
2. 点击 **"Run workflow"**
3. 选择参数：
   - **KernelSU 变体**：`ReSukiSU` 或 `SukiSU`（推荐）
   - **构建全部版本**：`true`
4. 点击 **"Run workflow"**

### 步骤五：下载内核

1. 构建完成后（约1-2小时）
2. 在 **Actions** 页面下载 **Artifacts**
3. 或在 **Releases** 页面下载发布版本

## 补丁说明

### Gunyah 内存修复补丁

- **补丁1**: `0001-arm64-dts-qcom-sm8650-reserve-gunyah-metadata.patch`
  - 在设备树中预留 Gunyah 元数据区域（512 KiB）
  - 解决内存分配冲突问题

- **补丁2**: `0002-arm64-dts-qcom-sm8650-fix-gunyah-memory-region.patch`
  - 优化补丁，确保内存区域不重叠
  - 提高兼容性

### 技术细节

根据 [CVE-2026-43347](https://nvd.nist.gov/vuln/detail/CVE-2026-43347)：

**问题根源**：
- 高通 Gunyah 虚拟机管理程序声称拥有 `0x91a80000` 处的 512KB 内存区域
- UEFI 固件只预留了 288KB
- 内核分配器使用了这些被虚拟机管理程序占用的内存页
- 导致同步外部中止异常，系统崩溃

**解决方案**：
- 在设备树中完整预留 Gunyah 元数据区域
- 确保内核不会分配这些内存页
- 避免与虚拟机管理程序冲突

## KernelSU 集成说明

本补丁与 KernelSU 完全兼容。在 ABK 构建时，你可以选择以下 KernelSU 变体：

- **ReSukiSU**：推荐，功能丰富，稳定性好
- **SukiSU**：另一个流行的选择
- **Official**：官方 KernelSU

**建议配置**：
- KernelSU 变体：`ReSukiSU`
- 构建全部版本：`true`

## 注意事项

1. **风险提示**：刷入自定义内核属于高风险操作，建议先备份 Boot 镜像
2. **兼容性**：本补丁适用于所有 SM8650 设备（小米14、OnePlus 12 等）
3. **骁龙8 Elite**：8 Elite (SM8750) 及以后的芯片已经重构了 Gunyah 代码，不存在此问题
4. **内核版本**：补丁适用于 android14-6.1 内核

## 相关链接

- [ABK项目](https://github.com/xingguangcuican6666/ABK)
- [DroidVM Issue #4](https://github.com/Droid-VM/DroidVM/issues/4)
- [CVE-2026-43347](https://nvd.nist.gov/vuln/detail/CVE-2026-43347)
- [KernelSU Official](https://github.com/tiann/KernelSU)
- [SukiSU](https://github.com/SukiSU-Ultra/SukiSU-Ultra)
- [ReSukiSU](https://github.com/ReSukiSU/ReSukiSU)

## 许可证

本项目基于 GPL-2.0 许可证开源。