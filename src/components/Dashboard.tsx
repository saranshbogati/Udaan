import React, { useState, useEffect } from 'react';
import { Building2, MessageSquare, Users, Star, TrendingUp, Eye } from 'lucide-react';
import { collegeApi, reviewApi } from '../services/api';
import type { College, Review } from '../services/api';

interface StatsCard {
  title: string;
  value: string;
  icon: React.ElementType;
  change?: string;
  changeType?: 'positive' | 'negative';
}

const Dashboard: React.FC = () => {
  const [stats, setStats] = useState({
    totalColleges: 0,
    totalReviews: 0,
    averageRating: 0,
  });
  const [recentColleges, setRecentColleges] = useState<College[]>([]);
  const [recentReviews, setRecentReviews] = useState<Review[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      setLoading(true);
      
      // Fetch colleges and reviews
      const [collegesResponse, reviewsResponse] = await Promise.all([
        collegeApi.getAll(1, 10),
        reviewApi.getAll(1, 10)
      ]);

      const colleges = collegesResponse.data.colleges;
      const reviews = reviewsResponse.data.reviews;

      // Calculate average rating
      const avgRating = colleges.length > 0 
        ? colleges.reduce((sum, college) => sum + college.average_rating, 0) / colleges.length 
        : 0;

      setStats({
        totalColleges: collegesResponse.data.total,
        totalReviews: reviewsResponse.data.total,
        averageRating: avgRating,
      });

      setRecentColleges(colleges.slice(0, 5));
      setRecentReviews(reviews.slice(0, 5));
    } catch (error) {
      console.error('Error fetching dashboard data:', error);
    } finally {
      setLoading(false);
    }
  };

  const statsCards: StatsCard[] = [
    {
      title: 'Total Colleges',
      value: stats.totalColleges.toString(),
      icon: Building2,
      change: '+12%',
      changeType: 'positive',
    },
    {
      title: 'Total Reviews',
      value: stats.totalReviews.toString(),
      icon: MessageSquare,
      change: '+8%',
      changeType: 'positive',
    },
    {
      title: 'Average Rating',
      value: stats.averageRating.toFixed(1),
      icon: Star,
      change: '+0.2',
      changeType: 'positive',
    },
    {
      title: 'Active Users',
      value: '1,234',
      icon: Users,
      change: '+15%',
      changeType: 'positive',
    },
  ];

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-600 mt-2">Welcome to the Udaan admin dashboard</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {statsCards.map((stat, index) => {
          const Icon = stat.icon;
          return (
            <div key={index} className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">{stat.title}</p>
                  <p className="text-3xl font-bold text-gray-900 mt-2">{stat.value}</p>
                  {stat.change && (
                    <div className="flex items-center mt-2">
                      <TrendingUp className={`w-4 h-4 mr-1 ${
                        stat.changeType === 'positive' ? 'text-green-500' : 'text-red-500'
                      }`} />
                      <span className={`text-sm font-medium ${
                        stat.changeType === 'positive' ? 'text-green-600' : 'text-red-600'
                      }`}>
                        {stat.change}
                      </span>
                      <span className="text-gray-500 text-sm ml-1">from last month</span>
                    </div>
                  )}
                </div>
                <div className="bg-primary-100 rounded-lg p-3">
                  <Icon className="w-6 h-6 text-primary-600" />
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Recent Activity */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Colleges */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200">
          <div className="p-6 border-b border-gray-200">
            <h2 className="text-lg font-semibold text-gray-900">Recent Colleges</h2>
          </div>
          <div className="p-6">
            <div className="space-y-4">
              {recentColleges.map((college) => (
                <div key={college.id} className="flex items-center justify-between">
                  <div className="flex items-center space-x-3">
                    <div className="bg-primary-100 rounded-full p-2">
                      <Building2 className="w-4 h-4 text-primary-600" />
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-900">{college.name}</p>
                      <p className="text-xs text-gray-500">{college.location}</p>
                    </div>
                  </div>
                  <div className="flex items-center space-x-2">
                    <Star className="w-4 h-4 text-yellow-400" />
                    <span className="text-sm text-gray-600">{college.average_rating.toFixed(1)}</span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Recent Reviews */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200">
          <div className="p-6 border-b border-gray-200">
            <h2 className="text-lg font-semibold text-gray-900">Recent Reviews</h2>
          </div>
          <div className="p-6">
            <div className="space-y-4">
              {recentReviews.map((review) => (
                <div key={review.id} className="border-b border-gray-100 last:border-0 pb-4 last:pb-0">
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center space-x-2">
                        <p className="text-sm font-medium text-gray-900">{review.user_name}</p>
                        <div className="flex items-center">
                          {[...Array(5)].map((_, i) => (
                            <Star
                              key={i}
                              className={`w-3 h-3 ${
                                i < review.rating ? 'text-yellow-400' : 'text-gray-300'
                              }`}
                              fill="currentColor"
                            />
                          ))}
                        </div>
                      </div>
                      <p className="text-xs text-gray-500 mt-1">{review.college_name}</p>
                      <p className="text-sm text-gray-700 mt-2 line-clamp-2">{review.title}</p>
                    </div>
                    <button className="ml-4 text-primary-600 hover:text-primary-700">
                      <Eye className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;