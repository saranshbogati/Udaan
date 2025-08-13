# Udaan Admin Dashboard

A modern admin dashboard for managing the Udaan college review application. Built with React, TypeScript, and Tailwind CSS.

## Features

### 📊 **Dashboard Overview**
- Real-time statistics (total colleges, reviews, users, average rating)
- Recent colleges and reviews overview
- Visual statistics cards with trend indicators

### 🏛️ **College Management**
- **CRUD Operations**: Create, Read, Update, Delete colleges
- **Search & Filter**: Find colleges by name, location, or type
- **Detailed Information**: Manage college details, contact info, and metadata
- **Pagination**: Efficient data browsing with pagination

### 📝 **Review Management**
- **View All Reviews**: Browse all user reviews with search functionality
- **Review Details**: View complete review information including images
- **Delete Reviews**: Remove inappropriate or spam reviews
- **Filter Options**: Search by user, college, or review content
- **Verification Status**: See verified reviews and user programs

### 🎨 **Modern UI/UX**
- Clean, responsive design with Tailwind CSS
- Intuitive navigation with sidebar layout
- Modal dialogs for detailed views and editing
- Loading states and error handling
- Mobile-friendly responsive design

## Technology Stack

- **Frontend**: React 18 with TypeScript
- **Styling**: Tailwind CSS
- **Routing**: React Router v6
- **HTTP Client**: Axios
- **Icons**: Lucide React
- **Backend**: FastAPI (existing)

## Prerequisites

Before running the admin dashboard, ensure you have:

1. **Node.js** (v16 or later)
2. **npm** or **yarn**
3. **FastAPI backend** running on `http://localhost:8000`

## Installation & Setup

1. **Navigate to the admin dashboard directory:**
   ```bash
   cd admin-dashboard
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure environment:**
   - Copy `.env.example` to `.env`
   - Update `REACT_APP_API_URL` if your backend runs on a different port
   ```
   REACT_APP_API_URL=http://localhost:8000
   ```

4. **Start the development server:**
   ```bash
   npm start
   ```

5. **Open your browser:**
   Navigate to `http://localhost:3000`

## Project Structure

```
admin-dashboard/
├── src/
│   ├── components/          # React components
│   │   ├── Layout.tsx      # Main layout with sidebar
│   │   ├── Dashboard.tsx   # Dashboard overview
│   │   ├── Colleges.tsx    # College management
│   │   └── Reviews.tsx     # Review management
│   ├── services/
│   │   └── api.ts          # API service layer
│   ├── App.tsx             # Main App component
│   └── index.tsx           # Entry point
├── public/                 # Static assets
├── tailwind.config.js      # Tailwind configuration
└── package.json           # Dependencies
```

## API Integration

The dashboard connects to your existing FastAPI backend using these endpoints:

### Colleges
- `GET /colleges` - List colleges with pagination
- `POST /colleges` - Create new college
- `PUT /colleges/{id}` - Update college
- `DELETE /colleges/{id}` - Delete college

### Reviews
- `GET /reviews` - List reviews with pagination
- `GET /colleges/{id}/reviews` - Get college reviews
- `DELETE /reviews/{id}` - Delete review

### Dashboard Stats
- `GET /colleges` - For college statistics
- `GET /reviews` - For review statistics

## Available Scripts

- `npm start` - Start development server
- `npm build` - Build for production
- `npm test` - Run tests
- `npm run eject` - Eject from Create React App

## Features in Detail

### Dashboard Statistics
- **Real-time Metrics**: Total colleges, reviews, and average ratings
- **Trend Indicators**: Visual indicators showing growth/decline
- **Recent Activity**: Quick view of latest colleges and reviews

### College Management
- **Add New Colleges**: Form-based college creation with validation
- **Edit Existing**: Update college information with pre-filled forms
- **Search & Filter**: Real-time search by name, location, or type
- **Visual Display**: College cards with ratings and review counts

### Review Management
- **Grid Layout**: Card-based review display for easy scanning
- **Detailed View**: Modal with complete review information
- **Quick Actions**: One-click view and delete operations
- **Search Function**: Find reviews by content, user, or college

## Customization

### Styling
- Modify `tailwind.config.js` for custom colors and themes
- Update component classes for design changes
- Colors follow a primary blue theme with gray accents

### API Configuration
- Update `src/services/api.ts` for different endpoint structures
- Modify base URL in `.env` file
- Add authentication headers if needed

## Future Enhancements

Potential features for future versions:

- **User Management**: Add, edit, and manage user accounts
- **Analytics Dashboard**: Charts and graphs for data visualization
- **Review Approval**: Workflow for reviewing flagged content
- **Bulk Operations**: Mass import/export of colleges
- **Advanced Filtering**: Date ranges, rating filters, location-based filters
- **Notifications**: Real-time updates for new reviews/colleges
- **Role Management**: Different admin levels and permissions

## Troubleshooting

### Common Issues

1. **API Connection Error**:
   - Ensure FastAPI backend is running on the correct port
   - Check CORS configuration in your FastAPI app
   - Verify `.env` file has correct API URL

2. **Build Errors**:
   - Clear node_modules and reinstall: `rm -rf node_modules && npm install`
   - Check for TypeScript errors in the console

3. **Styling Issues**:
   - Ensure Tailwind CSS is properly configured
   - Check for conflicting CSS classes

### CORS Configuration

If you encounter CORS issues, add this to your FastAPI app:

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # React dev server
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is part of the Udaan college review application.
