import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/post.dart';

class PostDetailsScreen extends StatefulWidget {
  final Post post;
  const PostDetailsScreen({super.key, required this.post});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SizedBox(height: kIsWeb ? 24 : 16),
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: CircleAvatar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: const Icon(CupertinoIcons.arrow_left),
        ),
      ),
      title: Text(
        widget.post.name,
        style: kIsWeb
            ? Theme.of(
                context,
              ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold)
            : Theme.of(
                context,
              ).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
        maxLines: 1,
      ),
      subtitle: Text(widget.post.address, maxLines: 1),
      trailing: CupertinoButton.filled(
        color: const Color(0xFF8eda53),
        padding: const EdgeInsets.symmetric(
          horizontal: kIsWeb ? 36 : 16,
          vertical: 4,
        ),
        borderRadius: BorderRadius.circular(8),
        onPressed: () {},
        child: const Text('Book Now'),
      ),
    );
  }

  Widget _buildImages() {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.post.imageUrls.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) => ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(16),
              child: Image.network(
                widget.post.imageUrls[index],
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.post.imageUrls.length,
            (index) => GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                setState(() => _currentIndex = index);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _currentIndex == index
                        ? Colors.blue
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(8),
                  child: Image.network(
                    widget.post.imageUrls[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Description'),
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Text(widget.post.description),
        ),
        _buildSectionTitle('Pricing'),
        _buildPricing(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
    );
  }

  Widget _buildPricing() {
    final prices = [
      {'label': 'Daily', 'value': widget.post.dailyPrice},
      {'label': 'Weekly', 'value': widget.post.weeklyPrice},
      {'label': 'Monthly', 'value': widget.post.monthlyPrice},
    ];

    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(
        scrollbars: false,
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.trackpad,
        },
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 8,
          children: prices.map((price) {
            return IntrinsicWidth(
              child: Container(
                constraints: const BoxConstraints(minWidth: 160),
                child: Card.outlined(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
                  child: ListTile(
                    leading: Text('৳', style: const TextStyle(fontSize: 28)),
                    title: Text(price['label'] as String),
                    subtitle: Text(
                      (price['value'] as double).toStringAsFixed(2),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildReviews() {
    return ListTile(
      title: _buildSectionTitle('Reviews'),
      subtitle: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(
          scrollbars: false,
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.stylus,
            PointerDeviceKind.trackpad,
          },
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 32,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 180,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.star_border),
                        Icon(Icons.star_border),
                        Icon(Icons.star_border),
                        Icon(Icons.star_border),
                        Icon(Icons.star_border),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(),
                      title: const Text('Username'),
                      subtitle: const Text('12/12/2025'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Review Title'),
                      subtitle: const Text('Review Body'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
