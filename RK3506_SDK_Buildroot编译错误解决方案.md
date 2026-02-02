# RK3506 SDK Buildroot 编译错误解决方案

## 问题描述

使用 RK3506 SDK 编译 buildroot 时，在 `post-build` 阶段构建 WiFi/BT 模块失败，错误代码为 2。

### 错误信息摘要

```
>>> Building Wifi/BT module and firmwares...
>>> Start building wifi/BT (AIC8800DC)
>>> building aic8800 wifi driver
>>> building aic8800 bt driver
ERROR: modpost: "__hci_cmd_sync" [.../aic_btusb.ko] undefined!
ERROR: modpost: "hci_recv_frame" [.../aic_btusb.ko] undefined!
ERROR: modpost: "hci_alloc_dev_priv" [.../aic_btusb.ko] undefined!
ERROR: modpost: "hci_free_dev" [.../aic_btusb.ko] undefined!
ERROR: modpost: "hci_register_dev" [.../aic_btusb.ko] undefined!
ERROR: modpost: "hci_unregister_dev" [.../aic_btusb.ko] undefined!
>>> ERROR: Running 00-wifibt.sh - build_wifibt failed!
```

---

## 问题分析

### 主要错误原因

**AIC8800 蓝牙驱动编译失败**：内核模块 `aic_btusb.ko` 找不到 HCI（Host Controller Interface）蓝牙符号。

这些未定义的符号：
- `__hci_cmd_sync`
- `hci_recv_frame`
- `hci_alloc_dev_priv`
- `hci_free_dev`
- `hci_register_dev`
- `hci_unregister_dev`

都是 Linux 内核蓝牙子系统（`net/bluetooth/`）导出的函数。出现 "undefined" 错误意味着**内核没有启用蓝牙支持**。

### 次要错误

```
mv: cannot stat '.../S05async-commit.sh': No such file or directory
```
这是 `post-build-fast-display.sh` 脚本尝试移动一个不存在的文件。

---

## 解决方案

### 方案一：启用内核蓝牙支持（推荐）

如果您的项目需要使用 AIC8800DC WiFi/BT 模块的蓝牙功能，需要在内核配置中启用蓝牙支持。

#### 步骤 1：进入内核配置目录

```bash
cd /home/double/aoke_3506/rk3506_linux6.1_sdk_v1.2.0
```

#### 步骤 2：打开内核配置菜单

```bash
# 方法1：使用 SDK 脚本
./build.sh kernel-config

# 方法2：直接进入 kernel 目录配置
cd kernel-6.1
make ARCH=arm menuconfig
```

#### 步骤 3：启用蓝牙相关配置

在内核配置菜单中，启用以下选项：

```
Networking support  --->
    Bluetooth subsystem support  --->
        [*] Bluetooth subsystem support
        <*>   Bluetooth Classic (BR/EDR) features
        <*>   RFCOMM protocol support
        [*]     RFCOMM TTY support
        <*>   BNEP protocol support
        [*]     Multicast filter support
        [*]     Protocol filter support
        <*>   HIDP protocol support
        [*]   Bluetooth High Speed (HS) features
        [*]   Bluetooth Low Energy (LE) features
              Bluetooth device drivers  --->
                  <*> HCI USB driver
                  <*> HCI UART driver
```

或者直接编辑内核配置文件（`kernel-6.1/arch/arm/configs/` 下对应的 defconfig 文件），添加：

```
CONFIG_BT=y
CONFIG_BT_BREDR=y
CONFIG_BT_RFCOMM=y
CONFIG_BT_RFCOMM_TTY=y
CONFIG_BT_BNEP=y
CONFIG_BT_BNEP_MC_FILTER=y
CONFIG_BT_BNEP_PROTO_FILTER=y
CONFIG_BT_HIDP=y
CONFIG_BT_HS=y
CONFIG_BT_LE=y
CONFIG_BT_HCIBTUSB=y
CONFIG_BT_HCIUART=y
```

#### 步骤 4：保存配置并重新编译

```bash
# 保存内核配置
./build.sh kernel-config savedefconfig

# 重新编译内核
./build.sh kernel

# 重新编译 buildroot
./build.sh buildroot
```

---

### 方案二：禁用蓝牙驱动编译（如不需要蓝牙功能）

如果您的项目**不需要蓝牙功能**，可以修改 WiFi/BT 模块配置，跳过蓝牙驱动编译。

#### 方法 2.1：修改设备配置文件

查找并编辑您的板级配置文件，通常位于：
- `device/rockchip/rk3506/` 目录下
- 或 `device/vanxoak/hd_rk3506_iot_nand/` 目录下

查找 WiFi/BT 相关配置变量，例如：

```bash
# 禁用蓝牙，只保留WiFi
RK_WIFIBT_CHIP=AIC8800DC_WIFI  # 而不是 AIC8800DC（包含BT）
```

#### 方法 2.2：修改 00-wifibt.sh 脚本

编辑文件：
```
device/rockchip/common/post-hooks/00-wifibt.sh
```

找到 AIC8800 蓝牙驱动编译部分（约第 257 行附近），添加跳过逻辑或注释掉蓝牙驱动编译：

```bash
# 在蓝牙驱动编译前添加条件判断
if [ "$SKIP_BT_DRIVER" != "true" ]; then
    echo ">>> building aic8800 bt driver"
    $KMAKE M=$RKWIFIBT_DIR/drivers/bluetooth_aic8800_driver modules
fi
```

或直接注释掉蓝牙编译命令。

---

### 方案三：检查内核配置一致性

确保内核配置和实际编译使用的配置一致：

```bash
cd kernel-6.1

# 检查当前配置中蓝牙支持状态
grep -E "CONFIG_BT=|CONFIG_BT_HCIBTUSB=" .config

# 如果显示 CONFIG_BT is not set，则需要启用
```

如果发现配置不一致，可能是：
1. defconfig 文件与 .config 不同步
2. 编译过程中配置被覆盖

执行以下命令同步配置：

```bash
# 使用您的板级 defconfig 重新生成 .config
make ARCH=arm rockchip_defconfig  # 或您的具体 defconfig 名称

# 然后手动启用蓝牙选项
make ARCH=arm menuconfig
```

---

## 附加问题修复

### 修复 S05async-commit.sh 缺失问题

如果仍然遇到：
```
mv: cannot stat '.../S05async-commit.sh': No such file or directory
```

检查 `post-build-fast-display.sh` 脚本：

```bash
# 文件位置
board/rockchip/rk3506/post-build-fast-display.sh
```

方案：
1. 创建缺失的文件（如果需要该功能）
2. 修改脚本，添加文件存在性检查：

```bash
# 在 mv 命令前添加检查
if [ -f "$TARGET_DIR/etc/init.d/pre_init/S05async-commit.sh" ]; then
    mv "$TARGET_DIR/etc/init.d/pre_init/S05async-commit.sh" ...
fi
```

---

## 完整修复流程总结

```bash
# 1. 进入 SDK 目录
cd /home/double/aoke_3506/rk3506_linux6.1_sdk_v1.2.0

# 2. 配置内核启用蓝牙
./build.sh kernel-config
# 在菜单中启用 Bluetooth subsystem support 及相关选项
# 保存并退出

# 3. 保存配置到 defconfig
./build.sh kernel-config savedefconfig

# 4. 清理之前的编译产物（可选但推荐）
./build.sh cleanall

# 5. 重新编译内核
./build.sh kernel

# 6. 重新编译 buildroot
./build.sh buildroot

# 或一次性完整编译
./build.sh all
```

---

## 验证修复

编译成功后，检查生成的内核模块：

```bash
# 检查蓝牙模块是否正确编译
ls external/rkwifibt/drivers/bluetooth_aic8800_driver/*.ko

# 检查目标文件系统中的驱动
ls buildroot/output/rockchip_hd_rk3506b_iot_nand/target/lib/modules/*/kernel/drivers/bluetooth/
```

---

## 参考资料

- Rockchip RK3506 Linux SDK 开发手册
- Linux Kernel Bluetooth Subsystem Documentation
- AIC8800DC WiFi/BT 模块规格书

---

**文档版本**：V1.0  
**创建日期**：2026-02-02  
**适用SDK版本**：rk3506_linux6.1_sdk_v1.2.0
