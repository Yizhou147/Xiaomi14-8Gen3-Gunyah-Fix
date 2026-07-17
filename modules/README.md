# Gunyah kvcalloc 修复模块

## 文件说明

| 文件 | 说明 |
|------|------|
| `gunyah_kvcalloc_fix.zip` | KernelSU/Magisk 刷入模块，重启后自动加载 |
| `gunyah_kvcalloc_mod.ko` | 独立内核模块文件，可用于 `insmod` 手动加载 |

## 原理

通过 kprobe 钩子劫持 Gunyah 内核驱动的内存分配函数，将 `kcalloc` 替换为 `kvcalloc`（使用 vmalloc），解决大内存 VM 创建时的 OOM 问题。

## 兼容性

- 内核版本：`6.1.138-android14-11-g5929004f86ffc-ab10010184-4k`
- 设备：小米14（SM8650），理论上兼容所有 SM8650 设备
- 需要 KernelSU 或 Magisk root

## 使用方法

### 方式一：ZIP 模块刷入（推荐）
1. 将 `gunyah_kvcalloc_fix.zip` 传到手机
2. 打开 KernelSU/Magisk Manager → 模块 → 从本地安装
3. 选择 ZIP 文件，安装后重启
4. 检查日志：`su -c cat /data/local/tmp/gunyah_kvcalloc.log`

### 方式二：手动加载
```bash
su
cp gunyah_kvcalloc_mod.ko /data/local/tmp/
insmod /data/local/tmp/gunyah_kvcalloc_mod.ko
```

## 作者

**秋秋** QQ: 3487467850
