import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:udaan/services/api_service.dart';
import '../../models/college.dart';
import 'college_detail_screen.dart';

class CollegeListScreen extends StatefulWidget {
  const CollegeListScreen({super.key});

  @override
  State<CollegeListScreen> createState() => _CollegeListScreenState();
}

class _CollegeListScreenState extends State<CollegeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  List<College> _colleges = [];
  List<College> _filteredColleges = [];
  String _selectedFilter = 'All';
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadColleges();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadColleges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiService.getColleges(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        limit: 20,
      );

      if (result.isSuccess) {
        setState(() {
          _colleges = result.data!.colleges;
          _filteredColleges = _colleges;
          _isLoading = false;
        });
        _filterColleges();
      } else {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _filterColleges();
  }

  void _filterColleges() {
    String searchTerm = _searchController.text.toLowerCase();

    setState(() {
      _filteredColleges = _colleges.where((college) {
        bool matchesSearch = searchTerm.isEmpty ||
            college.name.toLowerCase().contains(searchTerm) ||
            college.location.toLowerCase().contains(searchTerm) ||
            college.programs
                .any((program) => program.toLowerCase().contains(searchTerm));

        bool matchesFilter = _selectedFilter == 'All' ||
            (college.collegeType?.toLowerCase() ==
                _selectedFilter.toLowerCase());

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  Future<void> _refreshColleges() async {
    _searchQuery = '';
    _searchController.clear();
    setState(() {
      _selectedFilter = 'All';
    });
    await _loadColleges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Colleges in Nepal'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Add notifications or profile
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search colleges, locations, programs...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 12),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'All',
                      'University',
                      'College',
                      'Institute',
                    ].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            filter,
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.white : Colors.grey[700],
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: Theme.of(context).primaryColor,
                          backgroundColor: Colors.grey.shade200,
                          checkmarkColor: Colors.white,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                            _filterColleges();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Results Count and Refresh
          if (!_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_filteredColleges.length} colleges found',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: _refreshColleges,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),

          // College List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshColleges,
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading colleges...'),
                        ],
                      ),
                    )
                  : _filteredColleges.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredColleges.length,
                          itemBuilder: (context, index) {
                            return CollegeCard(
                              college: _filteredColleges[index],
                              onTap: () => _navigateToCollegeDetail(
                                  _filteredColleges[index]),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    String subtitle;

    if (_searchController.text.isNotEmpty) {
      message = 'No colleges found for "${_searchController.text}"';
      subtitle = 'Try different keywords or clear the search';
    } else if (_selectedFilter != 'All') {
      message = 'No ${_selectedFilter.toLowerCase()}s found';
      subtitle = 'Try changing the filter or refresh the list';
    } else {
      message = 'No colleges available';
      subtitle = 'Pull to refresh or try again later';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _refreshColleges,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCollegeDetail(College college) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CollegeDetailScreen(college: college),
      ),
    );
  }
}

class CollegeCard extends StatelessWidget {
  final College college;
  final VoidCallback onTap;

  const CollegeCard({
    super.key,
    required this.college,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image or icon
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: college.images.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: college.images.first,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 80,
                          width: 80,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.school,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        ),
                      )
                    : Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.school,
                          size: 40,
                          color: Colors.blue.shade400,
                        ),
                      ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      college.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            college.location,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // College Type
                    if (college.collegeType != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              college.collegeType!.toLowerCase() == 'university'
                                  ? Colors.blue.shade50
                                  : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: college.collegeType!.toLowerCase() ==
                                    'university'
                                ? Colors.blue.shade200
                                : Colors.green.shade200,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          college.collegeType!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: college.collegeType!.toLowerCase() ==
                                    'university'
                                ? Colors.blue.shade700
                                : Colors.green.shade700,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),

                    // Description
                    if (college.description != null &&
                        college.description!.isNotEmpty)
                      Text(
                        college.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    const SizedBox(height: 8),

                    // Rating
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: college.averageRating ?? 0,
                          itemBuilder: (_, __) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          college.averageRating != null
                              ? '${college.averageRating.toStringAsFixed(1)} (${college.totalReviews ?? 0})'
                              : 'No ratings',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
