TERMUX_PKG_HOMEPAGE=https://github.com/riscv-collab/riscv-gnu-toolchain
TERMUX_PKG_DESCRIPTION="RISC-V GNU Compiler Toolchain"
TERMUX_PKG_LICENSE="GNU GENERAL PUBLIC LICENSE, Copyright (c) 2016, The Regents of the University of California (Regents)."
TERMUX_PKG_LICENSE_FILE="riscv-gnu-toolchain/LICENSE"
TERMUX_PKG_MAINTAINER="@ZLangJIT"
GCC_MAJOR_VERSION=14
TERMUX_PKG_VERSION=${GCC_MAJOR_VERSION}.2
TERMUX_PKG_SHA256=324d483ff0b714c8ce7819a1b679dd9e4706cf91c6caf7336dc4ac0c1d3bf636
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_SRCURL=git+https://github.com/riscv-collab/riscv-gnu-toolchain
TERMUX_PKG_GIT_BRANCH=master
TERMUX_PKG_HOSTBUILD=true
# TERMUX_PKG_RM_AFTER_INSTALL=""
# TERMUX_PKG_DEPENDS=""
# TERMUX_PKG_BUILD_DEPENDS=""
# TERMUX_PKG_CONFLICTS=""
# TERMUX_PKG_BREAKS=""
# TERMUX_PKG_REPLACES=""
TERMUX_PKG_GROUPS="base-devel"
# TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
# -DANDROID_PLATFORM_LEVEL=$TERMUX_PKG_API_LEVEL
# --prefix=$(dirname $TERMUX_PREFIX/)
# "
TERMUX_PKG_HAS_DEBUG=false
# termux_step_post_get_source() {
# 	git fetch --unshallow
# 	git checkout master
# }

# termux_step_configure() {
# 	./configure --prefix=$TERMUX_PREFIX/
# }

# termux_step_make() {
# 	make -j1
# }

# termux_step_make_install() {
# 	make install
# }
