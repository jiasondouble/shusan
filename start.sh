#!/bin/bash
# Quick start script for the Remote Monitoring Center Application

echo "=========================================="
echo "Remote Monitoring Center - Quick Start"
echo "=========================================="
echo ""

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed"
    exit 1
fi

echo "✓ Python 3 found: $(python3 --version)"

# Check if pip is installed
if ! command -v pip3 &> /dev/null; then
    echo "Error: pip3 is not installed"
    exit 1
fi

echo "✓ pip3 found"

# Install dependencies
echo ""
echo "Installing dependencies..."
pip3 install -r requirements.txt

if [ $? -ne 0 ]; then
    echo "Error: Failed to install dependencies"
    exit 1
fi

echo "✓ Dependencies installed"

# Check if Redis is running
echo ""
echo "Checking Redis server..."
if command -v redis-cli &> /dev/null; then
    if redis-cli -p 8899 ping &> /dev/null; then
        echo "✓ Redis server is running on port 8899"
    else
        echo "⚠ Redis server is not running on port 8899"
        echo ""
        echo "Please start Redis server with:"
        echo "  redis-server --port 8899"
        echo ""
        echo "Or use the default port 6379 and update the port in the application."
    fi
else
    echo "⚠ redis-cli not found. Please install Redis."
    echo ""
    echo "You can still run the application, but it won't be able to connect to Redis."
fi

# Run the application
echo ""
echo "=========================================="
echo "Starting the application..."
echo "=========================================="
echo ""

# Set environment variable for Qt platform (for headless environments)
export QT_QPA_PLATFORM=xcb

python3 monitoring_center.py

if [ $? -ne 0 ]; then
    echo ""
    echo "Note: If running in a headless environment, use:"
    echo "  QT_QPA_PLATFORM=offscreen python3 monitoring_center.py"
fi
