安装和配置说明
安装方法：
将整个 luci-app-hardware-monitor 目录放入 OpenWrt 的 package 目录中

运行 make menuconfig 选择 LuCI → Applications → luci-app-hardware-monitor

编译安装包
命令: make package/luci-app-hardware-monitor/compile V=s -j8

特性：
实时监控：CPU负载、内存使用率、网络状态、防火墙状态

自动刷新：每5秒自动更新状态（可配置）

响应式设计：适配桌面和移动设备

安全检测：防火墙活动监控和安全评分

可视化展示：彩色进度条和状态指示器

快速操作：一键访问系统设置和重启功能

兼容性：
支持所有OpenWrt版本（19.07+）

兼容各种硬件架构

支持多种Luci主题

不依赖特定硬件特性

这个插件提供了完整的硬件监控解决方案，具有现代化的用户界面和实时数据更新功能。
