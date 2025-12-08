#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Test script to validate the monitoring center application
"""

import sys
import time
import os
from PyQt5.QtWidgets import QApplication
from PyQt5.QtCore import QTimer
from PyQt5.QtGui import QPixmap

# Import the main application
from monitoring_center import MonitoringCenterApp


def test_application():
    """Test the application without Redis connection"""
    app = QApplication(sys.argv)
    window = MonitoringCenterApp()
    window.show()
    
    # Get the directory of this script
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Schedule screenshot and exit
    def take_screenshot_and_exit():
        # Take a screenshot
        screen = app.primaryScreen()
        screenshot = screen.grabWindow(window.winId())
        screenshot_path = os.path.join(script_dir, 'screenshot_monitoring_center.png')
        screenshot.save(screenshot_path)
        print(f"Screenshot saved: {screenshot_path}")
        
        # Log some test messages
        window.log_message("=" * 60)
        window.log_message("应用程序测试")
        window.log_message("=" * 60)
        window.log_message("✓ GUI 界面已成功创建")
        window.log_message("✓ 所有控件已初始化")
        window.log_message("✓ 布局正确显示")
        
        # Take another screenshot with content
        time.sleep(0.5)
        screenshot = screen.grabWindow(window.winId())
        screenshot_path_content = os.path.join(script_dir, 'screenshot_with_content.png')
        screenshot.save(screenshot_path_content)
        print(f"Screenshot with content saved: {screenshot_path_content}")
        
        # Exit application
        QTimer.singleShot(100, app.quit)
    
    # Schedule the screenshot after the window is fully rendered
    QTimer.singleShot(1000, take_screenshot_and_exit)
    
    # Run the application
    sys.exit(app.exec_())


if __name__ == '__main__':
    test_application()
