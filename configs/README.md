# RK3506 网关裁剪配置文件

## 文件说明

| 文件 | 说明 | 使用方式 |
|------|------|---------|
| `kernel_disable.config` | 内核需要**关闭**的 CONFIG 选项 (约170项) | 合并到 `.config` 或在 `menuconfig` 中逐项关闭 |
| `kernel_enable.config` | 内核需要**保留**的 CONFIG 选项 (约100项) | 确保这些选项已开启 |
| `buildroot_remove_packages.config` | Buildroot 需要**移除**的包 (约120项) | 合并到 Buildroot defconfig |
| `buildroot_keep_packages.config` | Buildroot 需要**保留**的包 | 合并到 Buildroot defconfig |
| `devicetree_disable.dts` | 设备树需要**禁用**的节点 | 添加到板级 dts 文件 |
| `devicetree_enable.dts` | 设备树需要**启用**的节点 (含CAN/RS485/ETH配置) | 添加到板级 dts 文件 |
| `qt5_configure_options.sh` | Qt5 手动编译时的 configure 参数 | 手动编译 Qt 时使用 |
| `busybox_minimal.config` | BusyBox 精简命令列表 | 替换 BusyBox .config |
| `rootfs_cleanup.sh` | Rootfs 发布前自动清理脚本 | `./rootfs_cleanup.sh /path/to/rootfs` |

## 快速使用

```bash
# 1. 内核裁剪
cd kernel
make ARCH=arm rockchip_linux_defconfig
scripts/kconfig/merge_config.sh .config /path/to/kernel_disable.config
scripts/kconfig/merge_config.sh .config /path/to/kernel_enable.config
make ARCH=arm menuconfig  # 检查确认
make ARCH=arm -j$(nproc)

# 2. Buildroot 裁剪
cd buildroot
make rockchip_rk3506_defconfig
# 手动在 menuconfig 中按照 buildroot_*.config 调整
make menuconfig
make -j$(nproc)

# 3. 设备树
# 将 devicetree_disable.dts 和 devicetree_enable.dts 的内容
# 合并到你的板级 dts 文件中

# 4. Rootfs 清理
chmod +x rootfs_cleanup.sh
./rootfs_cleanup.sh output/target/
```
