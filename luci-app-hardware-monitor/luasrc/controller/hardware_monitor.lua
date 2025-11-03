module("luci.controller.hardware_monitor", package.seeall)

function index()
    entry({"admin", "status", "hardware_monitor"}, firstchild(), _("Hardware Monitor"), 60).dependent = false
    entry({"admin", "status", "hardware_monitor", "overview"}, template("hardware_monitor/overview"), _("Overview"), 1)
    entry({"admin", "status", "hardware_monitor", "status_data"}, call("get_status_data")).leaf = true
end

function get_status_data()
    local lucihttp = require("luci.http")
    local sys = require("luci.sys")
    
    -- 设置JSON响应头
    lucihttp.prepare_content("application/json")
    
    -- 获取系统负载
    local load_avg = sys.exec("cat /proc/loadavg | awk '{print $1}'")
    load_avg = tonumber(load_avg) or 0
    local cpu_cores = tonumber(sys.exec("nproc 2>/dev/null")) or 1
    local load_percentage = math.floor((load_avg / cpu_cores) * 100 + 0.5)
    
    -- 获取内存使用率
    local memory_usage = sys.exec("free | grep Mem | awk '{printf \"%.0f\", $3/$2 * 100}'")
    memory_usage = tonumber(memory_usage) or 0
    
    -- 获取网络状态
    local has_network = sys.call("ping -c 1 -W 1 223.5.5.5 > /dev/null 2>&1") == 0
    
    -- 防火墙安全检测
    local drop_packets = sys.exec("iptables -L INPUT -nvx 2>/dev/null | grep -E 'DROP|REJECT' | awk '{sum += $1} END {print sum+0}'")
    drop_packets = tonumber(drop_packets) or 0
    
    local port_scan = sys.exec("logread | grep -i 'port.*scan\\|syn.*flood' | wc -l")
    port_scan = tonumber(port_scan) or 0
    
    local abnormal_conn = sys.exec("netstat -an 2>/dev/null | grep -E 'SYN_RECV|FIN_WAIT|TIME_WAIT' | wc -l")
    abnormal_conn = tonumber(abnormal_conn) or 0
    
    -- CPU温度（如果可用）
    local cpu_temp = "N/A"
    local temp_cmd = "cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -1"
    local temp_raw = sys.exec(temp_cmd)
    if temp_raw and tonumber(temp_raw) then
        cpu_temp = string.format("%.1f", tonumber(temp_raw) / 1000)
    end
    
    -- 磁盘使用率
    local disk_usage = sys.exec("df -h / | awk 'NR==2 {print $5}' | sed 's/%//'")
    disk_usage = tonumber(disk_usage) or 0
    
    -- 获取运行时间
    local uptime = sys.exec("cat /proc/uptime | awk '{print $1}'")
    uptime = tonumber(uptime) or 0
    
    -- 构建响应数据
    local response = {
        load_percentage = load_percentage,
        memory_usage = memory_usage,
        has_network = has_network,
        drop_packets = drop_packets,
        port_scan = port_scan,
        abnormal_conn = abnormal_conn,
        cpu_temp = cpu_temp,
        disk_usage = disk_usage,
        uptime = uptime,
        timestamp = os.time()
    }
    
    lucihttp.write_json(response)
end