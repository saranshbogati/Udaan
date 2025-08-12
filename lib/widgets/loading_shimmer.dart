import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CollegeCardSkeleton extends StatelessWidget {
  const CollegeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 20, color: Colors.white),
              const SizedBox(height: 8),
              Container(height: 16, width: 150, color: Colors.white),
              const SizedBox(height: 8),
              Container(height: 16, width: 100, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
