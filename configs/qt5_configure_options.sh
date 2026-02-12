#!/bin/bash
# ============================================================
# RK3506 网关裁剪 — Qt5 手动编译时的 configure 选项
# 如果使用 Buildroot 编译 Qt，则不需要此脚本
# ============================================================

# 交叉编译器前缀（根据实际修改）
CROSS_COMPILE=arm-linux-gnueabihf-
SYSROOT=/opt/rk3506-sysroot

./configure \
    -prefix /usr \
    -extprefix ${SYSROOT}/usr \
    -hostprefix /opt/qt5-host-tools \
    \
    -release \
    -strip \
    -optimize-size \
    -ltcg \
    -silent \
    -opensource \
    -confirm-license \
    \
    -platform linux-g++ \
    -xplatform linux-arm-gnueabihf-g++ \
    -sysroot ${SYSROOT} \
    \
    `# ======== 图形后端 ========` \
    -linuxfb \
    -no-opengl \
    -no-opengles2 \
    -no-opengles3 \
    -no-openvg \
    -no-eglfs \
    -no-gbm \
    -no-kms \
    -no-xcb \
    -no-xcb-xlib \
    -no-directfb \
    -no-mirclient \
    \
    `# ======== 关闭不需要的特性 ========` \
    -no-cups \
    -no-icu \
    -no-iconv \
    -no-harfbuzz \
    -no-gtk \
    -no-glib \
    -no-dbus \
    -no-journald \
    -no-syslog \
    \
    `# ======== 关闭不需要的图片格式 (按需保留) ========` \
    -no-gif \
    -no-libjpeg \
    `# -qt-libpng          # 如果UI需要PNG则保留` \
    -no-libpng \
    \
    `# ======== 字体 ========` \
    -qt-freetype \
    -no-fontconfig \
    \
    `# ======== SSL ========` \
    `# 如需HTTPS通信则保留:` \
    `# -openssl-linked` \
    -no-openssl \
    \
    `# ======== 数据库 ========` \
    -sql-sqlite \
    -no-sql-mysql \
    -no-sql-psql \
    -no-sql-odbc \
    -no-sql-oci \
    -no-sql-tds \
    -no-sql-db2 \
    -no-sql-ibase \
    \
    `# ======== 关闭不需要的 feature (细粒度) ========` \
    -no-feature-movie \
    -no-feature-printer \
    -no-feature-printpreviewwidget \
    -no-feature-printpreviewdialog \
    -no-feature-printdialog \
    -no-feature-pdf \
    -no-feature-whatsthis \
    -no-feature-wizard \
    -no-feature-calendarwidget \
    -no-feature-colordialog \
    -no-feature-fontdialog \
    -no-feature-lcdnumber \
    -no-feature-syntaxhighlighter \
    -no-feature-undoview \
    -no-feature-mdiarea \
    -no-feature-graphicseffect \
    -no-feature-textodfwriter \
    -no-feature-textmarkdownreader \
    -no-feature-textmarkdownwriter \
    -no-feature-cssparser \
    -no-feature-texthtmlparser \
    -no-feature-dom \
    -no-feature-xml \
    `# -no-feature-animation     # 如果 UI 不需要动画` \
    `# -no-feature-statemachine  # 如果不用状态机` \
    \
    `# ======== 不编译示例/测试/工具 ========` \
    -nomake examples \
    -nomake tests \
    -nomake tools \
    \
    `# ======== 跳过不需要的 Qt 子模块 ========` \
    -skip qtwebengine \
    -skip qtwebchannel \
    -skip qtwebsockets \
    -skip qtwebview \
    -skip qtmultimedia \
    -skip qtlocation \
    -skip qtsensors \
    -skip qtconnectivity \
    -skip qt3d \
    -skip qtdatavis3d \
    -skip qtcharts \
    -skip qtgamepad \
    -skip qtpurchasing \
    -skip qtscript \
    -skip qtspeech \
    -skip qtvirtualkeyboard \
    -skip qtwayland \
    -skip qtandroidextras \
    -skip qtmacextras \
    -skip qtwinextras \
    -skip qtx11extras \
    -skip qtdoc \
    -skip qtgraphicaleffects \
    -skip qtimageformats \
    -skip qtquickcontrols \
    -skip qtquickcontrols2 \
    -skip qtscxml \
    -skip qtremoteobjects \
    -skip qtnetworkauth \
    -skip qtlottie \
    -skip qtquicktimeline \
    -skip qtquick3d
