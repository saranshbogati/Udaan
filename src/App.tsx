import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Layout from './components/Layout';
import Dashboard from './components/Dashboard';
import Colleges from './components/Colleges';
import Reviews from './components/Reviews';
import './App.css';

function App() {
  return (
    <Router>
      <Layout>
        <Routes>
          <Route path="/" element={<Dashboard />} />
          <Route path="/colleges" element={<Colleges />} />
          <Route path="/reviews" element={<Reviews />} />
          <Route path="/users" element={<div className="text-center py-12"><h2 className="text-2xl font-bold text-gray-900">Users Management</h2><p className="text-gray-600 mt-2">Coming soon...</p></div>} />
          <Route path="/settings" element={<div className="text-center py-12"><h2 className="text-2xl font-bold text-gray-900">Settings</h2><p className="text-gray-600 mt-2">Coming soon...</p></div>} />
        </Routes>
      </Layout>
    </Router>
  );
}

export default App;