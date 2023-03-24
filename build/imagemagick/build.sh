#!/usr/bin/bash
#
# {{{ CDDL HEADER
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
# }}}

# Copyright 2023 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/build.sh

PROG=ImageMagick
VER=7.1.1-4
PKG=ooce/application/imagemagick
SUMMARY="$PROG - Convert, Edit, or Compose Bitmap Images"
DESC="Use $PROG to create, edit, compose, or convert bitmap images. It can "
DESC+="read and write images in a variety of formats (over 200) including "
DESC+="PNG, JPEG, GIF, HEIC, TIFF, DPX, EXR, WebP, Postscript, PDF, and SVG."

OPREFIX=$PREFIX
PREFIX+=/$PROG

reset_configure_opts

SKIP_LICENCES=ImageMagick
SKIP_RTIME_CHECK=1
SKIP_SSP_CHECK=1

BUILD_DEPENDS_IPS="
    library/libxml2
    ooce/library/fontconfig
    ooce/library/freetype2
    ooce/library/libheif
    ooce/library/libjpeg-turbo
    ooce/library/libpng
    ooce/library/pango
    ooce/library/tiff
    ooce/library/libwebp
    ooce/library/libzip
    ooce/application/graphviz
"

XFORM_ARGS="
    -DPREFIX=${PREFIX#/}
    -DOPREFIX=${OPREFIX#/}
    -DPROG=$PROG
    -DPKGROOT=$PROG
"

TESTSUITE_FILTER='^[A-Z#][A-Z ]'

CONFIGURE_OPTS="
    --prefix=$PREFIX
    --sysconfdir=/etc$PREFIX
    --enable-hdri
    --with-modules
    --with-heic
    --disable-static
"

# As of version 7.1.0-34, a "Linux-compatible sendfile()" is detected;
# override thiis.
CONFIGURE_OPTS+=" ac_cv_have_linux_sendfile=no"

CONFIGURE_OPTS[amd64]+=" --bindir=$PREFIX/bin"

CPPFLAGS+=" -I$OPREFIX/libzip/include"
LDFLAGS[i386]+=" -L$OPREFIX/lib -R$OPREFIX/lib"
LDFLAGS[amd64]+=" -L$OPREFIX/lib/amd64 -R$OPREFIX/lib/amd64"

make_isa_stub() {
    pushd $DESTDIR$PREFIX/bin >/dev/null
    logcmd mkdir -p amd64
    logcmd mv *-config amd64/ || logerr "mv -config"
    make_isaexec_stub_arch amd64 $PREFIX/bin
    popd >/dev/null
}

init
prep_build
download_source $PROG $PROG $VER
patch_source
build
strip_install
run_testsuite check
make_isa_stub
VER=${VER//-/.} make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
