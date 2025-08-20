import React from "react";

import AdminDashboard from "../components/AdminDashboard";
import AdminLogin from "../components/AdminLogin";
import { useAuth } from "../contexts/AuthContext";

const AdminRoute: React.FC = () => {
  const { user, login, logout, loading } = useAuth();

  const handleLoginSuccess = async (username: string, password: string) => {
    await login(username, password);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-100 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading...</p>
        </div>
      </div>
    );
  }

  if (!user) {
    return <AdminLogin onLogin={handleLoginSuccess} />;
  }

  return <AdminDashboard user={user} onLogout={logout} />;
};

export default AdminRoute;
