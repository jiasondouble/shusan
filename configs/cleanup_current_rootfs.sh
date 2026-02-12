#!/bin/sh
# ============================================================
# RK3506 网关 — 当前 rootfs 立即清理脚本
#
# ★ 这是在开发板上直接执行的临时清理脚本
# ★ 用于验证裁剪效果，正式版应在 Buildroot 中关闭对应的包
#
# 使用: sh cleanup_current_rootfs.sh
# ============================================================

set -e

echo "清理前:"
df -h /
echo ""

# ──────────────────────────────────────
# [1] Python 3.11 — 35.1 MB ← 最大元凶!
# ──────────────────────────────────────
echo "[1] 删除 Python 3.11 ... (节省 ~35 MB)"
rm -rf /usr/lib/python3.11
rm -f  /usr/lib/libpython3.11.so*
rm -f  /usr/bin/python /usr/bin/python3 /usr/bin/python3.11

# ──────────────────────────────────────
# [2] /etc/udev/hwdb.bin — 9.3 MB
# ──────────────────────────────────────
echo "[2] 删除 udev hwdb.bin ... (节省 ~9.3 MB)"
rm -f /etc/udev/hwdb.bin

# ──────────────────────────────────────
# [3] rockchip-test — 8.7 MB (NPU测试模型等)
# ──────────────────────────────────────
echo "[3] 删除 rockchip-test ... (节省 ~8.7 MB)"
rm -rf /rockchip-test

# ──────────────────────────────────────
# [4] V4L2 / DVB 视频工具 — 7.0 MB
# ──────────────────────────────────────
echo "[4] 删除 V4L2/DVB ... (节省 ~7 MB)"
rm -f /usr/bin/v4l2-ctl
rm -f /usr/lib/libdvbv5.a
rm -f /usr/lib/libdvbv5.so*
rm -f /usr/lib/libv4lconvert.a
rm -f /usr/lib/libv4lconvert.so*
rm -f /usr/lib/libv4l2.so*
rm -f /usr/lib/libv4l1.so*

# ──────────────────────────────────────
# [5] GStreamer 多媒体框架 — 4.0 MB
# ──────────────────────────────────────
echo "[5] 删除 GStreamer ... (节省 ~4 MB)"
rm -rf /usr/lib/gstreamer-1.0
rm -f  /usr/lib/libgstreamer-1.0.so*
rm -f  /usr/lib/libgstvideo-1.0.so*
rm -f  /usr/lib/libgstaudio-1.0.so*
rm -f  /usr/lib/libgstbase-1.0.so*
rm -f  /usr/lib/libgstpbutils-1.0.so*
rm -f  /usr/lib/libgsttag-1.0.so*
rm -f  /usr/lib/libgstapp-1.0.so*
rm -f  /usr/lib/libgstriff-1.0.so*
rm -f  /usr/lib/libgstallocators-1.0.so*
rm -rf /usr/share/gstreamer-1.0
rm -rf /usr/share/gst-plugins-base

# ──────────────────────────────────────
# [6] Rockchip 多媒体库 — 2.5 MB
# ──────────────────────────────────────
echo "[6] 删除 Rockchip 多媒体库 ... (节省 ~2.5 MB)"
rm -f /usr/lib/librockit.so*
rm -f /usr/lib/librkdemuxer.so*
rm -f /usr/lib/librkmuxer.so*
rm -f /usr/lib/librga.so*

# ──────────────────────────────────────
# [7] 内核模块 (WiFi/BT驱动) — 5.9 MB
# ──────────────────────────────────────
echo "[7] 删除 WiFi/BT 内核模块 ... (节省 ~5.9 MB)"
rm -rf /usr/lib/modules
# 或只删 WiFi 模块:
# rm -f /usr/lib/modules/*/kernel/drivers/net/wireless -rf
# rm -f /lib/modules/*/kernel/drivers/net/wireless -rf

# ──────────────────────────────────────
# [8] WiFi 工具 + 固件 — 5.6 MB
# ──────────────────────────────────────
echo "[8] 删除 WiFi 工具+固件 ... (节省 ~5.6 MB)"
rm -f  /usr/sbin/wpa_supplicant
rm -f  /usr/sbin/wpa_cli
rm -f  /usr/sbin/hostapd
rm -f  /usr/bin/dhd_priv
rm -rf /lib/firmware/aic8800D80
rm -rf /lib/firmware/aic8800DC
rm -rf /lib/firmware/rtl_bt
rm -rf /lib/firmware/rtlbt

# ──────────────────────────────────────
# [9] 蓝牙全套 — 4.8 MB
# ──────────────────────────────────────
echo "[9] 删除蓝牙 ... (节省 ~4.8 MB)"
rm -f  /usr/bin/bluetoothctl
rm -f  /usr/bin/btmon
rm -f  /usr/bin/hcidump
rm -f  /usr/bin/rtk_hciattach
rm -f  /usr/bin/brcm_patchram_plus1
rm -rf /usr/libexec/bluetooth
rm -f  /usr/lib/libbluetooth.so*
rm -rf /usr/lib/alsa-lib/libasound_module_*bluealsa*
rm -rf /etc/bluetooth
rm -f  /etc/dbus-1/system.d/bluetooth.conf 2>/dev/null

# ──────────────────────────────────────
# [10] 音频 (ALSA) — 3.0 MB
# ──────────────────────────────────────
echo "[10] 删除 ALSA 音频 ... (节省 ~3 MB)"
rm -f  /usr/lib/libasound.so*
rm -rf /usr/lib/alsa-lib
rm -f  /usr/lib/libsamplerate.so*
rm -f  /usr/lib/libspandsp.so*
rm -f  /usr/sbin/alsactl
rm -rf /usr/share/alsa

# ──────────────────────────────────────
# [11] 调试工具 — 7.5 MB
# ──────────────────────────────────────
echo "[11] 删除调试工具 ... (节省 ~7.5 MB)"
rm -f /usr/bin/rg                          # ripgrep 3.6MB
rm -f /usr/bin/adbd                        # ADB 2.9MB
rm -f /usr/bin/modetest                    # DRM测试 0.6MB
rm -f /usr/bin/kmsgrab                     # 0.5MB

# ──────────────────────────────────────
# [12] OpenSSH → 改用 dropbear (节省 ~3MB)
#     如果已经装了 dropbear 就删 openssh
#     如果没有 dropbear, 先跳过此步
# ──────────────────────────────────────
echo "[12] 删除 OpenSSH (如有 dropbear 替代) ... (节省 ~3 MB)"
# 确认 dropbear 存在后再删:
if command -v dropbear >/dev/null 2>&1; then
    rm -f /usr/bin/ssh /usr/bin/ssh-keygen /usr/bin/ssh-keyscan
    rm -f /usr/bin/ssh-add /usr/bin/ssh-agent
    rm -f /usr/sbin/sshd
    rm -f /usr/bin/scp /usr/bin/sftp
    echo "  已删除 OpenSSH (dropbear 可用)"
else
    echo "  跳过: 未找到 dropbear, 保留 OpenSSH"
fi

# ──────────────────────────────────────
# [13] 其他不需要的工具/库 — 5.0 MB
# ──────────────────────────────────────
echo "[13] 删除其他不需要的工具/库 ... (节省 ~5 MB)"
rm -f  /usr/lib/liblvgl.so*               # LVGL图形库 1.1MB
rm -f  /usr/lib/libtiff.so*               # TIFF图片 0.5MB
rm -f  /usr/lib/libdrm.so*                # DRM 0.1MB
rm -f  /usr/sbin/irqbalance               # 1.2MB
rm -f  /usr/bin/bash                       # 用 busybox ash 0.9MB
rm -f  /usr/bin/inotifywait                # 0.6MB
rm -f  /usr/bin/input-event-daemon         # 0.4MB
rm -rf /info                               # System.map 1.9MB

# ──────────────────────────────────────
# [14] GLib (如果没有其他程序依赖)
# ──────────────────────────────────────
echo "[14] 删除 GLib ... (节省 ~2.8 MB)"
# ⚠️ 如果你的程序依赖 glib 则跳过此步!
# rm -f /usr/lib/libglib-2.0.so*
# rm -f /usr/lib/libgio-2.0.so*
# rm -f /usr/lib/libgobject-2.0.so*
# rm -f /usr/lib/libgmodule-2.0.so*
# rm -f /usr/lib/libgthread-2.0.so*
echo "  跳过: 需确认无依赖后手动删除"

# ──────────────────────────────────────
# [15] 清理 zoneinfo (仅保留 Asia/Shanghai)
# ──────────────────────────────────────
echo "[15] 清理 zoneinfo ... (节省 ~2.7 MB)"
if [ -d /usr/share/zoneinfo ]; then
    TMPZONE=$(mktemp -d)
    mkdir -p "$TMPZONE/Asia"
    cp /usr/share/zoneinfo/Asia/Shanghai "$TMPZONE/Asia/" 2>/dev/null
    cp /usr/share/zoneinfo/UTC "$TMPZONE/" 2>/dev/null
    rm -rf /usr/share/zoneinfo
    mv "$TMPZONE" /usr/share/zoneinfo
fi

# ──────────────────────────────────────
# [16] 杂项清理
# ──────────────────────────────────────
echo "[16] 清理杂项..."
rm -rf /usr/share/bash-completion
rm -rf /usr/share/man
rm -rf /usr/include
rm -rf /usr/lib/pkgconfig
rm -rf /usr/share/dbus-1/system-services/org.bluez.service 2>/dev/null

echo ""
echo "================================================"
echo "清理后:"
df -h /
echo ""
echo "各目录占用:"
du -sh /* 2>/dev/null | sort -rh | head -15
echo ""
echo "/usr/lib 最大项:"
du -sh /usr/lib/* 2>/dev/null | sort -rh | head -15
echo "================================================"
