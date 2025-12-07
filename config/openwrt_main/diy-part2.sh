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
# Remove existing ccache settings
sed -i '/CONFIG_DEVEL/d' .config
sed -i '/CONFIG_CCACHE/d' .config
# Apply new ccache configuration
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
# 1. Add luci-app-amlogic (N1 必须插件，务必保留！)
rm -rf package/luci-app-amlogic
git clone https://github.com/ophub/luci-app-amlogic.git package/luci-app-amlogic

# 2. Fix Rust Compilation on GitHub Actions (Rust 修复补丁)
# 修复 `llvm.download-ci-llvm` 报错
rust_makefile="feeds/packages/lang/rust/Makefile"
if [ -f "$rust_makefile" ]; then
    echo "Applying Rust CI fix to $rust_makefile..."
    sed -i 's/download-ci-llvm = true/download-ci-llvm = "if-unchanged"/g' "$rust_makefile"
    sed -i 's/download-ci-llvm = "true"/download-ci-llvm = "if-unchanged"/g' "$rust_makefile"
    sed -i 's/^.*download-ci-llvm.*/\t\techo "download-ci-llvm = \\"if-unchanged\\"" >> $(PKG_BUILD_DIR)\/config.toml/' "$rust_makefile"
fi

# 3. Clean up duplicate packages (清理重复包)
# 注意：仅清理我们手动下载了源码的包。
# 官方的 net/tailscale 必须保留，因为我们没手动下载核心，只下载了界面。

rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/packages/net/passwall

rm -rf feeds/luci/applications/luci-app-openclash
rm -rf feeds/packages/net/openclash

# 只删除 feeds 里的 tailscale 界面，保留 net/tailscale 核心！
rm -rf feeds/luci/applications/luci-app-tailscale
# rm -rf feeds/packages/net/tailscale  <-- 这行代码删除了，这是导致报错的元凶

# ------------------------------- Other ends -------------------------------
