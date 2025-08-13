#!/bin/bash

echo "🚀 Starting Udaan Admin Dashboard..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js v16 or later."
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Please install npm."
    exit 1
fi

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "⚠️  Creating .env file with default settings..."
    echo "REACT_APP_API_URL=http://localhost:8000" > .env
fi

echo "🌐 Starting development server..."
echo "📝 Admin Dashboard will be available at: http://localhost:3000"
echo "🔧 Make sure your FastAPI backend is running on: http://localhost:8000"
echo ""

# Start the development server
npm start