#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Remote Monitoring Center Application
模拟远程监控中心应用程序

This application provides a GUI interface for remote monitoring using Redis pub/sub.
"""

import sys
import json
import threading
from datetime import datetime
from PyQt5.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QLabel, QLineEdit, QPushButton, QTextEdit, QGroupBox, QButtonGroup,
    QRadioButton
)
from PyQt5.QtCore import Qt, pyqtSignal, QObject
from PyQt5.QtGui import QFont
import redis


class RedisListener(QObject):
    """Redis pub/sub listener running in a separate thread"""
    message_received = pyqtSignal(str, str)  # channel, message
    
    def __init__(self, host, port):
        super().__init__()
        self.host = host
        self.port = port
        self.redis_client = None
        self.pubsub = None
        self.running = False
        self.thread = None
    
    def start(self):
        """Start listening to Redis channels"""
        try:
            self.redis_client = redis.Redis(
                host=self.host,
                port=self.port,
                decode_responses=True
            )
            # Test connection
            self.redis_client.ping()
            
            self.pubsub = self.redis_client.pubsub()
            # Subscribe to monitoring channels
            self.pubsub.subscribe('monitoring_data', 'device_status', 'query_results')
            
            self.running = True
            self.thread = threading.Thread(target=self._listen, daemon=True)
            self.thread.start()
            return True
        except Exception as e:
            return False
    
    def stop(self):
        """Stop listening"""
        self.running = False
        if self.pubsub:
            self.pubsub.unsubscribe()
            self.pubsub.close()
        if self.redis_client:
            self.redis_client.close()
    
    def _listen(self):
        """Listen for messages in a separate thread"""
        while self.running:
            try:
                message = self.pubsub.get_message()
                if message and message['type'] == 'message':
                    channel = message['channel']
                    data = message['data']
                    self.message_received.emit(channel, data)
            except Exception as e:
                if self.running:
                    self.message_received.emit('error', str(e))
            finally:
                import time
                time.sleep(0.1)
    
    def publish(self, channel, message):
        """Publish a message to Redis"""
        try:
            if self.redis_client:
                self.redis_client.publish(channel, message)
                return True
        except Exception as e:
            return False
        return False


class MonitoringCenterApp(QMainWindow):
    """Main application window for remote monitoring center"""
    
    def __init__(self):
        super().__init__()
        self.redis_listener = None
        self.service_running = False
        self.current_tab = "device_status"  # or "query_records"
        
        self.initUI()
    
    def initUI(self):
        """Initialize the user interface"""
        self.setWindowTitle('模拟远程监控中心')
        self.setGeometry(100, 100, 1200, 800)
        
        # Create central widget and main layout
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        main_layout = QVBoxLayout(central_widget)
        
        # Create top control area
        top_layout = QHBoxLayout()
        
        # Left configuration panel
        config_group = QGroupBox()
        config_layout = QVBoxLayout()
        
        # Server address input
        addr_layout = QHBoxLayout()
        addr_label = QLabel('服务器地址:')
        addr_label.setFixedWidth(100)
        self.addr_input = QLineEdit()
        self.addr_input.setText('localhost')
        addr_layout.addWidget(addr_label)
        addr_layout.addWidget(self.addr_input)
        config_layout.addLayout(addr_layout)
        
        # Server port input
        port_layout = QHBoxLayout()
        port_label = QLabel('服务器端口:')
        port_label.setFixedWidth(100)
        self.port_input = QLineEdit()
        self.port_input.setText('8899')
        port_layout.addWidget(port_label)
        port_layout.addWidget(self.port_input)
        config_layout.addLayout(port_layout)
        
        # Tab buttons
        tab_layout = QHBoxLayout()
        self.tab_group = QButtonGroup()
        
        self.device_status_btn = QRadioButton('设备状态信息')
        self.device_status_btn.setChecked(True)
        self.device_status_btn.toggled.connect(lambda: self.switch_tab('device_status'))
        
        self.query_records_btn = QRadioButton('查询记录')
        self.query_records_btn.toggled.connect(lambda: self.switch_tab('query_records'))
        
        self.tab_group.addButton(self.device_status_btn)
        self.tab_group.addButton(self.query_records_btn)
        
        tab_layout.addWidget(self.device_status_btn)
        tab_layout.addWidget(self.query_records_btn)
        config_layout.addLayout(tab_layout)
        
        config_group.setLayout(config_layout)
        top_layout.addWidget(config_group)
        
        # Right control panel
        control_group = QGroupBox('模拟远程监控中心')
        control_layout = QVBoxLayout()
        
        # Create control buttons
        self.start_service_btn = QPushButton('启动服务')
        self.start_service_btn.clicked.connect(self.start_service)
        
        self.stop_service_btn = QPushButton('停止服务')
        self.stop_service_btn.clicked.connect(self.stop_service)
        self.stop_service_btn.setEnabled(False)
        
        self.info_confirm_btn = QPushButton('信息确认')
        self.info_confirm_btn.clicked.connect(self.info_confirm)
        
        self.info_restore_btn = QPushButton('信息恢复')
        self.info_restore_btn.clicked.connect(self.info_restore)
        
        self.remote_query_btn = QPushButton('远程查询')
        self.remote_query_btn.clicked.connect(self.remote_query)
        
        self.clear_btn = QPushButton('清除')
        self.clear_btn.clicked.connect(self.clear_display)
        
        # Add buttons to control layout
        control_layout.addWidget(self.start_service_btn)
        control_layout.addWidget(self.stop_service_btn)
        control_layout.addWidget(self.info_confirm_btn)
        control_layout.addWidget(self.info_restore_btn)
        control_layout.addWidget(self.remote_query_btn)
        control_layout.addWidget(self.clear_btn)
        control_layout.addStretch()
        
        control_group.setLayout(control_layout)
        top_layout.addWidget(control_group)
        
        main_layout.addLayout(top_layout)
        
        # Central display area
        display_group = QGroupBox('监控显示区域')
        display_layout = QVBoxLayout()
        
        self.display_text = QTextEdit()
        self.display_text.setReadOnly(True)
        self.display_text.setStyleSheet('background-color: #f5f5f5;')
        font = QFont('Courier New', 10)
        self.display_text.setFont(font)
        
        display_layout.addWidget(self.display_text)
        display_group.setLayout(display_layout)
        
        main_layout.addWidget(display_group)
        
        # Set layout proportions
        main_layout.setStretch(0, 1)  # Top control area
        main_layout.setStretch(1, 5)  # Display area
    
    def switch_tab(self, tab_name):
        """Switch between tabs"""
        self.current_tab = tab_name
        self.log_message(f"切换到: {tab_name}")
    
    def start_service(self):
        """Start monitoring service"""
        host = self.addr_input.text()
        port = int(self.port_input.text())
        
        self.log_message(f"正在连接到 Redis 服务器 {host}:{port}...")
        
        # Create and start Redis listener
        self.redis_listener = RedisListener(host, port)
        self.redis_listener.message_received.connect(self.on_redis_message)
        
        if self.redis_listener.start():
            self.service_running = True
            self.start_service_btn.setEnabled(False)
            self.stop_service_btn.setEnabled(True)
            self.addr_input.setEnabled(False)
            self.port_input.setEnabled(False)
            
            self.log_message("✓ 服务已启动")
            self.log_message(f"已订阅频道: monitoring_data, device_status, query_results")
            
            # Simulate initial device status
            self.simulate_device_status()
        else:
            self.log_message("✗ 连接失败，请检查服务器地址和端口")
    
    def stop_service(self):
        """Stop monitoring service"""
        if self.redis_listener:
            self.redis_listener.stop()
            self.redis_listener = None
        
        self.service_running = False
        self.start_service_btn.setEnabled(True)
        self.stop_service_btn.setEnabled(False)
        self.addr_input.setEnabled(True)
        self.port_input.setEnabled(True)
        
        self.log_message("服务已停止")
    
    def info_confirm(self):
        """Confirm information"""
        if not self.service_running:
            self.log_message("请先启动服务")
            return
        
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        confirm_msg = {
            'action': 'confirm',
            'timestamp': timestamp,
            'tab': self.current_tab
        }
        
        if self.redis_listener.publish('control_commands', json.dumps(confirm_msg)):
            self.log_message(f"[{timestamp}] 信息确认已发送")
        else:
            self.log_message("发送确认失败")
    
    def info_restore(self):
        """Restore information"""
        if not self.service_running:
            self.log_message("请先启动服务")
            return
        
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        restore_msg = {
            'action': 'restore',
            'timestamp': timestamp
        }
        
        if self.redis_listener.publish('control_commands', json.dumps(restore_msg)):
            self.log_message(f"[{timestamp}] 信息恢复请求已发送")
        else:
            self.log_message("发送恢复请求失败")
    
    def remote_query(self):
        """Execute remote query"""
        if not self.service_running:
            self.log_message("请先启动服务")
            return
        
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        query_msg = {
            'action': 'query',
            'timestamp': timestamp,
            'query_type': self.current_tab
        }
        
        if self.redis_listener.publish('query_requests', json.dumps(query_msg)):
            self.log_message(f"[{timestamp}] 远程查询请求已发送")
            self.log_message(f"查询类型: {self.current_tab}")
            
            # Simulate query results
            self.simulate_query_results()
        else:
            self.log_message("发送查询请求失败")
    
    def clear_display(self):
        """Clear display area"""
        self.display_text.clear()
        self.log_message("显示区域已清除")
    
    def log_message(self, message):
        """Log message to display area"""
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        formatted_msg = f"[{timestamp}] {message}"
        self.display_text.append(formatted_msg)
    
    def on_redis_message(self, channel, message):
        """Handle incoming Redis messages"""
        if channel == 'error':
            self.log_message(f"Redis 错误: {message}")
        else:
            self.log_message(f"收到消息 [{channel}]: {message}")
    
    def simulate_device_status(self):
        """Simulate device status data"""
        status_data = {
            'devices': [
                {'id': 'DEV001', 'name': '疏散控制器1', 'status': 'online', 'signal': 'strong'},
                {'id': 'DEV002', 'name': '疏散控制器2', 'status': 'online', 'signal': 'medium'},
                {'id': 'DEV003', 'name': '应急电源1', 'status': 'online', 'voltage': '24.5V'},
                {'id': 'DEV004', 'name': '应急电源2', 'status': 'online', 'voltage': '24.2V'},
                {'id': 'DEV005', 'name': '疏散灯具组1', 'status': 'online', 'count': 120},
            ]
        }
        
        self.log_message("=" * 60)
        self.log_message("设备状态信息")
        self.log_message("=" * 60)
        for device in status_data['devices']:
            info_parts = [f"设备ID: {device['id']}", f"名称: {device['name']}", f"状态: {device['status']}"]
            if 'signal' in device:
                info_parts.append(f"信号: {device['signal']}")
            if 'voltage' in device:
                info_parts.append(f"电压: {device['voltage']}")
            if 'count' in device:
                info_parts.append(f"数量: {device['count']}")
            self.log_message(" | ".join(info_parts))
        self.log_message("=" * 60)
    
    def simulate_query_results(self):
        """Simulate query results"""
        import time
        time.sleep(0.5)  # Simulate network delay
        
        if self.current_tab == 'device_status':
            self.log_message("=" * 60)
            self.log_message("设备状态查询结果")
            self.log_message("=" * 60)
            self.log_message("在线设备: 5/5")
            self.log_message("离线设备: 0")
            self.log_message("告警设备: 0")
            self.log_message("=" * 60)
        else:
            self.log_message("=" * 60)
            self.log_message("历史查询记录")
            self.log_message("=" * 60)
            records = [
                "2025-12-07 14:30:15 | 设备状态查询 | 成功",
                "2025-12-07 10:15:22 | 远程控制命令 | 成功",
                "2025-12-06 16:45:33 | 信息确认 | 成功",
                "2025-12-06 09:20:11 | 设备状态查询 | 成功",
            ]
            for record in records:
                self.log_message(record)
            self.log_message("=" * 60)
    
    def closeEvent(self, event):
        """Handle window close event"""
        if self.service_running:
            self.stop_service()
        event.accept()


def main():
    """Main entry point"""
    app = QApplication(sys.argv)
    
    # Set application style
    app.setStyle('Fusion')
    
    window = MonitoringCenterApp()
    window.show()
    
    sys.exit(app.exec_())


if __name__ == '__main__':
    main()
