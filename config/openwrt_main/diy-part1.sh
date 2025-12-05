#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt
# Function: Diy script (Before Update feeds, Modify the default IP, hostname, theme, add/remove software packages, etc.)
# Source code repository: https://github.com/openwrt/openwrt / Branch: main
#========================================================================================================================

# Add a feed source
# sed -i '$a src-git lienol https://github.com/Lienol/openwrt-package' feeds.conf.default

# other
# rm -rf package/utils/{ucode,fbtest}

#!/bin/bash
# 必装: Passwall
echo "src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall;packages" >> feeds.conf.default
echo "src-git passwall_luci https://github.com/xiaorouji/openwrt-passwall;luci" >> feeds.conf.default

# 必装: OpenClash
git clone --depth 1 https://github.com/vernesong/OpenClash.git package/luci-app-openclash

# 必装: TurboACC
git clone --depth 1 https://github.com/chenmozhijian/luci-app-turboacc.git package/luci-app-turboacc

# 必装: Tailscale (界面)
git clone --depth 1 https://github.com/asvow/luci-app-tailscale.git package/luci-app-tailscale

# 可选: Argon 主题 (N1 常用主题)
git clone --depth 1 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
