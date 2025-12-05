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
# ... (保留原有的注释)

# 1. 添加 Passwall 源 (依赖和本体)
echo "src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall;packages" >> feeds.conf.default
echo "src-git passwall_luci https://github.com/xiaorouji/openwrt-passwall;luci" >> feeds.conf.default

# 2. 添加 OpenClash (直接克隆源码到 package 目录)
git clone --depth 1 https://github.com/vernesong/OpenClash.git package/luci-app-openclash

# 3. 添加 Turbo ACC 网络加速
git clone --depth 1 https://github.com/chenmozhijian/luci-app-turboacc.git package/luci-app-turboacc

# 4. 添加 Tailscale 界面 (官方源通常只有核心 core，没有界面)
git clone --depth 1 https://github.com/asvow/luci-app-tailscale.git package/luci-app-tailscale

# 5. 确保 ZeroTier 存在 (官方源通常已有，但为了保险可以添加一个常用库，或者直接依赖官方 feed)
# 官方 OpenWrt feed 通常包含 luci-app-zerotier，无需额外添加

# 6. 晶晨盒子插件 (luci-app-amlogic)
# 注意：你的 diy-part2.sh 中已经包含了 luci-app-amlogic 的下载命令，这里不用重复。
