#!/bin/bash
# ============================================================
# RK3506 网关 — 自动修改 Buildroot defconfig 的脚本
#
# 使用方法 (在 SDK 根目录下执行):
#
#   第一步: 找到你的 defconfig 文件
#     find buildroot/configs -name "*rk3506*"
#
#   第二步: 执行本脚本
#     bash patch_buildroot.sh <defconfig路径>
#
#   例如:
#     bash patch_buildroot.sh buildroot/configs/rockchip_rk3506_defconfig
#
#   第三步: clean 重新编译
#     cd buildroot/output/rockchip_rk3506
#     make clean
#     cd ../../..
#     ./build.sh buildroot
#
# ============================================================

set -e

DEFCONFIG="${1:?用法: $0 <defconfig文件路径>}"

if [ ! -f "$DEFCONFIG" ]; then
    echo "错误: 文件不存在: $DEFCONFIG"
    exit 1
fi

# 备份
cp "$DEFCONFIG" "${DEFCONFIG}.bak.$(date +%Y%m%d%H%M%S)"
echo "已备份到: ${DEFCONFIG}.bak.*"
echo ""

# ──────────────────────────────────────
# 函数: 关闭一个选项
# ──────────────────────────────────────
disable_option() {
    local opt="$1"
    local desc="$2"

    # 如果是 BR2_PACKAGE_XXX=y 的形式, 改为 not set
    if grep -q "^${opt}=y" "$DEFCONFIG" 2>/dev/null; then
        sed -i "s|^${opt}=y|# ${opt} is not set|" "$DEFCONFIG"
        echo "  [已关闭] ${opt}  (${desc})"
    elif grep -q "^${opt}=" "$DEFCONFIG" 2>/dev/null; then
        sed -i "s|^${opt}=.*|# ${opt} is not set|" "$DEFCONFIG"
        echo "  [已关闭] ${opt}  (${desc})"
    elif grep -q "# ${opt} is not set" "$DEFCONFIG" 2>/dev/null; then
        echo "  [已关闭] ${opt}  (${desc}) -- 已经是关闭状态"
    else
        # 选项不存在, 追加
        echo "# ${opt} is not set" >> "$DEFCONFIG"
        echo "  [已添加] ${opt}  (${desc})"
    fi
}

echo "================================================"
echo "  开始修改: $DEFCONFIG"
echo "================================================"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【1】关闭 Python 3.11 (节省 ~35 MB)"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_PYTHON3"           "Python3 主包"
disable_option "BR2_PACKAGE_PYTHON3_PY_ONLY"   "Python3 .py"
disable_option "BR2_PACKAGE_PYTHON3_PYC_ONLY"  "Python3 .pyc"
disable_option "BR2_PACKAGE_PYTHON_PIP"        "pip"
disable_option "BR2_PACKAGE_PYTHON_SETUPTOOLS" "setuptools"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【2】关闭 rockchip-test (节省 ~8.7 MB)"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_ROCKCHIP_TEST"     "Rockchip 测试包"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【3】关闭 V4L2 / DVB 视频 (节省 ~7 MB)"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_V4L_UTILS"         "v4l-utils"
disable_option "BR2_PACKAGE_LIBV4L"            "libv4l"
disable_option "BR2_PACKAGE_V4L_UTILS_COMPLIANCE" "v4l2-compliance"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【4】关闭 GStreamer (节省 ~4 MB)"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_GSTREAMER1"             "GStreamer1"
disable_option "BR2_PACKAGE_GST1_PLUGINS_BASE"      "gst-plugins-base"
disable_option "BR2_PACKAGE_GST1_PLUGINS_GOOD"      "gst-plugins-good"
disable_option "BR2_PACKAGE_GST1_PLUGINS_BAD"       "gst-plugins-bad"
disable_option "BR2_PACKAGE_GST1_PLUGINS_UGLY"      "gst-plugins-ugly"
disable_option "BR2_PACKAGE_GST1_LIBAV"             "gst-libav"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【5】关闭 WiFi (节省 ~5.6 MB)"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_WPA_SUPPLICANT"    "wpa_supplicant"
disable_option "BR2_PACKAGE_HOSTAPD"           "hostapd"
disable_option "BR2_PACKAGE_IW"                "iw"
disable_option "BR2_PACKAGE_WIRELESS_TOOLS"    "wireless-tools"
disable_option "BR2_PACKAGE_WIRELESS_REGDB"    "wireless-regdb"
# Rockchip WiFi/BT 组合包
disable_option "BR2_PACKAGE_RKWIFIBT"          "rkwifibt"
disable_option "BR2_PACKAGE_RKWIFIBT_ALL"      "rkwifibt-all"
disable_option "BR2_PACKAGE_RKWIFIBT_AP6XXX"   "rkwifibt-ap6xxx"
disable_option "BR2_PACKAGE_RKWIFIBT_RTK"      "rkwifibt-rtk"
disable_option "BR2_PACKAGE_RKWIFIBT_AIC"      "rkwifibt-aic"
disable_option "BR2_PACKAGE_RKWIFIBT_VENDOR"   "rkwifibt-vendor"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【6】关闭蓝牙 (节省 ~4.8 MB)"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_BLUEZ5_UTILS"      "bluez5"
disable_option "BR2_PACKAGE_BLUEZ5_UTILS_CLIENT"   "bluetoothctl"
disable_option "BR2_PACKAGE_BLUEZ5_UTILS_MONITOR"  "btmon"
disable_option "BR2_PACKAGE_BLUEZ5_UTILS_TOOLS"    "bluez-tools"
disable_option "BR2_PACKAGE_BLUEZ5_UTILS_DEPRECATED" "bluez-deprecated"
disable_option "BR2_PACKAGE_BLUEZ5_UTILS_PLUGINS_AUDIO" "bluez-audio"
disable_option "BR2_PACKAGE_BLUEZ5_UTILS_PLUGINS_MESH"  "bluez-mesh"
disable_option "BR2_PACKAGE_BLUEZ_ALSA"        "bluez-alsa"
disable_option "BR2_PACKAGE_BROADCOM_BSA"      "broadcom-bsa"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【7】关闭 ALSA 音频 (节省 ~3 MB)"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_ALSA_LIB"          "alsa-lib"
disable_option "BR2_PACKAGE_ALSA_UTILS"        "alsa-utils"
disable_option "BR2_PACKAGE_ALSA_PLUGINS"      "alsa-plugins"
disable_option "BR2_PACKAGE_ALSA_UCM_CONF"     "alsa-ucm-conf"
disable_option "BR2_PACKAGE_LIBSAMPLERATE"     "libsamplerate"
disable_option "BR2_PACKAGE_SPANDSP"           "spandsp"
disable_option "BR2_PACKAGE_SPEEX"             "speex"
disable_option "BR2_PACKAGE_SPEEXDSP"          "speexdsp"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【8】关闭 ADB 调试 (节省 ~2.9 MB)"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_ANDROID_TOOLS"     "android-tools"
disable_option "BR2_PACKAGE_ANDROID_TOOLS_ADBD" "adbd"
disable_option "BR2_PACKAGE_ANDROID_TOOLS_ADB"  "adb"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【9】关闭 ripgrep (节省 ~3.6 MB)"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_RIPGREP"           "ripgrep"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【10】关闭 Rockchip 多媒体 (节省 ~2.5 MB)"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_ROCKIT"            "rockit"
disable_option "BR2_PACKAGE_ROCKCHIP_RGA"      "rockchip-rga"
disable_option "BR2_PACKAGE_ROCKCHIP_MPP"      "rockchip-mpp"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【11】关闭 OpenSSH → 改用 dropbear (节省 ~3 MB)"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_OPENSSH"           "openssh"
# 开启 dropbear (轻量SSH)
if ! grep -q "^BR2_PACKAGE_DROPBEAR=y" "$DEFCONFIG" 2>/dev/null; then
    echo "BR2_PACKAGE_DROPBEAR=y" >> "$DEFCONFIG"
    echo "  [已开启] BR2_PACKAGE_DROPBEAR  (轻量SSH替代openssh)"
fi
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【12】关闭 LVGL (节省 ~1.1 MB)"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_LVGL"              "lvgl"
disable_option "BR2_PACKAGE_LV_DRIVERS"        "lv-drivers"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【13】关闭 irqbalance (节省 ~1.2 MB)"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_IRQBALANCE"        "irqbalance"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【14】关闭 bash (节省 ~0.9 MB, 用 busybox ash)"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_BASH"              "bash"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【15】关闭其他不需要的包"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_INOTIFY_TOOLS"     "inotify-tools"
disable_option "BR2_PACKAGE_INPUT_EVENT_DAEMON" "input-event-daemon"
disable_option "BR2_PACKAGE_LIBDRM"            "libdrm"
disable_option "BR2_PACKAGE_LIBDRM_INSTALL_TESTS" "modetest/kmsgrab"
disable_option "BR2_PACKAGE_TIFF"              "libtiff"
disable_option "BR2_PACKAGE_LINUX_FIRMWARE"    "linux-firmware"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【16】关闭 eudev hwdb (节省 ~9.3 MB)"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_EUDEV_ENABLE_HWDB" "eudev-hwdb"
# 如果上面的选项不存在, 我们在 post-build 脚本中删除
echo "  注: 如果 hwdb 仍存在, 需在 post-build.sh 中手动删除"
echo ""

echo ""
echo "================================================"
echo "  修改完成!"
echo ""
echo "  接下来你需要执行以下命令重新编译:"
echo ""
echo "  # 方法1: 如果用 build.sh"
echo "  cd <SDK根目录>"
echo "  source envsetup.sh rockchip_rk3506"
echo "  make clean -C buildroot/output/rockchip_rk3506"
echo "  ./build.sh buildroot"
echo ""
echo "  # 方法2: 如果直接用 make"
echo "  cd buildroot/output/rockchip_rk3506"
echo "  make clean"
echo "  make defconfig"
echo "  make -j\$(nproc)"
echo ""
echo "  编译完成后重新烧写 rootfs 分区"
echo "================================================"
