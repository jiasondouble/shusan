# 使用指南 / Usage Guide

## 远程监控中心应用程序使用指南

### 快速开始

#### 1. 安装依赖

```bash
pip install -r requirements.txt
```

#### 2. 启动 Redis 服务器（可选）

如果要测试完整的 Redis 发布/订阅功能：

```bash
# 在端口 8899 上启动 Redis
redis-server --port 8899
```

#### 3. 运行应用程序

```bash
# 常规环境
python3 monitoring_center.py

# 无头环境（服务器）
QT_QPA_PLATFORM=offscreen python3 monitoring_center.py

# 使用启动脚本
./start.sh
```

---

### 界面说明

#### 顶部控制区域

**左侧配置面板：**

1. **服务器地址**
   - 输入 Redis 服务器地址
   - 默认值：`localhost`
   - 示例：`192.168.1.100`, `redis.example.com`

2. **服务器端口**
   - 输入 Redis 服务器端口号
   - 默认值：`8899`
   - 标准 Redis 端口：`6379`

3. **选项卡按钮**
   - **设备状态信息**：显示设备状态和监控数据
   - **查询记录**：显示历史查询记录

**右侧控制面板：**

1. **启动服务**
   - 连接到 Redis 服务器
   - 开始订阅监控数据
   - 按钮变为不可用，"停止服务"变为可用

2. **停止服务**
   - 断开 Redis 连接
   - 停止接收监控数据
   - 恢复配置输入框

3. **信息确认**
   - 确认当前显示的监控信息
   - 发送确认消息到 Redis `control_commands` 频道

4. **信息恢复**
   - 请求恢复历史信息
   - 发送恢复请求到 Redis

5. **远程查询**
   - 执行远程数据查询
   - 根据当前选项卡查询设备状态或历史记录
   - 发送查询请求到 Redis `query_requests` 频道

6. **清除**
   - 清空显示区域的所有内容

#### 中央显示区域

- 显示实时监控数据
- 显示日志信息（带时间戳）
- 显示查询结果
- 支持滚动查看历史记录

---

### 使用流程

#### 基本使用流程

1. **启动应用程序**
   ```bash
   python3 monitoring_center.py
   ```

2. **配置连接参数**
   - 输入 Redis 服务器地址和端口
   - 或使用默认值

3. **启动服务**
   - 点击"启动服务"按钮
   - 等待连接成功提示
   - 查看自动显示的设备状态信息

4. **切换视图**
   - 点击"设备状态信息"查看设备状态
   - 点击"查询记录"查看历史记录

5. **执行操作**
   - 使用"远程查询"获取最新数据
   - 使用"信息确认"确认重要信息
   - 使用"信息恢复"请求历史数据
   - 使用"清除"清理显示区域

6. **停止服务**
   - 点击"停止服务"断开连接
   - 或直接关闭窗口

---

### Redis 频道说明

#### 订阅频道（接收数据）

| 频道名称 | 用途 | 数据格式 |
|---------|------|---------|
| `monitoring_data` | 实时监控数据 | JSON |
| `device_status` | 设备状态信息 | JSON |
| `query_results` | 查询结果 | JSON |

#### 发布频道（发送命令）

| 频道名称 | 用途 | 数据格式 |
|---------|------|---------|
| `control_commands` | 控制指令 | JSON |
| `query_requests` | 查询请求 | JSON |

---

### 测试和开发

#### 运行测试脚本

```bash
# 测试应用程序（无需 Redis）
QT_QPA_PLATFORM=offscreen python3 test_app.py
```

#### 使用模拟 Redis 服务器

在一个终端启动模拟服务器：

```bash
python3 mock_redis_server.py
```

在另一个终端启动监控中心：

```bash
python3 monitoring_center.py
```

#### 自定义开发

**添加新的监控功能：**

1. 在 `RedisListener` 类中订阅新频道：
```python
self.pubsub.subscribe('monitoring_data', 'device_status', 'query_results', 'your_new_channel')
```

2. 在 `on_redis_message` 方法中处理新消息类型：
```python
def on_redis_message(self, channel, message):
    if channel == 'your_new_channel':
        # 处理新消息
        self.handle_new_message(message)
    else:
        self.log_message(f"收到消息 [{channel}]: {message}")
```

3. 添加新的 UI 控件和处理函数。

---

### 常见问题

#### Q: 应用程序无法启动

**A:** 检查以下几点：
- Python 版本是否为 3.7+
- PyQt5 是否正确安装
- 是否有 X11 显示服务器（Linux 桌面环境）
- 尝试使用 `QT_QPA_PLATFORM=offscreen` 环境变量

#### Q: 无法连接到 Redis

**A:** 检查：
- Redis 服务器是否正在运行
- 服务器地址和端口是否正确
- 防火墙是否允许连接
- 使用 `redis-cli -h <host> -p <port> ping` 测试连接

#### Q: 没有收到监控数据

**A:** 确保：
- Redis 服务已启动
- 有其他程序在发布数据到订阅的频道
- 可以使用 `mock_redis_server.py` 进行测试

#### Q: 显示乱码

**A:** 检查：
- 系统是否支持中文字符集
- 终端编码是否为 UTF-8
- PyQt5 版本是否正确

---

### 系统要求

- **操作系统**: Linux, Windows, macOS
- **Python**: 3.7 或更高版本
- **依赖库**: PyQt5 5.15.10, redis 5.0.1
- **Redis**: 可选，用于完整功能测试

---

### 技术支持

如有问题或建议，请访问：
- GitHub 仓库: https://github.com/jiasondouble/shusan
- 提交 Issue 或 Pull Request

---

### 更新日志

**v1.0** (2025-12-08)
- 初始版本发布
- 实现基本 GUI 界面
- 集成 Redis 发布/订阅
- 添加设备状态监控
- 添加查询记录功能
- 支持中文界面

---

### 许可证

本项目遵循仓库许可证。
