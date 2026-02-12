#!/bin/sh
# ============================================================
# RK3506 rootfs 空间诊断脚本
# 直接在开发板上运行: sh diagnose_rootfs.sh
# ============================================================

echo "================================================"
echo "  RK3506 Rootfs 空间诊断报告"
echo "================================================"
echo ""

echo "【1】总体磁盘占用"
echo "────────────────────────────────────"
df -h /
echo ""

echo "【2】一级目录占用排序"
echo "────────────────────────────────────"
du -sh /* 2>/dev/null | sort -rh
echo ""

echo "【3】/usr 子目录占用"
echo "────────────────────────────────────"
du -sh /usr/* 2>/dev/null | sort -rh
echo ""

echo "【4】/usr/lib 子目录占用 (通常最大)"
echo "────────────────────────────────────"
du -sh /usr/lib/* 2>/dev/null | sort -rh | head -30
echo ""

echo "【5】/usr/bin 最大的文件"
echo "────────────────────────────────────"
ls -lhS /usr/bin/ 2>/dev/null | head -20
echo ""

echo "【6】/usr/sbin 最大的文件"
echo "────────────────────────────────────"
ls -lhS /usr/sbin/ 2>/dev/null | head -20
echo ""

echo "【7】/usr/share 子目录占用"
echo "────────────────────────────────────"
du -sh /usr/share/* 2>/dev/null | sort -rh | head -20
echo ""

echo "【8】Qt 库占用明细"
echo "────────────────────────────────────"
ls -lhS /usr/lib/libQt5*.so* 2>/dev/null || echo "(未找到 Qt 库)"
echo ""
echo "Qt 插件目录:"
du -sh /usr/lib/qt5/plugins/* 2>/dev/null || \
du -sh /usr/lib/qt/plugins/* 2>/dev/null || echo "(未找到 Qt 插件)"
echo ""
echo "Qt QML 目录:"
du -sh /usr/lib/qt5/qml 2>/dev/null || \
du -sh /usr/lib/qt/qml 2>/dev/null || echo "(无 QML)"
echo ""

echo "【9】GPU/Mali 库"
echo "────────────────────────────────────"
ls -lh /usr/lib/libmali* 2>/dev/null || echo "(无 Mali 库)"
ls -lh /usr/lib/libMali* 2>/dev/null || echo "(无 Mali 库)"
ls -lh /usr/lib/libGLES* 2>/dev/null || echo "(无 GLES 库)"
ls -lh /usr/lib/libEGL* 2>/dev/null || echo "(无 EGL 库)"
ls -lh /usr/lib/libwayland* 2>/dev/null || echo "(无 Wayland 库)"
ls -lh /usr/lib/libdrm* 2>/dev/null || echo "(无 DRM 库)"
echo ""

echo "【10】音频相关库"
echo "────────────────────────────────────"
ls -lh /usr/lib/libasound* 2>/dev/null || echo "(无 ALSA 库)"
ls -lh /usr/lib/libpulse* 2>/dev/null || echo "(无 PulseAudio 库)"
ls -lh /usr/lib/alsa-lib/ 2>/dev/null || echo "(无 ALSA 插件)"
du -sh /usr/share/alsa 2>/dev/null || echo "(无 ALSA 配置)"
echo ""

echo "【11】蓝牙相关"
echo "────────────────────────────────────"
ls -lh /usr/lib/libbluetooth* 2>/dev/null || echo "(无蓝牙库)"
ls -lh /usr/bin/bluetooth* 2>/dev/null || echo "(无蓝牙工具)"
ls -lh /usr/libexec/bluetooth/ 2>/dev/null || echo "(无蓝牙服务)"
du -sh /etc/bluetooth 2>/dev/null || echo "(无蓝牙配置)"
echo ""

echo "【12】WiFi 相关"
echo "────────────────────────────────────"
ls -lh /usr/sbin/wpa_supplicant 2>/dev/null || echo "(无 wpa_supplicant)"
ls -lh /usr/sbin/hostapd 2>/dev/null || echo "(无 hostapd)"
ls -lh /usr/sbin/iw 2>/dev/null || echo "(无 iw)"
du -sh /lib/firmware 2>/dev/null || echo "(无 firmware)"
ls -lh /lib/firmware/ 2>/dev/null | head -20
echo ""

echo "【13】多媒体相关"
echo "────────────────────────────────────"
ls -lh /usr/lib/libgstreamer* 2>/dev/null || echo "(无 GStreamer)"
ls -lh /usr/lib/libavcodec* 2>/dev/null || echo "(无 FFmpeg)"
ls -lh /usr/lib/librockchip_mpp* 2>/dev/null || echo "(无 MPP)"
ls -lh /usr/lib/librga* 2>/dev/null || echo "(无 RGA)"
echo ""

echo "【14】Python/脚本语言"
echo "────────────────────────────────────"
du -sh /usr/lib/python* 2>/dev/null || echo "(无 Python)"
du -sh /usr/lib/node_modules 2>/dev/null || echo "(无 NodeJS)"
ls -lh /usr/bin/python* 2>/dev/null || echo "(无 python)"
ls -lh /usr/bin/lua* 2>/dev/null || echo "(无 lua)"
echo ""

echo "【15】ICU 国际化库 (巨大!)"
echo "────────────────────────────────────"
ls -lhS /usr/lib/libicu*.so* 2>/dev/null || echo "(无 ICU 库 — 好!)"
echo ""

echo "【16】字体文件"
echo "────────────────────────────────────"
du -sh /usr/share/fonts 2>/dev/null || echo "(无字体目录)"
find /usr/share/fonts -name "*.ttf" -o -name "*.otf" 2>/dev/null | while read f; do
    ls -lh "$f"
done
echo ""

echo "【17】文档/locale/man"
echo "────────────────────────────────────"
du -sh /usr/share/doc 2>/dev/null || echo "(无 doc)"
du -sh /usr/share/man 2>/dev/null || echo "(无 man)"
du -sh /usr/share/info 2>/dev/null || echo "(无 info)"
du -sh /usr/share/locale 2>/dev/null || echo "(无 locale)"
du -sh /usr/share/zoneinfo 2>/dev/null || echo "(无 zoneinfo)"
du -sh /usr/share/terminfo 2>/dev/null || echo "(无 terminfo)"
echo ""

echo "【18】头文件/开发文件 (运行时不需要)"
echo "────────────────────────────────────"
du -sh /usr/include 2>/dev/null || echo "(无头文件 — 好!)"
du -sh /usr/lib/pkgconfig 2>/dev/null || echo "(无 pkgconfig)"
du -sh /usr/lib/cmake 2>/dev/null || echo "(无 cmake)"
echo ""

echo "【19】内核模块"
echo "────────────────────────────────────"
du -sh /lib/modules 2>/dev/null || echo "(无内核模块)"
ls /lib/modules/ 2>/dev/null
echo ""

echo "【20】全系统最大的 30 个文件"
echo "────────────────────────────────────"
find / -xdev -type f -exec ls -lh {} \; 2>/dev/null | awk '{print $5, $NF}' | sort -rh | head -30
echo ""

echo "================================================"
echo "  诊断完成"
echo "================================================"
