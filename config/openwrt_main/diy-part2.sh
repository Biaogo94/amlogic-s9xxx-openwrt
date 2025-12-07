#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt
# Function: Diy script (After Update feeds, Modify the default IP, hostname, theme, add/remove software packages, etc.)
# Source code repository: https://github.com/openwrt/openwrt / Branch: main
#========================================================================================================================

# ------------------------------- Main source started -------------------------------
#
# Set default IP address
default_ip="192.168.1.1"
ip_regex="^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
# Modify default IP if an argument is provided and it matches the IP format
[[ -n "${1}" && "${1}" != "${default_ip}" && "${1}" =~ ${ip_regex} ]] && {
    echo "Modify default IP address to: ${1}"
    sed -i "/lan) ipad=\${ipaddr:-/s/\${ipaddr:-\"[^\"]*\"}/\${ipaddr:-\"${1}\"}/" package/base-files/*/bin/config_generate
}

# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow

# Set etc/openwrt_release
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d) for N1'|g" package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCEREPO='github.com/openwrt/openwrt'" >>package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCECODE='openwrt'" >>package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCEBRANCH='main'" >>package/base-files/files/etc/openwrt_release

# Set ccache
sed -i '/CONFIG_DEVEL/d' .config
sed -i '/CONFIG_CCACHE/d' .config
if [[ "${2}" == "true" ]]; then
    echo "CONFIG_DEVEL=y" >>.config
    echo "CONFIG_CCACHE=y" >>.config
    echo 'CONFIG_CCACHE_DIR="$(TOPDIR)/.ccache"' >>.config
else
    echo '# CONFIG_DEVEL is not set' >>.config
    echo "# CONFIG_CCACHE is not set" >>.config
    echo 'CONFIG_CCACHE_DIR=""' >>.config
fi
#
# ------------------------------- Main source ends -------------------------------

# ------------------------------- Other started -------------------------------
#
# 1. Add luci-app-amlogic (N1 核心插件)
rm -rf package/luci-app-amlogic
git clone https://github.com/ophub/luci-app-amlogic.git package/luci-app-amlogic

# 2. Fix Rust Compilation on GitHub Actions (Rust 编译修复)
rust_makefile="feeds/packages/lang/rust/Makefile"
if [ -f "$rust_makefile" ]; then
    echo "Applying Rust CI fix to $rust_makefile..."
    sed -i 's/download-ci-llvm = true/download-ci-llvm = "if-unchanged"/g' "$rust_makefile"
    sed -i 's/download-ci-llvm = "true"/download-ci-llvm = "if-unchanged"/g' "$rust_makefile"
    sed -i 's/^.*download-ci-llvm.*/\t\techo "download-ci-llvm = \\"if-unchanged\\"" >> $(PKG_BUILD_DIR)\/config.toml/' "$rust_makefile"
fi

# 3. Clean up duplicate packages (清理手动下载的插件冲突)
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/packages/net/passwall
rm -rf feeds/luci/applications/luci-app-openclash
rm -rf feeds/packages/net/openclash
rm -rf feeds/luci/applications/luci-app-tailscale
# 注意：不要删除 feeds/packages/net/tailscale (核心包)

# 4. Fix Tailscale File Conflict (修复 Tailscale 文件冲突)
# 删除官方包 Makefile 中安装 init.d 和 config 文件的命令，把位置让给 luci-app-tailscale
ts_makefile="feeds/packages/net/tailscale/Makefile"
if [ -f "$ts_makefile" ]; then
    echo "Fixing Tailscale file conflict in $ts_makefile..."
    # 删除包含 /etc/init.d/tailscale 的行
    sed -i '/\/etc\/init.d\/tailscale/d' "$ts_makefile"
    # 删除包含 /etc/config/tailscale 的行
    sed -i '/\/etc\/config\/tailscale/d' "$ts_makefile"
fi

# ------------------------------- Other ends -------------------------------
