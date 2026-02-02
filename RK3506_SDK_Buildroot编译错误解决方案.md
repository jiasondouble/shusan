# RK3506 SDK Buildroot 编译错误解决方案

## 问题描述

使用 RK3506 SDK 编译 buildroot 时，在 `post-build` 阶段构建 WiFi/BT 模块失败。

### 错误信息

```
>>> building aic8800 bt driver
ERROR: modpost: "__hci_cmd_sync" [.../aic_btusb.ko] undefined!
ERROR: modpost: "hci_recv_frame" [.../aic_btusb.ko] undefined!
ERROR: modpost: "hci_alloc_dev_priv" [.../aic_btusb.ko] undefined!
ERROR: modpost: "hci_free_dev" [.../aic_btusb.ko] undefined!
ERROR: modpost: "hci_register_dev" [.../aic_btusb.ko] undefined!
ERROR: modpost: "hci_unregister_dev" [.../aic_btusb.ko] undefined!
>>> ERROR: Running 00-wifibt.sh - build_wifibt failed!
```

以及：
```
mv: cannot stat '.../S05async-commit.sh': No such file or directory
```

---

## 问题原因

**内核未启用蓝牙支持（CONFIG_BT）**

HCI 符号（`hci_recv_frame`、`hci_register_dev` 等）来自 Linux 内核蓝牙子系统（`net/bluetooth/`），当前内核配置未启用蓝牙支持，导致 AIC8800 蓝牙驱动编译失败。

---

## 解决方法（二选一）

### 方法1：启用内核蓝牙支持（需要蓝牙功能时使用）

```bash
cd /home/double/aoke_3506/rk3506_linux6.1_sdk_v1.2.0

# 1. 进入内核配置菜单
./build.sh kernel-config

# 2. 在菜单中启用蓝牙：
#    Networking support --->
#        Bluetooth subsystem support --->
#            [*] Bluetooth subsystem support
#            <*>   HCI USB driver
# 保存并退出

# 3. 保存配置到 defconfig
./build.sh kernel-config savedefconfig

# 4. 重新编译
./build.sh kernel
./build.sh buildroot
```

或者直接在 defconfig 中添加：
```
CONFIG_BT=y
CONFIG_BT_BREDR=y
CONFIG_BT_HCIBTUSB=y
```

---

### 方法2：跳过蓝牙驱动编译（不需要蓝牙功能时使用）

**修改文件**：
```
/home/double/aoke_3506/rk3506_linux6.1_sdk_v1.2.0/device/rockchip/common/post-hooks/00-wifibt.sh
```

**找到约第257行**：
```bash
$KMAKE M=$RKWIFIBT_DIR/drivers/bluetooth_aic8800_driver modules
```

**改为**：
```bash
# $KMAKE M=$RKWIFIBT_DIR/drivers/bluetooth_aic8800_driver modules
echo ">>> Skipping BT driver build (CONFIG_BT not enabled)"
```

然后重新编译：
```bash
./build.sh buildroot
```

---

## 修复 S05async-commit.sh 缺失错误

**修改文件**：
```
/home/double/aoke_3506/rk3506_linux6.1_sdk_v1.2.0/buildroot/board/rockchip/rk3506/post-build-fast-display.sh
```

**找到 mv 命令那行**，在前面加文件存在性判断：
```bash
# 原代码：
mv "$TARGET_DIR/etc/init.d/pre_init/S05async-commit.sh" ...

# 改为：
[ -f "$TARGET_DIR/etc/init.d/pre_init/S05async-commit.sh" ] && \
mv "$TARGET_DIR/etc/init.d/pre_init/S05async-commit.sh" ...
```

或直接注释掉该 mv 命令。

---

## 快速验证

```bash
# 检查内核蓝牙配置状态
grep -E "^CONFIG_BT=|^CONFIG_BT_HCIBTUSB=" /home/double/aoke_3506/rk3506_linux6.1_sdk_v1.2.0/kernel-6.1/.config

# 如果输出为空或显示 "# CONFIG_BT is not set"，则需要启用蓝牙或使用方法2跳过
```

---

## 总结

| 场景 | 推荐方案 |
|------|---------|
| 需要蓝牙功能 | 方法1：启用内核 CONFIG_BT |
| 不需要蓝牙功能 | 方法2：注释掉蓝牙驱动编译 |

---

**文档版本**：V1.1  
**更新日期**：2026-02-02  
**适用SDK版本**：rk3506_linux6.1_sdk_v1.2.0
