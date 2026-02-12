#!/bin/bash
# ============================================================
# RK3506 网关 — 第二轮裁剪
# 在 SDK 根目录下执行: bash do_patch_round2.sh
#
# 第一轮: 78MB → 38MB (砍掉 Python/蓝牙/WiFi/GStreamer/ALSA)
# 第二轮: 38MB → 预计 20~25MB
# ============================================================

set -e

DEFCONFIG="buildroot/configs/rockchip_hd_rk3506b_iot_nand_defconfig"

if [ ! -f "$DEFCONFIG" ]; then
    echo "错误: 找不到 $DEFCONFIG"
    exit 1
fi

cp "$DEFCONFIG" "${DEFCONFIG}.bak2"
echo "已备份: ${DEFCONFIG}.bak2"
echo ""

disable_option() {
    local opt="$1"
    local desc="$2"
    if grep -q "^${opt}=y" "$DEFCONFIG" 2>/dev/null; then
        sed -i "s|^${opt}=y|# ${opt} is not set|" "$DEFCONFIG"
        echo "  [关闭] ${opt}  ($desc)"
    elif grep -q "^${opt}=" "$DEFCONFIG" 2>/dev/null; then
        sed -i "s|^${opt}=.*|# ${opt} is not set|" "$DEFCONFIG"
        echo "  [关闭] ${opt}  ($desc)"
    elif grep -q "# ${opt} is not set" "$DEFCONFIG" 2>/dev/null; then
        echo "  [已关] ${opt}  ($desc)"
    else
        echo "# ${opt} is not set" >> "$DEFCONFIG"
        echo "  [添加] ${opt}  ($desc)"
    fi
}

enable_option() {
    local opt="$1"
    local desc="$2"
    if grep -q "^${opt}=y" "$DEFCONFIG" 2>/dev/null; then
        echo "  [已开] ${opt}  ($desc)"
    elif grep -q "# ${opt} is not set" "$DEFCONFIG" 2>/dev/null; then
        sed -i "s|# ${opt} is not set|${opt}=y|" "$DEFCONFIG"
        echo "  [开启] ${opt}  ($desc)"
    else
        echo "${opt}=y" >> "$DEFCONFIG"
        echo "  [添加] ${opt}  ($desc)"
    fi
}

echo "================================================"
echo "  第二轮裁剪: $DEFCONFIG"
echo "================================================"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【1】hwdb.bin 9.3MB — 关闭 eudev hwdb"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_EUDEV_ENABLE_HWDB"     "eudev hwdb 9.3MB"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【2】V4L2/DVB 视频 ~5MB — v4l2-ctl + libdvbv5"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_V4L_UTILS"             "v4l-utils 3.8MB"
disable_option "BR2_PACKAGE_LIBV4L"                "libv4l"
disable_option "BR2_PACKAGE_V4L_UTILS_COMPLIANCE"  "v4l2-compliance"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【3】OpenSSH → dropbear ~4MB"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_OPENSSH"               "openssh 4MB→dropbear 0.2MB"
enable_option  "BR2_PACKAGE_DROPBEAR"              "dropbear 轻量SSH"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【4】ADB ~2.9MB"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_ANDROID_ADBD"          "adbd"
disable_option "BR2_PACKAGE_RKSCRIPT_USB_ADBD"     "rkscript usb adbd"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【5】Rockchip 多媒体残留 ~1.3MB"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_ROCKIT"                "rockit/rkdemuxer/rkmuxer"
disable_option "BR2_PACKAGE_ROCKCHIP_RGA"          "rockchip-rga"
disable_option "BR2_PACKAGE_ROCKCHIP_MPP"          "rockchip-mpp"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【6】irqbalance 1.2MB"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_IRQBALANCE"            "irqbalance"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【7】libdrm + 测试工具 ~1.1MB (modetest/kmsgrab)"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_LIBDRM"                "libdrm"
disable_option "BR2_PACKAGE_LIBDRM_INSTALL_TESTS"  "modetest+kmsgrab"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【8】bash 0.9MB (用 busybox ash)"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_BASH"                  "bash"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【9】spandsp 0.7MB (电话DSP库, 不需要)"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_SPANDSP"               "spandsp"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【10】inotify-tools 0.6MB"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_INOTIFY_TOOLS"         "inotify-tools"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【11】input-event-daemon 0.4MB"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_INPUT_EVENT_DAEMON"    "input-event-daemon"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【12】stressapptest 0.3MB"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_STRESSAPPTEST"         "stressapptest"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【13】iperf/iperf3 0.4MB (网络测试, 发布版去掉)"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_IPERF"                 "iperf"
disable_option "BR2_PACKAGE_IPERF3"                "iperf3"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【14】libtiff 0.5MB"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_TIFF"                  "libtiff"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【15】parted 0.4MB (分区工具)"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_PARTED"                "parted"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【16】libjpeg-turbo 0.3MB (如果不需要图片)"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_JPEG_TURBO"            "libjpeg-turbo"
disable_option "BR2_PACKAGE_LIBJPEG"               "libjpeg"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "【17】Qt5Test 0.3MB (测试模块, 发布不需要)"
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disable_option "BR2_PACKAGE_QT5BASE_TEST"          "Qt5Test"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ""
echo "================================================"
echo "  同时创建 post-build 清理规则"
echo "================================================"

# 找到 post-build.sh 或创建一个
POST_BUILD=""
for f in \
    "device/rockchip/rk3506/post-build.sh" \
    "buildroot/board/rockchip/rk3506/post-build.sh" \
    "device/rockchip/common/post-build.sh" \
    "buildroot/board/rockchip/common/post-build.sh"; do
    if [ -f "$f" ]; then
        POST_BUILD="$f"
        break
    fi
done

CLEANUP_MARKER="# === RK3506 GATEWAY CLEANUP ==="

if [ -n "$POST_BUILD" ]; then
    if ! grep -q "$CLEANUP_MARKER" "$POST_BUILD" 2>/dev/null; then
        cat >> "$POST_BUILD" << 'CLEANUP_EOF'

# === RK3506 GATEWAY CLEANUP ===
# 删除 udev hwdb (9.3MB)
rm -f ${TARGET_DIR}/etc/udev/hwdb.bin

# 删除 /info (System.map 1.4MB)
rm -rf ${TARGET_DIR}/info

# 清理 zoneinfo, 仅保留 Asia/Shanghai (节省 2.7MB)
if [ -d ${TARGET_DIR}/usr/share/zoneinfo ]; then
    TMPZONE=$(mktemp -d)
    mkdir -p ${TMPZONE}/Asia
    cp ${TARGET_DIR}/usr/share/zoneinfo/Asia/Shanghai ${TMPZONE}/Asia/ 2>/dev/null || true
    cp ${TARGET_DIR}/usr/share/zoneinfo/UTC ${TMPZONE}/ 2>/dev/null || true
    rm -rf ${TARGET_DIR}/usr/share/zoneinfo
    mv ${TMPZONE} ${TARGET_DIR}/usr/share/zoneinfo
fi

# 删除 bash-completion
rm -rf ${TARGET_DIR}/usr/share/bash-completion

# 删除 ssh moduli (0.6MB)
rm -f ${TARGET_DIR}/etc/ssh/moduli

# 删除 man
rm -rf ${TARGET_DIR}/usr/share/man

# 删除 pkgconfig
rm -rf ${TARGET_DIR}/usr/lib/pkgconfig

# 删除 include
rm -rf ${TARGET_DIR}/usr/include

# 删除静态库 (.a 文件)
find ${TARGET_DIR}/usr/lib -name "*.a" -delete 2>/dev/null || true

# 删除 .la 文件
find ${TARGET_DIR} -name "*.la" -delete 2>/dev/null || true
# === END GATEWAY CLEANUP ===
CLEANUP_EOF
        echo "  已添加清理规则到: $POST_BUILD"
    else
        echo "  清理规则已存在: $POST_BUILD"
    fi
else
    echo "  未找到 post-build.sh, 请手动在编译后清理"
    echo "  或在 defconfig 中设置 BR2_ROOTFS_POST_BUILD_SCRIPT 指向一个清理脚本"
fi

echo ""
echo "================================================"
echo "  第二轮修改完成!"
echo ""
echo "  预计从 38MB → 20~25MB"
echo ""
echo "  接下来执行:"
echo "  cd buildroot/output/rockchip_hd_rk3506b_iot_nand"
echo "  make clean"
echo "  cd ../../.."
echo "  ./build.sh buildroot"
echo "================================================"
