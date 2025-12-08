#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Redis Mock Server for Testing
模拟 Redis 服务器用于测试

This script simulates a Redis server that publishes monitoring data
for testing the monitoring center application.
"""

import redis
import time
import json
import random
from datetime import datetime


def publish_monitoring_data(redis_client):
    """Publish simulated monitoring data"""
    devices = ['DEV001', 'DEV002', 'DEV003', 'DEV004', 'DEV005']
    statuses = ['online', 'warning', 'error']
    
    while True:
        try:
            # Simulate device status
            device_id = random.choice(devices)
            status = random.choice(statuses)
            
            data = {
                'device_id': device_id,
                'status': status,
                'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                'value': random.uniform(20.0, 30.0)
            }
            
            # Publish to monitoring_data channel
            redis_client.publish('monitoring_data', json.dumps(data))
            print(f"Published: {data}")
            
            time.sleep(random.uniform(2, 5))  # Random interval
            
        except KeyboardInterrupt:
            print("\nStopping mock server...")
            break
        except Exception as e:
            print(f"Error: {e}")
            time.sleep(1)


def main():
    """Main entry point"""
    # Connect to Redis
    try:
        redis_client = redis.Redis(
            host='localhost',
            port=8899,
            decode_responses=True
        )
        
        # Test connection
        redis_client.ping()
        print("Connected to Redis server on port 8899")
        print("Publishing monitoring data...")
        print("Press Ctrl+C to stop\n")
        
        # Start publishing
        publish_monitoring_data(redis_client)
        
    except redis.ConnectionError:
        print("Error: Could not connect to Redis server on port 8899")
        print("Please start Redis server with: redis-server --port 8899")
    except Exception as e:
        print(f"Error: {e}")


if __name__ == '__main__':
    main()
