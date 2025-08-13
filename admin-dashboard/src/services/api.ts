import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Types
export interface College {
  id: number;
  name: string;
  location: string;
  city?: string;
  state?: string;
  country: string;
  website?: string;
  phone?: string;
  email?: string;
  established_year?: number;
  college_type?: string;
  affiliation?: string;
  description?: string;
  logo_url?: string;
  images?: string[];
  programs?: string[];
  facilities?: string[];
  average_rating: number;
  total_reviews: number;
  college_metadata?: any;
  created_at: string;
}

export interface Review {
  id: number;
  college_id: number;
  user_id: number;
  user_name: string;
  rating: number;
  title: string;
  content: string;
  program?: string;
  graduation_year?: string;
  images?: string[];
  is_verified: boolean;
  likes_count: number;
  college_name?: string;
  created_at: string;
}

// API Functions
export const collegeApi = {
  getAll: (page = 1, limit = 20) => 
    api.get<{colleges: College[], total: number, page: number, pages: number}>(`/colleges?page=${page}&limit=${limit}`),
  
  getById: (id: number) => 
    api.get<College>(`/colleges/${id}`),
  
  create: (college: Partial<College>) => 
    api.post<College>('/colleges', college),
  
  update: (id: number, college: Partial<College>) => 
    api.put<College>(`/colleges/${id}`, college),
  
  delete: (id: number) => 
    api.delete(`/colleges/${id}`),
};

export const reviewApi = {
  getAll: (page = 1, limit = 20) => 
    api.get<{reviews: Review[], total: number, page: number, pages: number}>(`/reviews?page=${page}&limit=${limit}`),
  
  delete: (id: number) => 
    api.delete(`/reviews/${id}`),
};

export default api;