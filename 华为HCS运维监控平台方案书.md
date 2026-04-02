# 华为 HCS 运维监控平台 - 实施方案

## 一、监控目标

对华为 HCS 上发放的 ECS、BMS、RDS、OBS 等资源进行监控，通过 Prometheus + 华为云 CES API 采集数据，Grafana 可视化，飞书告警。

---

## 二、整体架构

```
华为 HCS 资源（ECS/BMS/RDS/OBS）
        ↓ 华为云 CES API
  prometheus-hwc-exporter（自研）
        ↓
    Prometheus Server
        ↓
    AlertManager → 飞书 Webhook
        ↓
      Grafana
```

---

## 三、第一步：创建华为云凭证

### 3.1 获取 AK/SK

1. 登录华为云控制台 → IAM（统一身份认证）
2. 创建用户 → 勾选"编程访问"
3. 给用户附加权限：CES Reader + CMDB ReadOnlyAccess
4. 创建 AK/SK，保存好

### 3.2 确认区域

确定要监控的区域，如：`cn-north-4`（华北-北京四）

---

## 四、第二步：部署 Prometheus

### 4.1 二进制部署（单节点演示）

```bash
# 下载 Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
tar xzf prometheus-2.45.0.linux-amd64.tar.gz
cd prometheus-2.45.0.linux-amd64

# 启动
./prometheus --config.file=prometheus.yml
```

### 4.2 prometheus.yml 配置

```yaml
global:
  scrape_interval: 60s

scrape_configs:
  # 华为云 CES Exporter
  - job_name: 'hwcloud-ces'
    metrics_path: '/metrics'
    static_configs:
      - targets: ['localhost:9091']
        labels:
          region: cn-north-4

  # 主机监控（Node Exporter）
  - job_name: 'node'
    static_configs:
      - targets: ['node-exporter:9100']
```

---

## 五、第三步：部署华为云 CES Exporter

### 5.1 使用现成的 Exporter（推荐）

华为云官方提供 CES Exporter：

```bash
# 使用华为云监控代理
wget https://github.com/huaweicloud/huaweicloud-monitor-exporter/releases/download/v1.0.0/hwc-exporter-linux-amd64
chmod +x hwc-exporter-linux-amd64
```

### 5.2 配置 hwc-exporter

创建配置文件 `config.yaml`：

```yaml
access_key: "your-ak-here"
secret_key: "your-sk-here"
region: "cn-north-4"
project_id: "your-project-id"  # 可从华为云控制台获取

collectors:
  - ecs           # 云服务器
  - rds           # 数据库
  - obs           # 对象存储
  - elb           # 负载均衡
  - vpn           # VPN
  - ccm           # 云证书

http:
  port: 9091
  path: /metrics
```

### 5.3 启动

```bash
./hwc-exporter-linux-amd64 --config config.yaml
```

### 5.4 验证

```bash
curl http://localhost:9091/metrics | head -50
```

---

## 六、第四步：部署 Node Exporter（ECS 内部监控）

在每台 ECS 上部署 node_exporter：

```bash
# 下载
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar xzf node_exporter-1.6.1.linux-amd64.tar.gz

# 启动（ systemd 服务）
sudo tee /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
ExecStart=/opt/node_exporter/node_exporter
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable node_exporter
sudo systemctl start node_exporter
```

---

## 七、第五步：配置告警规则

### 7.1 创建告警规则文件 `alerts.yml`

```yaml
groups:
  - name: huawei-hcs-alerts
    rules:
      # ECS CPU 告警
      - alert: ECSCPUHigh
        expr: hwc_ecs_cpu_usage > 85
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "ECS {{ $labels.instance_id }} CPU 使用率过高"
          description: "当前: {{ $value }}%, 阈值: 85%"

      # ECS 内存告警
      - alert: ECSMemoryHigh
        expr: hwc_ecs_memory_usage > 90
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "ECS {{ $labels.instance_id }} 内存使用率过高"

      # RDS 连接数告警
      - alert: RDSDBConnectionsHigh
        expr: hwc_rds_db_connections_usage > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "RDS {{ $labels.instance_id }} 连接数过高"

      # OBS 可用性告警
      - alert: OBSAvailabilityLow
        expr: hwc_obs_bucket_avail < 99.9
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "OBS bucket {{ $labels.bucket_name }} 可用性低于阈值"
```

### 7.2 更新 prometheus.yml

```yaml
rule_files:
  - "alerts.yml"
```

---

## 八、第六步：配置飞书告警

### 8.1 创建飞书告警机器人

1. 打开飞书群 → 设置 → 群机器人 → 添加机器人
2. 选择"自定义机器人"
3. 名字随便取，如"HCS监控告警"
4. 保存 Webhook 地址，格式：`https://open.feishu.cn/open-apis/bot/v2/hook/xxxxx`

### 8.2 安装 alertmanager-webhook-feishu

```bash
git clone https://github.com/goertzenator/alertmanager-webhook-feishu.git
cd alertmanager-webhook-feishu
go build -o alertmanager-feishu main.go
```

### 8.3 配置 alertmanager

创建 `alertmanager.yml`：

```yaml
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h
  receiver: 'feishu'
  routes:
    - match:
        severity: critical
      receiver: 'feishu-critical'
      group_wait: 10s

receivers:
  - name: 'feishu'
    webhook_configs:
      - url: 'https://open.feishu.cn/open-apis/bot/v2/hook/你的Webhook地址'
        send_resolved: true

  - name: 'feishu-critical'
    webhook_configs:
      - url: 'https://open.feishu.cn/open-apis/bot/v2/hook/你的Webhook地址'
        send_resolved: true
```

### 8.4 启动 AlertManager

```bash
./alertmanager --config.file=alertmanager.yml
```

---

## 九、第七步：配置 Grafana

### 9.1 安装 Grafana

```bash
sudo apt-get install -y grafana
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
```

### 9.2 添加数据源

1. 打开 http://localhost:3000
2. Configuration → Data Sources → Add data source
3. 选择 Prometheus，URL：`http://localhost:9090`
4. Save & Test

### 9.3 导入监控面板

Grafana ID: 15172（Node Exporter Full 面板）

或自己创建面板：
- 添加 Panel → PromQL → 选择指标 → 设置阈值

常用 PromQL：
```promql
# ECS CPU
hwc_ecs_cpu_usage{instance_id=~"ecs-.*"}

# 内存
hwc_ecs_memory_usage

# RDS 连接
hwc_rds_db_connections_usage

# OBS 请求数
rate(hwc_obs_requests_total[5m])
```

---

## 十、第八步：自动化巡检脚本

### 10.1 每日巡检脚本

```python
#!/usr/bin/env python3
"""
华为 HCS 监控巡检脚本
每日定时执行，检查所有资源状态
"""

import requests
import time
from datetime import datetime

# 华为云配置
ACCESS_KEY = "your-ak"
SECRET_KEY = "your-sk"
REGION = "cn-north-4"
PROJECT_ID = "your-project-id"

# 飞书配置
FEISHU_WEBHOOK = "https://open.feishu.cn/open-apis/bot/v2/hook/xxx"

def get_token():
    """获取华为云访问令牌"""
    url = f"https://iam.{REGION}.myhuaweicloud.com/v3/auth/tokens"
    data = {
        "auth": {
            "identity": {
                "methods": ["access_key"],
                "access_key": {
                    "access_key": ACCESS_KEY,
                    "secret_key": SECRET_KEY
                }
            },
            "scope": {
                "project": {"name": REGION}
            }
        }
    }
    resp = requests.post(url, json=data)
    return resp.headers.get("X-Subject-Token")

def get_ecs_list(token):
    """获取所有 ECS 实例"""
    url = f"https://ecs.{REGION}.myhuaweicloud.com/v1/{PROJECT_ID}/cloudservers"
    headers = {"X-Auth-Token": token}
    resp = requests.get(url, headers=headers)
    return resp.json().get("servers", [])

def get_rds_list(token):
    """获取所有 RDS 实例"""
    url = f"https://rds.{REGION}.myhuaweicloud.com/v3/{PROJECT_ID}/instances"
    headers = {"X-Auth-Token": token}
    resp = requests.get(url, headers=headers)
    return resp.json().get("instances", [])

def check_alerts(instance_name, metric, value, threshold):
    """检查是否触发告警"""
    if value > threshold:
        send_feishu_alert(instance_name, metric, value, threshold)

def send_feishu_alert(instance, metric, value, threshold):
    """发送飞书告警"""
    message = {
        "msg_type": "interactive",
        "card": {
            "header": {
                "title": f"🚨 监控告警 - {metric}",
                "template": "red"
            },
            "elements": [
                {"tag": "div", "text": {"content": f"**实例**: {instance}", "tag": "lark_md"}},
                {"tag": "div", "text": {"content": f"**指标**: {metric}", "tag": "lark_md"}},
                {"tag": "div", "text": {"content": f"**当前值**: {value}%", "tag": "lark_md"}},
                {"tag": "div", "text": {"content": f"**阈值**: {threshold}%", "tag": "lark_md"}},
                {"tag": "div", "text": {"content": f"**时间**: {datetime.now()}", "tag": "lark_md"}},
            ]
        }
    }
    requests.post(FEISHU_WEBHOOK, json=message)

def daily_check():
    """每日巡检"""
    print(f"[{datetime.now()}] 开始巡检...")
    token = get_token()
    
    # 检查 ECS
    ecs_list = get_ecs_list(token)
    print(f"ECS 数量: {len(ecs_list)}")
    
    # 检查 RDS
    rds_list = get_rds_list(token)
    print(f"RDS 数量: {len(rds_list)}")
    
    # TODO: 从 CES 获取实时指标进行判断
    # 具体指标查询参考第五步的 CES API
    
    print(f"[{datetime.now()}] 巡检完成")

if __name__ == "__main__":
    daily_check()
```

---

## 十一、华为云 CES API 详解

### 11.1 查询指标数据

```bash
# 获取 Token（复用上面的方法）

# 查询 ECS CPU 使用率
curl -X GET "https://ces.cn-north-4.myhuaweicloud.com/V1.0/metricdata?search=&namespace=SYS.ECS&metric_name= cpu_util&from=1709136000000&to=1709143200000&limit=100" \
  -H "X-Auth-Token: $TOKEN"
```

### 11.2 常用指标名称

| 资源类型 | 指标名称 | 说明 |
|----------|----------|------|
| ECS | cpu_util | CPU 使用率 |
| ECS | mem_util | 内存使用率 |
| ECS | disk_util | 磁盘使用率 |
| ECS | net_bits_out | 网络出带宽 |
| RDS | rds_cpu_util | RDS CPU 使用率 |
| RDS | rds_mem_util | RDS 内存使用率 |
| RDS | rds_disk_util | RDS 磁盘使用率 |
| RDS | rds_conn_count | 数据库连接数 |
| OBS | obs_bucket_avail | OBS 可用性 |
| OBS | obs_bucket_latency | OBS 延迟 |

---

## 十二、实施检查清单

| 步骤 | 任务 | 状态 |
|------|------|------|
| 1 | 创建华为云 IAM 用户，获取 AK/SK | ⬜ |
| 2 | 部署 Prometheus Server | ⬜ |
| 3 | 部署华为云 CES Exporter | ⬜ |
| 4 | 在 ECS 上部署 Node Exporter | ⬜ |
| 5 | 配置 Prometheus 告警规则 | ⬜ |
| 6 | 创建飞书告警机器人 | ⬜ |
| 7 | 部署 AlertManager + 飞书插件 | ⬜ |
| 8 | 安装配置 Grafana | ⬜ |
| 9 | 导入/创建监控面板 | ⬜ |
| 10 | 测试告警通知 | ⬜ |
| 11 | 部署每日巡检脚本 | ⬜ |
| 12 | 文档交接 | ⬜ |

---

*文档版本：V1.0*
*创建时间：2026-03-30*
