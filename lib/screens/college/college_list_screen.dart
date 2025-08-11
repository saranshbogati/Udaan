import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../models/college.dart';
import 'college_detail_screen.dart';

class CollegeListScreen extends StatefulWidget {
  const CollegeListScreen({Key? key}) : super(key: key);

  @override
  State<CollegeListScreen> createState() => _CollegeListScreenState();
}

class _CollegeListScreenState extends State<CollegeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<College> _colleges = [];
  List<College> _filteredColleges = [];
  String _selectedFilter = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadColleges();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadColleges() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock data for now
    _colleges = [
      College(
        id: 1,
        name: 'Tribhuvan University',
        location: 'Kathmandu',
        address: 'Kirtipur, Kathmandu',
        type: 'university',
        programs: ['Engineering', 'Medicine', 'Arts', 'Science'],
        images: [],
        averageRating: 4.2,
        reviewCount: 156,
        phone: '+977-1-4330433',
        email: 'info@tu.edu.np',
        description: 'The oldest and largest university in Nepal',
      ),
      College(
        id: 2,
        name: 'Kathmandu University',
        location: 'Dhulikhel',
        address: 'Dhulikhel, Kavre',
        type: 'university',
        programs: ['Engineering', 'Management', 'Science', 'Arts'],
        images: [],
        averageRating: 4.5,
        reviewCount: 89,
        phone: '+977-11-661399',
        email: 'info@ku.edu.np',
        description: 'A modern autonomous university in Nepal',
      ),
      College(
        id: 3,
        name: 'Pokhara University',
        location: 'Pokhara',
        address: 'Dhungepatan, Pokhara',
        type: 'university',
        programs: ['Engineering', 'Health Sciences', 'Management'],
        images: [],
        averageRating: 4.1,
        reviewCount: 67,
        phone: '+977-61-504050',
        email: 'info@pu.edu.np',
        description: 'University located in the beautiful city of Pokhara',
      ),
      College(
        id: 4,
        name: 'St. Xavier\'s College',
        location: 'Kathmandu',
        address: 'Maitighar, Kathmandu',
        type: 'college',
        programs: ['BBA', 'BBS', 'BA', '+2 Science'],
        images: [],
        averageRating: 4.6,
        reviewCount: 234,
        phone: '+977-1-4248770',
        email: 'info@sxc.edu.np',
        description: 'Prestigious college affiliated with Tribhuvan University',
      ),
      College(
        id: 5,
        name: 'KMC College',
        location: 'Kathmandu',
        address: 'Sinamangal, Kathmandu',
        type: 'college',
        programs: ['MBBS', 'BDS', 'BSc Nursing'],
        images: [],
        averageRating: 4.3,
        reviewCount: 145,
        phone: '+977-1-4000839',
        email: 'info@kmc.edu.np',
        description: 'Leading medical college in Nepal',
      ),
    ];

    _filteredColleges = _colleges;
    _isLoading = false;
    setState(() {});
  }

  void _onSearchChanged() {
    _filterColleges();
  }

  void _filterColleges() {
    String searchTerm = _searchController.text.toLowerCase();

    setState(() {
      _filteredColleges = _colleges.where((college) {
        bool matchesSearch = college.name.toLowerCase().contains(searchTerm) ||
            college.location.toLowerCase().contains(searchTerm) ||
            college.programs
                .any((program) => program.toLowerCase().contains(searchTerm));

        bool matchesFilter = _selectedFilter == 'All' ||
            college.type.toLowerCase() == _selectedFilter.toLowerCase();

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Udaan: Find colleges in Nepal'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Add notifications
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
                    ].map((filter) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: _selectedFilter == filter,
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

          // Results Count
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${_filteredColleges.length} colleges found',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),

          // College List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
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
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
            'No colleges found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
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
    Key? key,
    required this.college,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          college.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: const Color.fromARGB(255, 211, 73, 73),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              college.location,
                              style: TextStyle(
                                color: const Color.fromARGB(255, 39, 24, 24),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: college.type == 'university'
                          ? Colors.blue.shade100
                          : const Color.fromARGB(255, 12, 224, 19),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      college.type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: college.type == 'university'
                            ? Colors.blue.shade700
                            : Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              if (college.description != null)
                Text(
                  college.description!,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),

              // Programs
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: college.programs.take(3).map((program) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      program,
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
              if (college.programs.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${college.programs.length - 3} more programs',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              // Rating and Reviews
              Row(
                children: [
                  if (college.averageRating != null) ...[
                    RatingBarIndicator(
                      rating: college.averageRating!,
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      college.averageRating!.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${college.reviewCount} reviews)',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ] else
                    Text(
                      'No reviews yet',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
