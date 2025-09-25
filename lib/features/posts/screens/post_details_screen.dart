import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../main.dart';
import '../models/post.dart';
import '../notifiers/approved_post_notifier.dart';

class PostDetailsScreen extends ConsumerStatefulWidget {
  final String id;
  const PostDetailsScreen({super.key, required this.id});

  @override
  ConsumerState<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends ConsumerState<PostDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Post? post;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  Future<void> _loadPost() async {
    final intId = int.tryParse(widget.id);
    if (intId == null) return;

    final fetchedPost = await ref
        .read(approvedPostsProvider.notifier)
        .getPostById(intId);
    setState(() {
      post = fetchedPost;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (post == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text('Post not found')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: kIsWeb ? 0 : 48),
                  _buildHeader(context),
                  const SizedBox(height: 32),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 900;
                      return isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 3, child: _buildImages()),
                                const SizedBox(width: 32),
                                Expanded(flex: 2, child: _buildDetails()),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildImages(),
                                const SizedBox(height: 24),
                                _buildDetails(),
                              ],
                            );
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildDescription(),
                  const SizedBox(height: 32),
                  _buildReviews(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.push(RouteNames.posts),
          child: CircleAvatar(
            backgroundColor: Colors.grey.shade100,
            child: const Icon(CupertinoIcons.arrow_left, color: Colors.black87),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post!.name,
                style: kIsWeb
                    ? Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      )
                    : Theme.of(context).textTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                post!.address,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () {},
          child: const Text('Book Now', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildImages() {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: PageView.builder(
            controller: _pageController,
            itemCount: post!.imageUrls.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) => ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(post!.imageUrls[index], fit: BoxFit.cover),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(post!.imageUrls.length, (index) {
            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                setState(() => _currentIndex = index);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _currentIndex == index
                        ? Colors.black87
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    post!.imageUrls[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Host & Pricing'),
        _buildHostTile(),
        SizedBox(height: 18),
        _buildPricing(),
        SizedBox(height: 18),
        _buildCaution(),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Description'),
        const SizedBox(height: 12),
        Text(
          post!.description,
          style: TextStyle(color: Colors.grey.shade800, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPricing() {
    final prices = [
      {'label': 'Daily', 'value': post!.dailyPrice},
      {'label': 'Weekly', 'value': post!.weeklyPrice},
      {'label': 'Monthly', 'value': post!.monthlyPrice},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: prices.map((price) {
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            child: Card(
              color: Colors.grey.shade100,
              surfaceTintColor: Colors.grey.shade100,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      price['label'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '৳${(price['value'] as double).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHostTile() {
    return Card(
      color: Colors.grey.shade100,
      surfaceTintColor: Colors.grey.shade100,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, size: 32, color: Colors.black54),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Host Name',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Host',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.call, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaution() {
    return Card(
      color: Colors.grey.shade100,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.black12,
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Never share your banking card details or OTP. Always verify the post before paying.',
                style: TextStyle(color: Colors.grey.shade800, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Reviews'),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: List.generate(3, (index) => _buildReviewCard())),
        ),
      ],
    );
  }

  Widget _buildReviewCard() {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (_) => const Icon(Icons.star_border, size: 16),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Username', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            '12/12/2025',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 12),
          const Text(
            'Review Title',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Review body goes here. Keep it short and readable.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
