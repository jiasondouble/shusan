#!/bin/bash
# ============================================================
# RK3506 网关裁剪 — Rootfs 发布前清理脚本
#
# 使用方法:
#   ./rootfs_cleanup.sh /path/to/rootfs
#
# 在 Buildroot 编译完成后，对 output/target/ 执行清理
# ============================================================

set -e

ROOTFS="${1:?用法: $0 /path/to/rootfs}"

if [ ! -d "$ROOTFS" ]; then
    echo "错误: 目录不存在: $ROOTFS"
    exit 1
fi

echo "========================================="
echo "清理前 rootfs 大小:"
du -sh "$ROOTFS"
echo "========================================="

# ──────────────────────────────────────
# [1] 删除文档
# ──────────────────────────────────────
echo "[1/10] 删除文档..."
rm -rf "$ROOTFS"/usr/share/doc
rm -rf "$ROOTFS"/usr/share/man
rm -rf "$ROOTFS"/usr/share/info
rm -rf "$ROOTFS"/usr/share/gtk-doc
rm -rf "$ROOTFS"/usr/share/help
rm -rf "$ROOTFS"/usr/share/readme
rm -rf "$ROOTFS"/usr/share/licenses

# ──────────────────────────────────────
# [2] 删除头文件 (运行时不需要)
# ──────────────────────────────────────
echo "[2/10] 删除头文件..."
rm -rf "$ROOTFS"/usr/include
rm -rf "$ROOTFS"/usr/lib/pkgconfig
rm -rf "$ROOTFS"/usr/lib/cmake
rm -rf "$ROOTFS"/usr/share/pkgconfig
rm -rf "$ROOTFS"/usr/share/aclocal
rm -rf "$ROOTFS"/usr/share/cmake

# ──────────────────────────────────────
# [3] 删除多余的 locale (仅保留 zh_CN 和 en_US)
# ──────────────────────────────────────
echo "[3/10] 清理 locale..."
if [ -d "$ROOTFS/usr/share/locale" ]; then
    cd "$ROOTFS/usr/share/locale"
    for dir in */; do
        case "$dir" in
            zh_CN/|en_US/|en/) ;;
            *) rm -rf "$dir" ;;
        esac
    done
    cd -
fi

# ──────────────────────────────────────
# [4] 清理时区 (仅保留 Asia/Shanghai)
# ──────────────────────────────────────
echo "[4/10] 清理时区..."
if [ -d "$ROOTFS/usr/share/zoneinfo" ]; then
    TMPZONE=$(mktemp -d)
    if [ -f "$ROOTFS/usr/share/zoneinfo/Asia/Shanghai" ]; then
        mkdir -p "$TMPZONE/Asia"
        cp "$ROOTFS/usr/share/zoneinfo/Asia/Shanghai" "$TMPZONE/Asia/"
    fi
    if [ -f "$ROOTFS/usr/share/zoneinfo/UTC" ]; then
        cp "$ROOTFS/usr/share/zoneinfo/UTC" "$TMPZONE/"
    fi
    rm -rf "$ROOTFS/usr/share/zoneinfo"
    mv "$TMPZONE" "$ROOTFS/usr/share/zoneinfo"
fi

# ──────────────────────────────────────
# [5] 删除不需要的字体 (保留基础字体)
# ──────────────────────────────────────
echo "[5/10] 清理字体..."
# 如果不需要任何字体显示 (纯后台):
# rm -rf "$ROOTFS"/usr/share/fonts
# 如果有屏幕, 只保留一个中文字体:
if [ -d "$ROOTFS/usr/share/fonts" ]; then
    find "$ROOTFS/usr/share/fonts" -name "*.ttf" -o -name "*.otf" | while read f; do
        base=$(basename "$f")
        case "$base" in
            DroidSansFallback*|wqy*|NotoSansCJK*|simhei*|msyh*) ;;
            *) rm -f "$f" ;;
        esac
    done
fi

# ──────────────────────────────────────
# [6] 删除 Qt 不需要的文件
# ──────────────────────────────────────
echo "[6/10] 清理 Qt 多余文件..."
rm -rf "$ROOTFS"/usr/lib/qt/examples
rm -rf "$ROOTFS"/usr/lib/qt/tests
rm -rf "$ROOTFS"/usr/lib/qt/doc
rm -rf "$ROOTFS"/usr/share/qt5/examples
rm -rf "$ROOTFS"/usr/share/qt5/doc
rm -rf "$ROOTFS"/usr/lib/qt5/examples
rm -rf "$ROOTFS"/usr/lib/qt5/doc
rm -rf "$ROOTFS"/usr/lib/qt/mkspecs
rm -rf "$ROOTFS"/usr/lib/qt5/mkspecs
rm -rf "$ROOTFS"/usr/lib/qt/qml          # 如不用 QML
rm -rf "$ROOTFS"/usr/lib/qt5/qml         # 如不用 QML
rm -rf "$ROOTFS"/usr/lib/qt/plugins/designer
rm -rf "$ROOTFS"/usr/lib/qt5/plugins/designer
rm -rf "$ROOTFS"/usr/lib/qt/translations
rm -rf "$ROOTFS"/usr/lib/qt5/translations

# 删除不需要的 Qt 插件
rm -rf "$ROOTFS"/usr/lib/qt/plugins/audio
rm -rf "$ROOTFS"/usr/lib/qt/plugins/mediaservice
rm -rf "$ROOTFS"/usr/lib/qt/plugins/playlistformats
rm -rf "$ROOTFS"/usr/lib/qt/plugins/multimedia
rm -rf "$ROOTFS"/usr/lib/qt/plugins/geoservices
rm -rf "$ROOTFS"/usr/lib/qt/plugins/sensors
rm -rf "$ROOTFS"/usr/lib/qt/plugins/sensorgestures
rm -rf "$ROOTFS"/usr/lib/qt/plugins/position
rm -rf "$ROOTFS"/usr/lib/qt/plugins/printsupport
rm -rf "$ROOTFS"/usr/lib/qt/plugins/bearer        # Qt4 遗留网络
rm -rf "$ROOTFS"/usr/lib/qt/plugins/wayland-*
rm -rf "$ROOTFS"/usr/lib/qt/plugins/xcbglintegrations

# ──────────────────────────────────────
# [7] 删除静态库
# ──────────────────────────────────────
echo "[7/10] 删除静态库..."
find "$ROOTFS"/usr/lib -name "*.a" -delete 2>/dev/null || true
find "$ROOTFS"/lib -name "*.a" -delete 2>/dev/null || true

# ──────────────────────────────────────
# [8] 删除 .la 文件
# ──────────────────────────────────────
echo "[8/10] 删除 .la 文件..."
find "$ROOTFS" -name "*.la" -delete 2>/dev/null || true

# ──────────────────────────────────────
# [9] Strip 所有二进制和共享库
# ──────────────────────────────────────
echo "[9/10] Strip 二进制文件..."
STRIP=${CROSS_COMPILE:-arm-linux-gnueabihf-}strip

if command -v "$STRIP" &>/dev/null; then
    find "$ROOTFS"/usr/lib -name "*.so*" -exec "$STRIP" --strip-unneeded {} \; 2>/dev/null || true
    find "$ROOTFS"/lib -name "*.so*" -exec "$STRIP" --strip-unneeded {} \; 2>/dev/null || true
    find "$ROOTFS"/usr/bin -type f -exec "$STRIP" --strip-unneeded {} \; 2>/dev/null || true
    find "$ROOTFS"/usr/sbin -type f -exec "$STRIP" --strip-unneeded {} \; 2>/dev/null || true
    find "$ROOTFS"/bin -type f -exec "$STRIP" --strip-unneeded {} \; 2>/dev/null || true
    find "$ROOTFS"/sbin -type f -exec "$STRIP" --strip-unneeded {} \; 2>/dev/null || true
else
    echo "警告: 未找到 $STRIP, 跳过 strip"
fi

# ──────────────────────────────────────
# [10] 删除其他杂项
# ──────────────────────────────────────
echo "[10/10] 清理杂项..."
rm -rf "$ROOTFS"/usr/share/bash-completion
rm -rf "$ROOTFS"/usr/share/zsh
rm -rf "$ROOTFS"/usr/share/applications
rm -rf "$ROOTFS"/usr/share/icons
rm -rf "$ROOTFS"/usr/share/pixmaps
rm -rf "$ROOTFS"/usr/share/themes
rm -rf "$ROOTFS"/usr/share/mime
rm -rf "$ROOTFS"/usr/share/sounds
rm -rf "$ROOTFS"/usr/share/wallpapers
rm -rf "$ROOTFS"/usr/share/terminfo     # 保留基础终端可注释此行
rm -rf "$ROOTFS"/usr/share/tabset
rm -rf "$ROOTFS"/usr/share/gdb
rm -rf "$ROOTFS"/usr/share/gir-1.0
rm -rf "$ROOTFS"/usr/share/vala
rm -rf "$ROOTFS"/var/cache/*
rm -rf "$ROOTFS"/tmp/*

echo "========================================="
echo "清理后 rootfs 大小:"
du -sh "$ROOTFS"
echo "========================================="

echo ""
echo "各目录占用:"
du -sh "$ROOTFS"/* 2>/dev/null | sort -rh | head -20
echo ""
echo "Qt 库占用:"
du -sh "$ROOTFS"/usr/lib/libQt5*.so* 2>/dev/null | sort -rh || echo "(无 Qt 库)"
echo ""
echo "最大的 20 个文件:"
find "$ROOTFS" -type f -exec du -h {} \; 2>/dev/null | sort -rh | head -20
