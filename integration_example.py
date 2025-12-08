#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Example: Integrating with Real Monitoring System
演示如何与真实监控系统集成

This example shows how to publish real monitoring data to Redis
for consumption by the monitoring center application.
"""

import redis
import json
import time
from datetime import datetime
import random


class DeviceMonitor:
    """Simulate a device monitoring system"""
    
    def __init__(self, redis_host='localhost', redis_port=8899):
        self.redis_client = redis.Redis(
            host=redis_host,
            port=redis_port,
            decode_responses=True
        )
        self.devices = self._initialize_devices()
    
    def _initialize_devices(self):
        """Initialize monitored devices"""
        return [
            {
                'id': 'CTRL-001',
                'name': '疏散控制器-A站台',
                'type': 'controller',
                'location': 'A站台'
            },
            {
                'id': 'CTRL-002',
                'name': '疏散控制器-B站台',
                'type': 'controller',
                'location': 'B站台'
            },
            {
                'id': 'PWR-001',
                'name': '应急电源-A站台',
                'type': 'power_supply',
                'location': 'A站台'
            },
            {
                'id': 'PWR-002',
                'name': '应急电源-B站台',
                'type': 'power_supply',
                'location': 'B站台'
            },
            {
                'id': 'LIGHT-A1',
                'name': '疏散灯具组-A1',
                'type': 'light_group',
                'location': 'A站台-1区'
            },
            {
                'id': 'LIGHT-A2',
                'name': '疏散灯具组-A2',
                'type': 'light_group',
                'location': 'A站台-2区'
            },
        ]
    
    def publish_device_status(self):
        """Publish device status to Redis"""
        status_data = []
        
        for device in self.devices:
            status = {
                'device_id': device['id'],
                'device_name': device['name'],
                'device_type': device['type'],
                'location': device['location'],
                'status': random.choice(['online', 'online', 'online', 'warning']),  # 75% online
                'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            }
            
            # Add type-specific data
            if device['type'] == 'controller':
                status['signal_strength'] = random.randint(70, 100)
                status['cpu_usage'] = random.randint(10, 60)
                status['memory_usage'] = random.randint(20, 70)
            
            elif device['type'] == 'power_supply':
                status['voltage'] = round(random.uniform(23.5, 24.8), 2)
                status['current'] = round(random.uniform(1.5, 3.2), 2)
                status['temperature'] = random.randint(25, 45)
            
            elif device['type'] == 'light_group':
                status['total_lights'] = 120
                status['online_lights'] = random.randint(115, 120)
                status['brightness'] = random.randint(80, 100)
            
            status_data.append(status)
        
        # Publish to device_status channel
        message = json.dumps(status_data, ensure_ascii=False)
        self.redis_client.publish('device_status', message)
        
        return status_data
    
    def publish_monitoring_data(self, device_id):
        """Publish real-time monitoring data for a specific device"""
        device = next((d for d in self.devices if d['id'] == device_id), None)
        if not device:
            return None
        
        data = {
            'device_id': device_id,
            'device_name': device['name'],
            'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')[:-3],
            'data_points': []
        }
        
        # Simulate different data points based on device type
        if device['type'] == 'controller':
            data['data_points'] = [
                {'metric': 'cpu_usage', 'value': random.randint(10, 60), 'unit': '%'},
                {'metric': 'memory_usage', 'value': random.randint(20, 70), 'unit': '%'},
                {'metric': 'network_traffic', 'value': random.randint(100, 500), 'unit': 'KB/s'},
            ]
        
        elif device['type'] == 'power_supply':
            data['data_points'] = [
                {'metric': 'voltage', 'value': round(random.uniform(23.5, 24.8), 2), 'unit': 'V'},
                {'metric': 'current', 'value': round(random.uniform(1.5, 3.2), 2), 'unit': 'A'},
                {'metric': 'power', 'value': round(random.uniform(35, 80), 2), 'unit': 'W'},
            ]
        
        elif device['type'] == 'light_group':
            data['data_points'] = [
                {'metric': 'brightness', 'value': random.randint(80, 100), 'unit': '%'},
                {'metric': 'online_count', 'value': random.randint(115, 120), 'unit': 'units'},
                {'metric': 'response_time', 'value': random.randint(50, 200), 'unit': 'ms'},
            ]
        
        # Publish to monitoring_data channel
        message = json.dumps(data, ensure_ascii=False)
        self.redis_client.publish('monitoring_data', message)
        
        return data
    
    def handle_control_command(self):
        """Subscribe to control commands and handle them"""
        pubsub = self.redis_client.pubsub()
        pubsub.subscribe('control_commands')
        
        print("Listening for control commands...")
        
        for message in pubsub.listen():
            if message['type'] == 'message':
                try:
                    command = json.loads(message['data'])
                    print(f"Received command: {command}")
                    
                    action = command.get('action')
                    timestamp = command.get('timestamp')
                    
                    if action == 'confirm':
                        print(f"[{timestamp}] Information confirmed")
                        # Execute confirmation logic
                        response = {
                            'status': 'success',
                            'message': '信息确认成功',
                            'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                        }
                        self.redis_client.publish('query_results', json.dumps(response, ensure_ascii=False))
                    
                    elif action == 'restore':
                        print(f"[{timestamp}] Restore request received")
                        # Execute restore logic
                        response = {
                            'status': 'success',
                            'message': '信息恢复成功',
                            'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                        }
                        self.redis_client.publish('query_results', json.dumps(response, ensure_ascii=False))
                    
                except json.JSONDecodeError:
                    print("Invalid JSON in command")
    
    def handle_query_request(self):
        """Subscribe to query requests and respond"""
        pubsub = self.redis_client.pubsub()
        pubsub.subscribe('query_requests')
        
        print("Listening for query requests...")
        
        for message in pubsub.listen():
            if message['type'] == 'message':
                try:
                    query = json.loads(message['data'])
                    print(f"Received query: {query}")
                    
                    query_type = query.get('query_type')
                    
                    if query_type == 'device_status':
                        # Send current device status
                        status_data = self.publish_device_status()
                        print(f"Sent device status: {len(status_data)} devices")
                    
                    elif query_type == 'query_records':
                        # Send query history
                        records = {
                            'records': [
                                {
                                    'timestamp': '2025-12-07 14:30:15',
                                    'type': '设备状态查询',
                                    'result': '成功',
                                    'user': 'admin'
                                },
                                {
                                    'timestamp': '2025-12-07 10:15:22',
                                    'type': '远程控制命令',
                                    'result': '成功',
                                    'user': 'operator1'
                                },
                            ]
                        }
                        self.redis_client.publish('query_results', json.dumps(records, ensure_ascii=False))
                
                except json.JSONDecodeError:
                    print("Invalid JSON in query")
    
    def run_monitoring_loop(self):
        """Run continuous monitoring loop"""
        print("Starting device monitoring...")
        print(f"Monitoring {len(self.devices)} devices")
        print("Press Ctrl+C to stop\n")
        
        try:
            iteration = 0
            while True:
                iteration += 1
                print(f"\n=== Monitoring Iteration {iteration} ===")
                
                # Publish device status every 5 iterations
                if iteration % 5 == 0:
                    status_data = self.publish_device_status()
                    print(f"Published device status for {len(status_data)} devices")
                
                # Publish real-time data for random device
                device = random.choice(self.devices)
                data = self.publish_monitoring_data(device['id'])
                print(f"Published monitoring data for {device['name']}")
                
                time.sleep(2)  # 2 second interval
        
        except KeyboardInterrupt:
            print("\n\nStopping monitoring...")


def main():
    """Main entry point"""
    import sys
    
    print("=" * 60)
    print("Device Monitoring System Integration Example")
    print("设备监控系统集成示例")
    print("=" * 60)
    print()
    
    # Parse command line arguments
    host = sys.argv[1] if len(sys.argv) > 1 else 'localhost'
    port = int(sys.argv[2]) if len(sys.argv) > 2 else 8899
    mode = sys.argv[3] if len(sys.argv) > 3 else 'monitor'
    
    print(f"Connecting to Redis at {host}:{port}")
    print(f"Mode: {mode}")
    print()
    
    try:
        monitor = DeviceMonitor(host, port)
        
        if mode == 'monitor':
            # Run continuous monitoring
            monitor.run_monitoring_loop()
        
        elif mode == 'command':
            # Handle control commands
            monitor.handle_control_command()
        
        elif mode == 'query':
            # Handle query requests
            monitor.handle_query_request()
        
        else:
            print(f"Unknown mode: {mode}")
            print("Available modes: monitor, command, query")
            sys.exit(1)
    
    except redis.ConnectionError:
        print(f"Error: Could not connect to Redis at {host}:{port}")
        print("Please ensure Redis server is running:")
        print(f"  redis-server --port {port}")
        sys.exit(1)
    
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == '__main__':
    main()
