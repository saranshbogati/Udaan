import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../models/review.dart';
import '../../models/saved_college.dart';
import '../../models/college.dart';
import '../../widgets/review_card.dart';
import '../college/college_detail_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  UserStats? _userStats;
  List<Review> _userReviews = [];
  List<Review> _likedReviews = [];
  List<SavedCollege> _savedColleges = [];

  bool _isLoadingStats = true;
  bool _isLoadingReviews = true;
  bool _isLoadingLikedReviews = true;
  bool _isLoadingSavedColleges = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadUserStats(),
      _loadUserReviews(),
      _loadLikedReviews(),
      _loadSavedColleges(),
    ]);
  }

  Future<void> _loadUserStats() async {
    setState(() => _isLoadingStats = true);
    try {
      final result = await _apiService.getUserStats();
      if (result.isSuccess) {
        setState(() {
          _userStats = result.data;
          _isLoadingStats = false;
        });
      } else {
        setState(() => _isLoadingStats = false);
        _showErrorSnackBar('Failed to load stats: ${result.error}');
      }
    } catch (e) {
      setState(() => _isLoadingStats = false);
      _showErrorSnackBar('Error loading stats: $e');
    }
  }

  Future<void> _loadUserReviews() async {
    setState(() => _isLoadingReviews = true);
    try {
      final result = await _apiService.getUserReviews();
      if (result.isSuccess) {
        setState(() {
          _userReviews = result.data!.reviews;
          _isLoadingReviews = false;
        });
      } else {
        setState(() => _isLoadingReviews = false);
        _showErrorSnackBar('Failed to load reviews: ${result.error}');
      }
    } catch (e) {
      setState(() => _isLoadingReviews = false);
      _showErrorSnackBar('Error loading reviews: $e');
    }
  }

  Future<void> _loadLikedReviews() async {
    setState(() => _isLoadingLikedReviews = true);
    try {
      final result = await _apiService.getLikedReviews();
      if (result.isSuccess) {
        setState(() {
          _likedReviews = result.data!.reviews;
          _isLoadingLikedReviews = false;
        });
      } else {
        setState(() => _isLoadingLikedReviews = false);
        _showErrorSnackBar('Failed to load liked reviews: ${result.error}');
      }
    } catch (e) {
      setState(() => _isLoadingLikedReviews = false);
      _showErrorSnackBar('Error loading liked reviews: $e');
    }
  }

  Future<void> _loadSavedColleges() async {
    setState(() => _isLoadingSavedColleges = true);
    try {
      final result = await _apiService.getSavedColleges();
      if (result.isSuccess) {
        setState(() {
          _savedColleges = result.data!.savedColleges;
          _isLoadingSavedColleges = false;
        });
      } else {
        setState(() => _isLoadingSavedColleges = false);
        _showErrorSnackBar('Failed to load saved colleges: ${result.error}');
      }
    } catch (e) {
      setState(() => _isLoadingSavedColleges = false);
      _showErrorSnackBar('Error loading saved colleges: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteReview(Review review) async {
    try {
      final result = await _apiService.deleteReview(review.id);
      if (result.isSuccess) {
        setState(() {
          _userReviews.removeWhere((r) => r.id == review.id);
        });
        _showSuccessSnackBar('Review deleted successfully');
      } else {
        _showErrorSnackBar('Failed to delete review: ${result.error}');
      }
    } catch (e) {
      _showErrorSnackBar('Error deleting review: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not logged in'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 280,
              floating: false,
              pinned: true,
              backgroundColor: Colors.blue[600],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.blue[600]!, Colors.blue[800]!],
                    ),
                  ),
                  child: _buildProfileHeader(user),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    ).then((_) => _loadData());
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () {
                    authService.logout();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ];
        },
        body: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.blue[600],
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: Colors.blue[600],
                tabs: const [
                  Tab(text: 'My Reviews'),
                  Tab(text: 'Liked'),
                  Tab(text: 'Saved'),
                  Tab(text: 'Stats'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMyReviewsTab(),
                  _buildLikedReviewsTab(),
                  _buildSavedCollegesTab(),
                  _buildStatsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: user.profilePicture != null
                  ? NetworkImage(user.profilePicture!)
                  : null,
              child: user.profilePicture == null
                  ? Text(
                      user.username[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName ?? user.username,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '@${user.username}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            if (user.isVerified) ...[
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified, color: Colors.green, size: 20),
                  SizedBox(width: 4),
                  Text(
                    'Verified User',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMyReviewsTab() {
    if (_isLoadingReviews) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userReviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share your college experience to help others',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userReviews.length,
      itemBuilder: (context, index) {
        final review = _userReviews[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ReviewCard(
            review: review,
            showActions: true,
            onEdit: () {
              // Navigate to edit review screen
              Navigator.pushNamed(
                context,
                '/edit-review',
                arguments: review,
              ).then((_) => _loadUserReviews());
            },
            onDelete: () => _showDeleteConfirmation(review),
          ),
        );
      },
    );
  }

  Widget _buildLikedReviewsTab() {
    if (_isLoadingLikedReviews) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_likedReviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No liked reviews',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Like helpful reviews to save them here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _likedReviews.length,
      itemBuilder: (context, index) {
        final review = _likedReviews[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ReviewCard(review: review),
        );
      },
    );
  }

  Widget _buildSavedCollegesTab() {
    if (_isLoadingSavedColleges) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_savedColleges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No saved colleges',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save colleges you\'re interested in to view them here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _savedColleges.length,
      itemBuilder: (context, index) {
        final savedCollege = _savedColleges[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue[100],
              backgroundImage: savedCollege.collegeLogoUrl != null
                  ? NetworkImage(savedCollege.collegeLogoUrl!)
                  : null,
              child: savedCollege.collegeLogoUrl == null
                  ? Text(
                      savedCollege.collegeName[0].toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    )
                  : null,
            ),
            title: Text(
              savedCollege.collegeName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (savedCollege.collegeLocation != null)
                  Text(
                    savedCollege.collegeLocation!,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    RatingBarIndicator(
                      rating: savedCollege.collegeAverageRating,
                      itemBuilder: (context, index) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${savedCollege.collegeAverageRating.toStringAsFixed(1)} (${savedCollege.collegeTotalReviews} reviews)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Saved ${savedCollege.timeAgo}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {
                // Navigate to college detail
                // You'll need to convert SavedCollege to College or pass the ID
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CollegeDetailScreen(
                      college: College(
                        id: savedCollege.collegeId,
                        name: savedCollege.collegeName,
                        location: savedCollege.collegeLocation ?? '',
                        averageRating: savedCollege.collegeAverageRating,
                        totalReviews: savedCollege.collegeTotalReviews,
                        logoUrl: savedCollege.collegeLogoUrl,
                        isSavedByCurrentUser: true,
                      ),
                    ),
                  ),
                ).then((_) => _loadSavedColleges());
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsTab() {
    if (_isLoadingStats) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userStats == null) {
      return const Center(
        child: Text('Failed to load stats'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatsCard(),
          const SizedBox(height: 16),
          _buildAchievementsCard(),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Impact',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Reviews',
                    _userStats!.totalReviews.toString(),
                    Icons.rate_review,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Likes Received',
                    _userStats!.totalLikesReceived.toString(),
                    Icons.favorite,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'People Helped',
                    _userStats!.peopleHelped.toString(),
                    Icons.people,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Saved Colleges',
                    _userStats!.savedCollegesCount.toString(),
                    Icons.bookmark,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsCard() {
    final joinedDate = _userStats!.joinedDate;
    final membershipDuration = DateTime.now().difference(joinedDate).inDays;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Achievements',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildAchievementItem(
              'Early Adopter',
              'Joined ${_formatDate(joinedDate)}',
              Icons.schedule,
              Colors.purple,
            ),
            if (_userStats!.totalReviews >= 1)
              _buildAchievementItem(
                'Reviewer',
                'Wrote your first review',
                Icons.edit,
                Colors.blue,
              ),
            if (_userStats!.totalReviews >= 5)
              _buildAchievementItem(
                'Prolific Reviewer',
                'Wrote 5+ reviews',
                Icons.star,
                Colors.amber,
              ),
            if (_userStats!.totalLikesReceived >= 10)
              _buildAchievementItem(
                'Helpful Contributor',
                'Received 10+ likes',
                Icons.thumb_up,
                Colors.green,
              ),
            if (membershipDuration >= 30)
              _buildAchievementItem(
                'Loyal Member',
                'Member for ${membershipDuration} days',
                Icons.loyalty,
                Colors.orange,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem(String title, String subtitle, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _showDeleteConfirmation(Review review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReview(review);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
