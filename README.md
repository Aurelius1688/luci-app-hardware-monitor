<img width="1642" height="784" alt="image" src="https://github.com/user-attachments/assets/2db8f403-6430-48a5-a8e9-f445f8970350" />


# LuCI 硬件监控插件 - 开源文档

## 📋 项目概述

**luci-app-hardware-monitor** 是一个为 OpenWrt 系统设计的全平台硬件监控插件，提供实时的系统状态监控和美观的用户界面。

### ✨ 功能特性
- 🖥️ 实时 CPU 负载监控
- 💾 内存使用率监控  
- 🌐 网络连接状态检测
- 🛡️ 防火墙安全状态监控
- 🎨 现代化暗色主题界面
- 🔄 5秒自动刷新
- 📱 响应式设计

## 🗂️ 项目结构

```
luci-app-hardware-monitor/
├── Makefile                          # 编译配置文件
├── luasrc/
│   ├── controller/
│   │   └── hardware_monitor.lua      # 控制器逻辑
│   ├── model/
│   │   └── cbi/
│   │       └── hardware_monitor/
│   │           └── overview.lua      # 配置页面模型
│   └── view/
│       └── hardware_monitor/
│           ├── overview.htm          # 主监控界面
│           └── status_data.htm       # JSON数据接口
└── root/
    └── www/
        └── cgi-bin/
            └── luci-static/
                └── hardware_monitor/
                    └── style.css     # 样式文件(可选)
```

## 🛠️ 安装和编译指南

### 环境要求
- OpenWrt 19.07 或更高版本
- 支持所有硬件架构 (x86, ARM, MIPS等)

### 方法一：源码集成编译

**下载对应的 SDK**

- 访问 [https://downloads.openwrt.org/releases/](https://downloads.openwrt.org/releases/)你的版本/targets/你的平台/
- 例如，对于 `24.10.4` 和 `x86_64`，下载：
  `immortalwrt-sdk-24.10.4-x86-generic_gcc-13.3.0_musl.Linux-x86_64.tar.zst`
- 解压命令:`tar --zstd -xf immortalwrt-sdk-24.10.4-x86-generic_gcc-13.3.0_musl.Linux-x86_64.tar.zst`
- 将其下载到你的 Linux 开发机。

**安装开发机依赖**
bash

```
sudo apt update
sudo apt install build-essential ccache file gawk gettext git libncurses5-dev libssl-dev python3 python3-setuptools rsync unzip wget
```

**配置编译选项**
```bash
cd immortalwrt-sdk-24.10.4-x86-generic_gcc-13.3.0_musl.Linux-x86_64
make menuconfig
```
导航到：
```
LuCI → Applications → luci-app-hardware-monitor
```
选择 `[*]` 编译进固件或 `[M]` 编译为模块

3. **编译插件**
```bash
# 单独编译插件
make package/luci-app-hardware-monitor/compile V=s

# 或编译整个固件
make V=s
```

4. **安装到路由器**
```bash
# 找到生成的IPK文件
find bin -name "luci-app-hardware-monitor*.ipk" -type f

# 上传并安装
scp luci-app-hardware-monitor_1.1-1_all.ipk root@192.168.1.1:/tmp/
ssh root@192.168.1.1 "opkg install /tmp/luci-app-hardware-monitor_1.1-1_all.ipk"
ssh root@192.168.1.1 "/etc/init.d/uhttpd restart"
```

### 方法二：手动安装（已有OpenWrt系统）

1. **下载预编译IPK**
```bash
wget https://github.com/Aurelius1688/luci-app-hardware-monitor/releases/download/ZIP/luci-app-hardware-monitor_1.1-r1_all.ipk
```

2. **安装依赖**
```bash
opkg update
opkg install luci-compat iptables netstat-nat
```

3. **安装插件**
```bash
opkg install luci-app-hardware-monitor_1.1-r1_all.ipk
/etc/init.d/uhttpd restart
```

## 🔧 配置文件说明

### Makefile 配置
```makefile
include $(TOPDIR)/rules.mk

LUCI_TITLE:=Hardware Monitor - 系统硬件监控
LUCI_DEPENDS:=+luci-compat +luci-lib-ipkg +iptables +netstat-nat

PKG_NAME:=luci-app-hardware-monitor
PKG_VERSION:=1.1
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=Hardware Monitor for OpenWrt
  PKGARCH:=all
endef
```

### 控制器 (hardware_monitor.lua)
```lua
module("luci.controller.hardware_monitor", package.seeall)

function index()
    entry({"admin", "status", "hardware_monitor"}, firstchild(), _("Hardware Monitor"), 60)
    entry({"admin", "status", "hardware_monitor", "overview"}, template("hardware_monitor/overview"), _("Overview"), 1)
    entry({"admin", "status", "hardware_monitor", "status_data"}, call("get_status_data")).leaf = true
end
```

## 🎯 使用指南

### 访问插件
1. 登录 LuCI Web 界面
2. 导航到：**状态 → Hardware Monitor → Overview**
3. 或直接访问：`http://192.168.1.1/cgi-bin/luci/admin/status/hardware_monitor/overview`

### 监控指标说明

#### 网络状态
- **监控项**: 互联网连接状态
- **检测方式**: Ping 223.5.5.5 (阿里云DNS)

#### 安全状态
- **评分规则** (3分制，分数越低越安全):
  - 0分 🟢 优秀: 所有指标正常
  - 1分 🟡 良好: 1个指标异常  
  - 2分 🔴 需关注: 2个指标异常
  - 3分 🔴 危险: 3个指标异常

- **监控指标**:
  - 丢弃包数量 > 50
  - 端口扫描次数 > 3
  - 异常连接数 > 10

## 🔄 API 接口

### 获取状态数据
**端点**: `/cgi-bin/luci/admin/status/hardware_monitor/status_data`

**响应格式** (JSON):
```json
{
  "load_percentage": 15,
  "memory_usage": 42,
  "has_network": true,
  "drop_packets": 12,
  "port_scan": 0,
  "abnormal_conn": 3,
  "timestamp": 1634567890
}
```

## 🐛 故障排除

### 常见问题

1. **插件未显示在菜单中**
   ```bash
   # 清理缓存
   rm -rf /tmp/luci-*
   /etc/init.d/uhttpd restart
   ```

2. **编译错误**
   - 确保在 `make menuconfig` 中正确选择插件
   - 检查依赖包是否可用

3. **界面显示异常**
   - 强制刷新浏览器缓存 (Ctrl+F5)
   - 检查 JavaScript 控制台错误信息

4. **数据不更新**
   - 检查网络连接
   - 验证 `/proc` 文件系统权限

### 日志查看
```bash
# 查看系统日志
logread | grep hardware

# 查看LuCI错误
tail -f /tmp/luci-indexcache
```

## 🤝 贡献指南

### 报告问题
1. 在 GitHub Issues 中描述问题
2. 提供 OpenWrt 版本和硬件信息
3. 包含相关日志和截图

### 提交代码
1. Fork 项目仓库
2. 创建功能分支
3. 提交清晰的 commit 信息
4. 发起 Pull Request

### 开发环境设置
```bash
# 1. 获取 OpenWrt SDK
wget https://downloads.openwrt.org/releases/21.02.0/targets/x86/64/openwrt-sdk-21.02.0-x86-64_gcc-8.4.0_musl.Linux-x86_64.tar.xz

# 2. 解压并设置环境
tar xf openwrt-sdk-*.tar.xz
cd openwrt-sdk-*

# 3. 克隆插件源码
git clone https://github.comAurelius1688/luci-app-hardware-monitor.git package/luci-app-hardware-monitor

# 4. 编译
make package/luci-app-hardware-monitor/compile V=s
```

## 📄 许可证

本项目采用 MIT 许可证：
```text
MIT License

Copyright (c) 2025 luci-app-hardware-monitor

Permission is hereby granted...
```

## 🙏 致谢

感谢 OpenWrt 社区和所有贡献者！

## 📞 支持与联系

- **项目主页**: https://github.com/Aurelius1688/luci-app-hardware-monitor/
- **问题反馈**: https://github.com/Aurelius1688/luci-app-hardware-monitor/issues
- **文档**: https://github.com/aurelius/luci-app-hardware-monitor/README.md
---

*让 OpenWrt 硬件监控变得更简单！* 🚀一个简单的硬件监控解决方案，具有现代化的用户界面和实时数据更新功能。
