import React, { useState, useEffect } from "react";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
} from "recharts";
import {
  Plus,
  Edit,
  Trash2,
  Eye,
  Users,
  Building2,
  MessageSquare,
  Star,
  Search,
  X,
  Save,
  LogOut,
} from "lucide-react";
import { collegeApi, reviewApi, College, Review } from "../services/api";
import { User } from "../contexts/AuthContext";

interface DashboardStats {
  totalColleges: number;
  totalReviews: number;
  totalUsers: number;
  averageRating: number;
}

interface AdminDashboardProps {
  onLogout?: () => void;
  user?: User;
}

const AdminDashboard: React.FC<AdminDashboardProps> = ({ onLogout }) => {
  const [activeTab, setActiveTab] = useState("overview");
  const [colleges, setColleges] = useState<College[]>([]);
  const [reviews, setReviews] = useState<Review[]>([]);
  const [stats, setStats] = useState<DashboardStats>({
    totalColleges: 0,
    totalReviews: 0,
    totalUsers: 0,
    averageRating: 0,
  });
  const [loading, setLoading] = useState(false);
  const [showModal, setShowModal] = useState(false);
  const [modalType, setModalType] = useState("");
  const [selectedItem, setSelectedItem] = useState<any>(null);
  const [searchTerm, setSearchTerm] = useState("");
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);

  // Load data on component mount
  useEffect(() => {
    loadDashboardData();
  }, []);

  useEffect(() => {
    if (activeTab === "colleges") {
      loadColleges();
    } else if (activeTab === "reviews") {
      loadReviews();
    }
  }, [activeTab, page]);

  const loadDashboardData = async () => {
    try {
      setLoading(true);

      // Load initial data for stats
      const [collegesRes, reviewsRes] = await Promise.all([
        collegeApi.getAll(1, 1),
        reviewApi.getAll(1, 1),
      ]);

      // Calculate basic stats from the response
      setStats({
        totalColleges: collegesRes.data.total,
        totalReviews: reviewsRes.data.total,
        totalUsers: 0, // You'll need to add a users endpoint
        averageRating: 4.2, // Calculate from actual data
      });
    } catch (error) {
      console.error("Error loading dashboard data:", error);
    } finally {
      setLoading(false);
    }
  };

  const loadColleges = async () => {
    try {
      setLoading(true);
      const response = await collegeApi.getAll(page, 20);
      setColleges(response.data.colleges);
      setTotalPages(response.data.pages);
    } catch (error) {
      console.error("Error loading colleges:", error);
    } finally {
      setLoading(false);
    }
  };

  const loadReviews = async () => {
    try {
      setLoading(true);
      const response = await reviewApi.getAll(page, 20);
      setReviews(response.data.reviews);
      setTotalPages(response.data.pages);
    } catch (error) {
      console.error("Error loading reviews:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleCreateCollege = async (collegeData: Partial<College>) => {
    try {
      await collegeApi.create(collegeData);
      setShowModal(false);
      loadColleges();
      loadDashboardData(); // Refresh stats
    } catch (error) {
      console.error("Error creating college:", error);
    }
  };

  const handleUpdateCollege = async (collegeData: Partial<College>) => {
    try {
      if (selectedItem?.id) {
        await collegeApi.update(selectedItem.id, collegeData);
        setShowModal(false);
        loadColleges();
      }
    } catch (error) {
      console.error("Error updating college:", error);
    }
  };

  const handleDeleteCollege = async (id: number) => {
    if (window.confirm("Are you sure you want to delete this college?")) {
      try {
        await collegeApi.delete(id);
        loadColleges();
        loadDashboardData(); // Refresh stats
      } catch (error) {
        console.error("Error deleting college:", error);
      }
    }
  };

  const handleDeleteReview = async (id: number) => {
    if (window.confirm("Are you sure you want to delete this review?")) {
      try {
        await reviewApi.delete(id);
        loadReviews();
        loadDashboardData(); // Refresh stats
      } catch (error) {
        console.error("Error deleting review:", error);
      }
    }
  };

  const openModal = (type: string, item: any = null) => {
    setModalType(type);
    setSelectedItem(item);
    setShowModal(true);
  };

  const filteredColleges = colleges.filter(
    (college) =>
      college.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      college.location?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      college.city?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const filteredReviews = reviews.filter(
    (review) =>
      review.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      review.content.toLowerCase().includes(searchTerm.toLowerCase()) ||
      review.college_name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      review.user_name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const StatCard: React.FC<{
    title: string;
    value: number;
    icon: React.ComponentType<any>;
    color: string;
  }> = ({ title, value, icon: Icon, color }) => (
    <div
      className="bg-white rounded-lg shadow-md p-6 border-l-4"
      style={{ borderLeftColor: color }}
    >
      <div className="flex items-center justify-between">
        <div>
          <p className="text-gray-600 text-sm font-medium">{title}</p>
          <p className="text-3xl font-bold text-gray-900">{value}</p>
        </div>
        <Icon className="w-8 h-8" style={{ color }} />
      </div>
    </div>
  );

  return (
    <div className="min-h-screen bg-gray-100">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-4">
            <h1 className="text-2xl font-bold text-gray-900">
              🏔️ Udaan Admin Dashboard
            </h1>
            <div className="flex items-center space-x-4">
              <div className="text-sm text-gray-600">
                Nepal College Review Platform
              </div>
              {onLogout && (
                <button
                  onClick={onLogout}
                  className="flex items-center px-3 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-md transition-colors"
                  title="Logout"
                >
                  <LogOut className="w-4 h-4 mr-2" />
                  Logout
                </button>
              )}
            </div>
          </div>
        </div>
      </header>

      {/* Navigation */}
      <nav className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex space-x-8">
            {[
              { id: "overview", label: "Overview", icon: BarChart },
              { id: "colleges", label: "Colleges", icon: Building2 },
              { id: "reviews", label: "Reviews", icon: MessageSquare },
              { id: "users", label: "Users", icon: Users },
            ].map(({ id, label, icon: Icon }) => (
              <button
                key={id}
                onClick={() => setActiveTab(id)}
                className={`flex items-center py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === id
                    ? "border-blue-500 text-blue-600"
                    : "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
                }`}
              >
                <Icon className="w-4 h-4 mr-2" />
                {label}
              </button>
            ))}
          </div>
        </div>
      </nav>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {loading && (
          <div className="flex justify-center items-center py-8">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
          </div>
        )}

        {activeTab === "overview" && (
          <div className="space-y-6">
            {/* Stats Cards */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              <StatCard
                title="Total Colleges"
                value={stats.totalColleges}
                icon={Building2}
                color="#3b82f6"
              />
              <StatCard
                title="Total Reviews"
                value={stats.totalReviews}
                icon={MessageSquare}
                color="#10b981"
              />
              <StatCard
                title="Total Users"
                value={stats.totalUsers}
                icon={Users}
                color="#8b5cf6"
              />
              <StatCard
                title="Average Rating"
                value={stats.averageRating}
                icon={Star}
                color="#f59e0b"
              />
            </div>

            {/* Recent Activity */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <div className="bg-white p-6 rounded-lg shadow-md">
                <h3 className="text-lg font-semibold mb-4">Recent Colleges</h3>
                <div className="space-y-3">
                  {colleges.slice(0, 5).map((college) => (
                    <div
                      key={college.id}
                      className="flex items-center justify-between p-3 bg-gray-50 rounded"
                    >
                      <div>
                        <p className="font-medium">{college.name}</p>
                        <p className="text-sm text-gray-500">
                          {college.city}, {college.state}
                        </p>
                      </div>
                      <div className="flex items-center">
                        <Star className="w-4 h-4 text-yellow-400 mr-1" />
                        <span className="text-sm">
                          {college.average_rating.toFixed(1)}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              <div className="bg-white p-6 rounded-lg shadow-md">
                <h3 className="text-lg font-semibold mb-4">Recent Reviews</h3>
                <div className="space-y-3">
                  {reviews.slice(0, 5).map((review) => (
                    <div key={review.id} className="p-3 bg-gray-50 rounded">
                      <div className="flex items-center justify-between mb-2">
                        <p className="font-medium truncate">{review.title}</p>
                        <div className="flex items-center">
                          <Star className="w-4 h-4 text-yellow-400 mr-1" />
                          <span className="text-sm">{review.rating}</span>
                        </div>
                      </div>
                      <p className="text-sm text-gray-500">
                        {review.college_name} • by {review.user_name}
                      </p>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        )}

        {activeTab === "colleges" && (
          <CollegesTab
            colleges={filteredColleges}
            searchTerm={searchTerm}
            setSearchTerm={setSearchTerm}
            onEdit={(college) => openModal("edit-college", college)}
            onCreate={() => openModal("create-college")}
            onDelete={handleDeleteCollege}
            page={page}
            totalPages={totalPages}
            onPageChange={setPage}
          />
        )}

        {activeTab === "reviews" && (
          <ReviewsTab
            reviews={filteredReviews}
            searchTerm={searchTerm}
            setSearchTerm={setSearchTerm}
            onView={(review) => openModal("view-review", review)}
            onDelete={handleDeleteReview}
            page={page}
            totalPages={totalPages}
            onPageChange={setPage}
          />
        )}

        {activeTab === "users" && (
          <div className="bg-white rounded-lg shadow-md p-6">
            <h2 className="text-xl font-bold mb-4">User Management</h2>
            <p className="text-gray-600">
              User management functionality will be implemented once user
              endpoints are available.
            </p>
          </div>
        )}
      </main>

      {/* Modals */}
      {showModal && (
        <>
          {(modalType === "create-college" || modalType === "edit-college") && (
            <CollegeForm
              college={modalType === "edit-college" ? selectedItem : null}
              onSubmit={
                modalType === "edit-college"
                  ? handleUpdateCollege
                  : handleCreateCollege
              }
              onClose={() => setShowModal(false)}
            />
          )}

          {modalType === "view-review" && selectedItem && (
            <ReviewModal
              review={selectedItem}
              onClose={() => setShowModal(false)}
            />
          )}
        </>
      )}
    </div>
  );
};

// College Form Component
const CollegeForm: React.FC<{
  college?: College | null;
  onSubmit: (data: Partial<College>) => void;
  onClose: () => void;
}> = ({ college, onSubmit, onClose }) => {
  const [formData, setFormData] = useState({
    name: college?.name || "",
    location: college?.location || "",
    city: college?.city || "",
    state: college?.state || "",
    country: "Nepal",
    established_year: college?.established_year || "",
    college_type: college?.college_type || "Public",
    description: college?.description || "",
    website: college?.website || "",
    phone: college?.phone || "",
    email: college?.email || "",
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Convert established_year to number if it's a string
    const submitData = {
      ...formData,
      established_year: formData.established_year
        ? Number(formData.established_year)
        : undefined,
    };
    onSubmit(submitData);
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-bold">
            {college ? "Edit College" : "Add New College"}
          </h2>
          <button
            onClick={onClose}
            className="text-gray-500 hover:text-gray-700"
          >
            <X className="w-6 h-6" />
          </button>
        </div>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                College Name *
              </label>
              <input
                type="text"
                required
                value={formData.name}
                onChange={(e) =>
                  setFormData({ ...formData, name: e.target.value })
                }
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Location
              </label>
              <input
                type="text"
                value={formData.location}
                onChange={(e) =>
                  setFormData({ ...formData, location: e.target.value })
                }
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                City
              </label>
              <input
                type="text"
                value={formData.city}
                onChange={(e) =>
                  setFormData({ ...formData, city: e.target.value })
                }
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Province
              </label>
              <select
                value={formData.state}
                onChange={(e) =>
                  setFormData({ ...formData, state: e.target.value })
                }
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Select Province</option>
                <option value="Koshi">Koshi</option>
                <option value="Madhesh">Madhesh</option>
                <option value="Bagmati">Bagmati</option>
                <option value="Gandaki">Gandaki</option>
                <option value="Lumbini">Lumbini</option>
                <option value="Karnali">Karnali</option>
                <option value="Sudurpashchim">Sudurpashchim</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Established Year
              </label>
              <input
                type="number"
                value={formData.established_year}
                onChange={(e) =>
                  setFormData({
                    ...formData,
                    established_year: Number(e.target.value),
                  })
                }
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                College Type
              </label>
              <select
                value={formData.college_type}
                onChange={(e) =>
                  setFormData({ ...formData, college_type: e.target.value })
                }
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="Public">Public</option>
                <option value="Private">Private</option>
                <option value="Community">Community</option>
              </select>
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Website
              </label>
              <input
                type="url"
                value={formData.website}
                onChange={(e) =>
                  setFormData({ ...formData, website: e.target.value })
                }
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Phone
              </label>
              <input
                type="tel"
                value={formData.phone}
                onChange={(e) =>
                  setFormData({ ...formData, phone: e.target.value })
                }
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Email
              </label>
              <input
                type="email"
                value={formData.email}
                onChange={(e) =>
                  setFormData({ ...formData, email: e.target.value })
                }
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Description
            </label>
            <textarea
              rows={3}
              value={formData.description}
              onChange={(e) =>
                setFormData({ ...formData, description: e.target.value })
              }
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div className="flex justify-end space-x-2 pt-4">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 text-gray-600 border border-gray-300 rounded-md hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 flex items-center"
            >
              <Save className="w-4 h-4 mr-2" />
              {college ? "Update" : "Create"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

// Colleges Tab Component
const CollegesTab: React.FC<{
  colleges: College[];
  searchTerm: string;
  setSearchTerm: (term: string) => void;
  onEdit: (college: College) => void;
  onCreate: () => void;
  onDelete: (id: number) => void;
  page: number;
  totalPages: number;
  onPageChange: (page: number) => void;
}> = ({
  colleges,
  searchTerm,
  setSearchTerm,
  onEdit,
  onCreate,
  onDelete,
  page,
  totalPages,
  onPageChange,
}) => (
  <div className="space-y-6">
    <div className="flex justify-between items-center">
      <div className="flex items-center space-x-4">
        <div className="relative">
          <Search className="w-5 h-5 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
          <input
            type="text"
            placeholder="Search colleges..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="pl-10 pr-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>
      </div>
      <button
        onClick={onCreate}
        className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 flex items-center"
      >
        <Plus className="w-4 h-4 mr-2" />
        Add College
      </button>
    </div>

    <div className="bg-white rounded-lg shadow-md overflow-hidden">
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                College
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Location
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Type
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Rating
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Reviews
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {colleges.map((college) => (
              <tr key={college.id} className="hover:bg-gray-50">
                <td className="px-6 py-4 whitespace-nowrap">
                  <div>
                    <div className="text-sm font-medium text-gray-900">
                      {college.name}
                    </div>
                    <div className="text-sm text-gray-500">
                      Est. {college.established_year}
                    </div>
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {college.city}, {college.state}
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span
                    className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                      college.college_type === "Public"
                        ? "bg-blue-100 text-blue-800"
                        : college.college_type === "Private"
                        ? "bg-green-100 text-green-800"
                        : "bg-yellow-100 text-yellow-800"
                    }`}
                  >
                    {college.college_type}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  <div className="flex items-center">
                    <Star className="w-4 h-4 text-yellow-400 mr-1" />
                    {college.average_rating.toFixed(1)}
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {college.total_reviews}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  <div className="flex space-x-2">
                    <button
                      onClick={() => onEdit(college)}
                      className="text-blue-600 hover:text-blue-900"
                    >
                      <Edit className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => onDelete(college.id)}
                      className="text-red-600 hover:text-red-900"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>

    {/* Pagination */}
    {totalPages > 1 && (
      <div className="flex justify-center space-x-2">
        {Array.from({ length: totalPages }, (_, i) => i + 1).map((pageNum) => (
          <button
            key={pageNum}
            onClick={() => onPageChange(pageNum)}
            className={`px-3 py-1 rounded ${
              page === pageNum
                ? "bg-blue-600 text-white"
                : "bg-white text-gray-700 border border-gray-300 hover:bg-gray-50"
            }`}
          >
            {pageNum}
          </button>
        ))}
      </div>
    )}
  </div>
);

// Reviews Tab Component
const ReviewsTab: React.FC<{
  reviews: Review[];
  searchTerm: string;
  setSearchTerm: (term: string) => void;
  onView: (review: Review) => void;
  onDelete: (id: number) => void;
  page: number;
  totalPages: number;
  onPageChange: (page: number) => void;
}> = ({
  reviews,
  searchTerm,
  setSearchTerm,
  onView,
  onDelete,
  page,
  totalPages,
  onPageChange,
}) => (
  <div className="space-y-6">
    <div className="flex justify-between items-center">
      <div className="relative">
        <Search className="w-5 h-5 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
        <input
          type="text"
          placeholder="Search reviews..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="pl-10 pr-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>
    </div>

    <div className="bg-white rounded-lg shadow-md overflow-hidden">
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Review
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                College
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                User
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Rating
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Status
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {reviews.map((review) => (
              <tr key={review.id} className="hover:bg-gray-50">
                <td className="px-6 py-4">
                  <div className="max-w-xs">
                    <div className="text-sm font-medium text-gray-900">
                      {review.title}
                    </div>
                    <div className="text-sm text-gray-500 truncate">
                      {review.content}
                    </div>
                    <div className="text-xs text-gray-400 mt-1">
                      {review.program} • {review.graduation_year}
                    </div>
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {review.college_name}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {review.user_name}
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="flex items-center">
                    <Star className="w-4 h-4 text-yellow-400 mr-1" />
                    <span className="text-sm text-gray-900">
                      {review.rating}
                    </span>
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span
                    className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                      review.is_verified
                        ? "bg-green-100 text-green-800"
                        : "bg-yellow-100 text-yellow-800"
                    }`}
                  >
                    {review.is_verified ? "Verified" : "Pending"}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  <div className="flex space-x-2">
                    <button
                      onClick={() => onView(review)}
                      className="text-blue-600 hover:text-blue-900"
                    >
                      <Eye className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => onDelete(review.id)}
                      className="text-red-600 hover:text-red-900"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>

    {/* Pagination */}
    {totalPages > 1 && (
      <div className="flex justify-center space-x-2">
        {Array.from({ length: totalPages }, (_, i) => i + 1).map((pageNum) => (
          <button
            key={pageNum}
            onClick={() => onPageChange(pageNum)}
            className={`px-3 py-1 rounded ${
              page === pageNum
                ? "bg-blue-600 text-white"
                : "bg-white text-gray-700 border border-gray-300 hover:bg-gray-50"
            }`}
          >
            {pageNum}
          </button>
        ))}
      </div>
    )}
  </div>
);

// Review Modal Component
const ReviewModal: React.FC<{
  review: Review;
  onClose: () => void;
}> = ({ review, onClose }) => (
  <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
    <div className="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-xl font-bold">Review Details</h2>
        <button onClick={onClose} className="text-gray-500 hover:text-gray-700">
          <X className="w-6 h-6" />
        </button>
      </div>

      <div className="space-y-4">
        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              College
            </label>
            <p className="text-sm text-gray-900">{review.college_name}</p>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              User
            </label>
            <p className="text-sm text-gray-900">{review.user_name}</p>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Program
            </label>
            <p className="text-sm text-gray-900">{review.program}</p>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Graduation Year
            </label>
            <p className="text-sm text-gray-900">{review.graduation_year}</p>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Rating
            </label>
            <div className="flex items-center">
              <Star className="w-4 h-4 text-yellow-400 mr-1" />
              <p className="text-sm text-gray-900">{review.rating}/5</p>
            </div>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Likes
            </label>
            <p className="text-sm text-gray-900">{review.likes_count}</p>
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Title
          </label>
          <p className="text-sm text-gray-900">{review.title}</p>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Content
          </label>
          <p className="text-sm text-gray-900 whitespace-pre-wrap">
            {review.content}
          </p>
        </div>

        <div className="flex items-center justify-between pt-4 border-t">
          <div className="flex items-center space-x-4">
            <span
              className={`inline-flex px-3 py-1 text-sm font-semibold rounded-full ${
                review.is_verified
                  ? "bg-green-100 text-green-800"
                  : "bg-yellow-100 text-yellow-800"
              }`}
            >
              {review.is_verified ? "Verified" : "Pending Verification"}
            </span>
          </div>
          <p className="text-sm text-gray-500">
            Posted on {new Date(review.created_at).toLocaleDateString()}
          </p>
        </div>
      </div>

      <div className="flex justify-end space-x-2 pt-6">
        <button
          onClick={onClose}
          className="px-4 py-2 text-gray-600 border border-gray-300 rounded-md hover:bg-gray-50"
        >
          Close
        </button>
      </div>
    </div>
  </div>
);

export default AdminDashboard;
