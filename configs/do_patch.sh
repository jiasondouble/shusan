#!/bin/bash
# ============================================================
# 精确修改你的 rockchip_hd_rk3506g_iot_nand_defconfig
#
# 使用方法: 在 SDK 根目录下执行
#   bash do_patch.sh
# ============================================================

set -e

DEFCONFIG="buildroot/configs/rockchip_hd_rk3506g_iot_nand_defconfig"

if [ ! -f "$DEFCONFIG" ]; then
    echo "错误: 找不到 $DEFCONFIG"
    echo "请确认在 SDK 根目录下执行此脚本"
    exit 1
fi

# 备份
cp "$DEFCONFIG" "${DEFCONFIG}.bak"
echo "已备份: ${DEFCONFIG}.bak"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# [1] 关闭 Python3 (节省 ~35MB)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "[1] 关闭 Python3 ..."
sed -i 's/^BR2_PACKAGE_PYTHON3=y/# BR2_PACKAGE_PYTHON3 is not set/' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_PYTHON3_PYC_ONLY=y/# BR2_PACKAGE_PYTHON3_PYC_ONLY is not set/' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_PYTHON3_SSL=y/# BR2_PACKAGE_PYTHON3_SSL is not set/' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_PYTHON3_UNICODEDATA=y/# BR2_PACKAGE_PYTHON3_UNICODEDATA is not set/' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_PYTHON3_PYEXPAT=y/# BR2_PACKAGE_PYTHON3_PYEXPAT is not set/' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_PYTHON3_ZLIB=y/# BR2_PACKAGE_PYTHON3_ZLIB is not set/' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_HOST_PYTHON3=y/# BR2_PACKAGE_HOST_PYTHON3 is not set/' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_HOST_PYTHON3_SSL=y/# BR2_PACKAGE_HOST_PYTHON3_SSL is not set/' "$DEFCONFIG"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# [2] 关闭 rockchip-test (节省 ~8.7MB)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "[2] 关闭 rockchip-test ..."
sed -i 's/^BR2_PACKAGE_ROCKCHIP_TEST=y/# BR2_PACKAGE_ROCKCHIP_TEST is not set/' "$DEFCONFIG"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# [3] 关闭 GStreamer (节省 ~4MB)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "[3] 关闭 GStreamer ..."
sed -i 's/^BR2_PACKAGE_GSTREAMER1=y/# BR2_PACKAGE_GSTREAMER1 is not set/' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_GSTREAMER1_PARSE=y/# BR2_PACKAGE_GSTREAMER1_PARSE is not set/' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_GSTREAMER1_TRACE=y/# BR2_PACKAGE_GSTREAMER1_TRACE is not set/' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_GSTREAMER1_GST_DEBUG=y/# BR2_PACKAGE_GSTREAMER1_GST_DEBUG is not set/' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_GSTREAMER1_PLUGIN_REGISTRY=y/# BR2_PACKAGE_GSTREAMER1_PLUGIN_REGISTRY is not set/' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_GSTREAMER1_INSTALL_TOOLS=y/# BR2_PACKAGE_GSTREAMER1_INSTALL_TOOLS is not set/' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_GST1_PLUGINS_GOOD_PLUGIN_V4L2=y/# BR2_PACKAGE_GST1_PLUGINS_GOOD_PLUGIN_V4L2 is not set/' "$DEFCONFIG"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# [4] 关闭 ALSA 音频 (节省 ~3MB)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "[4] 关闭 ALSA ..."
sed -i 's/^BR2_PACKAGE_ALSA_LIB=y/# BR2_PACKAGE_ALSA_LIB is not set/' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_ALSA_LIB_DEVDIR=.*/# BR2_PACKAGE_ALSA_LIB is not set/' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_ALSA_LIB_PCM_PLUGINS=.*//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_ALSA_LIB_CTL_PLUGINS=.*//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_ALSA_LIB_ALOAD=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_ALSA_LIB_MIXER=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_ALSA_LIB_PCM=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_ALSA_LIB_RAWMIDI=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_ALSA_LIB_HWDEP=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_ALSA_LIB_SEQ=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_ALSA_LIB_UCM=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_ALSA_LIB_ALISP=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_ALSA_LIB_OLD_SYMBOLS=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_ALSA_LIB_TOPOLOGY=y//' "$DEFCONFIG"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# [5] 关闭蓝牙 (节省 ~4.8MB)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "[5] 关闭蓝牙 ..."
sed -i 's/^BR2_PACKAGE_BLUEZ5_UTILS_HEADERS=y/# BR2_PACKAGE_BLUEZ5_UTILS_HEADERS is not set/' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_BLUEZ5_UTILS=y/# BR2_PACKAGE_BLUEZ5_UTILS is not set/' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_BLUEZ5_UTILS_OBEX=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_BLUEZ5_UTILS_CLIENT=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_BLUEZ5_UTILS_MONITOR=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_BLUEZ5_UTILS_TOOLS=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_BLUEZ5_UTILS_DEPRECATED=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_BLUEZ5_UTILS_PLUGINS_AUDIO=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_BLUEZ5_UTILS_PLUGINS_HID=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_BLUEZ5_UTILS_PLUGINS_HOG=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_BLUEZ5_UTILS_PLUGINS_NETWORK=y//' "$DEFCONFIG"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# [6] 关闭 WiFi — wpa_supplicant (节省 ~2.1MB)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "[6] 关闭 wpa_supplicant ..."
sed -i 's/^BR2_PACKAGE_WPA_SUPPLICANT=y/# BR2_PACKAGE_WPA_SUPPLICANT is not set/' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_WPA_SUPPLICANT_NL80211=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_WPA_SUPPLICANT_AP_SUPPORT=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_WPA_SUPPLICANT_AUTOSCAN=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_WPA_SUPPLICANT_EAP=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_WPA_SUPPLICANT_DEBUG_SYSLOG=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_WPA_SUPPLICANT_WPA3=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_WPA_SUPPLICANT_CLI=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_WPA_SUPPLICANT_WPA_CLIENT_SO=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_WPA_SUPPLICANT_PASSPHRASE=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_WPA_SUPPLICANT_CTRL_IFACE=y//' "$DEFCONFIG"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# [7] 关闭 WiFi — hostapd (节省 ~1.0MB)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "[7] 关闭 hostapd ..."
sed -i 's/^BR2_PACKAGE_HOSTAPD=y/# BR2_PACKAGE_HOSTAPD is not set/' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_HOSTAPD_DRIVER_HOSTAP=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_HOSTAPD_DRIVER_NL80211=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_HOSTAPD_HAS_WIFI_DRIVERS=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_HOSTAPD_ACS=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_HOSTAPD_WPA3=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_HOSTAPD_VLAN=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_HOSTAPD_VLAN_DYNAMIC=y//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_HOSTAPD_VLAN_NETLINK=y//' "$DEFCONFIG"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# [8] 关闭 ADB (节省 ~2.9MB)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "[8] 关闭 ADB ..."
sed -i 's/^BR2_PACKAGE_ANDROID_ADBD=y/# BR2_PACKAGE_ANDROID_ADBD is not set/' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_ANDROID_ADBD_TCP_PORT=.*//' "$DEFCONFIG"
sed -i 's/^BR2_PACKAGE_RKSCRIPT_USB_ADBD=y/# BR2_PACKAGE_RKSCRIPT_USB_ADBD is not set/' "$DEFCONFIG"

echo ""
echo "================================================"
echo "  defconfig 修改完成!"
echo ""
echo "  现在请验证修改结果:"
echo "  grep 'PYTHON3\|ROCKCHIP_TEST\|WPA_SUPPLICANT\|BLUEZ5\|GSTREAMER1\|ALSA_LIB\|ADBD\|HOSTAPD' $DEFCONFIG | grep '=y'"
echo ""
echo "  如果上面的命令没有输出, 说明全部关闭成功"
echo ""
echo "  接下来请执行:"
echo "  1) 删除旧的编译产物:"
echo "     rm -rf buildroot/output/rockchip_hd_rk3506g_iot_nand/target"
echo "     rm -rf buildroot/output/rockchip_hd_rk3506g_iot_nand/build"
echo "     rm -rf buildroot/output/rockchip_hd_rk3506g_iot_nand/images"
echo ""
echo "  2) 重新编译:"
echo "     ./build.sh buildroot"
echo ""
echo "  3) 编译完成后烧写新的 rootfs"
echo "================================================"
