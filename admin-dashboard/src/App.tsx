import React from 'react';
import './App.css';

function App() {
  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto py-6 px-4">
        <div className="text-center">
          <h1 className="text-4xl font-bold text-gray-900 mb-4">
            🚀 Udaan Admin Dashboard
          </h1>
          <p className="text-xl text-gray-600 mb-8">
            Modern admin interface for managing your college review platform
          </p>
          
          <div className="bg-white rounded-lg shadow-lg p-8 max-w-2xl mx-auto">
            <h2 className="text-2xl font-semibold text-gray-800 mb-6">
              Dashboard Features
            </h2>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6 text-left">
              <div className="bg-blue-50 p-4 rounded-lg">
                <h3 className="font-semibold text-blue-900 mb-2">📊 Dashboard Analytics</h3>
                <p className="text-blue-700 text-sm">Real-time statistics and overview of your platform</p>
              </div>
              
              <div className="bg-green-50 p-4 rounded-lg">
                <h3 className="font-semibold text-green-900 mb-2">🏛️ College Management</h3>
                <p className="text-green-700 text-sm">Full CRUD operations for college data</p>
              </div>
              
              <div className="bg-purple-50 p-4 rounded-lg">
                <h3 className="font-semibold text-purple-900 mb-2">📝 Review Oversight</h3>
                <p className="text-purple-700 text-sm">View and moderate user reviews</p>
              </div>
              
              <div className="bg-orange-50 p-4 rounded-lg">
                <h3 className="font-semibold text-orange-900 mb-2">⚡ Modern UI</h3>
                <p className="text-orange-700 text-sm">Clean, responsive design built with React & Tailwind</p>
              </div>
            </div>
            
            <div className="mt-8 p-4 bg-gray-50 rounded-lg">
              <p className="text-gray-600 text-sm">
                <strong>Setup Instructions:</strong><br/>
                1. Ensure your FastAPI backend is running on port 8000<br/>
                2. Install dependencies: <code className="bg-gray-200 px-1 rounded">npm install</code><br/>
                3. Start development server: <code className="bg-gray-200 px-1 rounded">npm start</code>
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
