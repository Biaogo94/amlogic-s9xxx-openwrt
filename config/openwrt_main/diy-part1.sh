#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt
# Function: Diy script (Before Update feeds, Modify the default IP, hostname, theme, add/remove software packages, etc.)
# Source code repository: https://github.com/openwrt/openwrt / Branch: main
#========================================================================================================================

# --- 1. Passwall (直克隆模式，修复 feeds 报错) ---
# 下载依赖
git clone --depth 1 https://github.com/xiaorouji/openwrt-passwall.git -b packages package/passwall_packages
# 下载主程序
git clone --depth 1 https://github.com/xiaorouji/openwrt-passwall.git -b luci package/passwall_luci

# --- 2. OpenClash ---
git clone --depth 1 https://github.com/vernesong/OpenClash.git package/luci-app-openclash

# --- 3. Turbo ACC 网络加速 ---
git clone --depth 1 https://github.com/chenmozhijian/luci-app-turboacc.git package/luci-app-turboacc

# --- 4. Tailscale (界面) ---
git clone --depth 1 https://github.com/asvow/luci-app-tailscale.git package/luci-app-tailscale

# --- 5. 确保 ZeroTier 存在 (官方源通常已有，这里作为保险可不加，或使用直克隆) ---
# git clone --depth 1 https://github.com/mchome/openwrt-vlmcsd.git package/vlmcsd
# git clone --depth 1 https://github.com/rufengsuixing/luci-app-zerotier.git package/luci-app-zerotier

# --- 6. 修正可能存在的重复包 (可选，视情况而定) ---
# rm -rf package/feeds/luci/luci-app-passwall
