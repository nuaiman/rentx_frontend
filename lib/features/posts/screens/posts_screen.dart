import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/pngs.dart';
import '../../../main.dart';
import '../../auth/notifiers/auth_notifier.dart';
import '../../auth/screens/auth_screen.dart';
import '../../categories/notifiers/category_notifier.dart';
import '../../init/screens/admin_init_screen.dart';
import '../notifiers/category_notifier.dart';
import '../notifiers/filtered_post_notifier.dart';
import '../notifiers/approved_post_notifier.dart';
import '../notifiers/search_notifier.dart';
import '../widgets/category_button.dart';
import 'add_post_screen.dart';
import 'post_details_screen.dart';

class PostsScreen extends ConsumerStatefulWidget {
  const PostsScreen({super.key});

  @override
  ConsumerState<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends ConsumerState<PostsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(approvedPostsProvider);
    final categories = ref.watch(categoriesProvider);
    final filteredPosts = ref.watch(filteredItemsProvider);
    final auth = ref.watch(authProvider);

    final LayerLink layerLink = LayerLink();
    OverlayEntry? overlayEntry;

    void showMenu() {
      overlayEntry = OverlayEntry(
        builder: (context) {
          return Positioned(
            width: 140, // width of the popup
            child: CompositedTransformFollower(
              link: layerLink,
              showWhenUnlinked: false,
              offset: Offset(30, 40),
              child: Material(
                elevation: 4,
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //
                      (auth.value!.role == 'user')
                          ? SizedBox.shrink()
                          : ListTile(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    // builder: (context) => AdminHomeScreen(),
                                    builder: (context) => AdminInitScreen(),
                                  ),
                                );
                              },
                              leading: Icon(CupertinoIcons.lock),
                              title: Text('Admin Panel'),
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              contentPadding: EdgeInsets.zero,
                            ),
                      //
                      ListTile(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddPostScreen(),
                            ),
                          );
                        },
                        leading: Icon(CupertinoIcons.add),
                        title: Text('My Listings'),
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        contentPadding: EdgeInsets.zero,
                      ),
                      //
                      ListTile(
                        onTap: () {
                          ref.read(authProvider.notifier).logout();
                        },
                        leading: Icon(CupertinoIcons.power),
                        title: Text('Logout'),
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

      Overlay.of(context).insert(overlayEntry!);
    }

    void hideMenu() {
      overlayEntry?.remove();
      overlayEntry = null;
    }

    return Scaffold(
      body: Align(
        alignment: AlignmentGeometry.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Safe box
                SizedBox(height: kIsWeb ? 0 : 48),
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(Pngs.logo, height: 40),
                      CompositedTransformTarget(
                        link: layerLink,
                        child: GestureDetector(
                          onTap: () {
                            if (auth.value == null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => AuthScreen()),
                              );
                            } else {
                              if (overlayEntry == null) {
                                showMenu();
                              } else {
                                hideMenu();
                              }
                            }
                          },
                          child: Image.asset(
                            auth.value == null ? Pngs.login : Pngs.dashboard,
                            height: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search bar
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 200,
                      maxWidth: 600,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          ref.read(searchProvider.notifier).setQuery(value);
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 20,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFf7f7f7),
                          hintText: 'Search...',
                          hintStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref
                                        .read(searchProvider.notifier)
                                        .clearQuery();
                                  },
                                ),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category buttons
                SizedBox(
                  height: 40,
                  child: ScrollConfiguration(
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: categories.map((category) {
                          return CategoryButton(
                            category: category,
                            onTap: () {
                              ref
                                  .read(categoryProvider.notifier)
                                  .setCategory(category);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Divider(),

                // Posts section
                ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final categoryPosts = filteredPosts
                        .where((post) => post.categoryId == category.id)
                        .toList();

                    if (categoryPosts.isEmpty) return const SizedBox.shrink();

                    final horizontalController = ScrollController();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Title + scroll buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    CupertinoIcons.arrow_left_circle,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    horizontalController.animateTo(
                                      horizontalController.offset - 200,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.ease,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    CupertinoIcons.arrow_right_circle,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    horizontalController.animateTo(
                                      horizontalController.offset + 200,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.ease,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Horizontal posts list
                        SizedBox(
                          height: 240,
                          child: ScrollConfiguration(
                            behavior: const ScrollBehavior().copyWith(
                              scrollbars: false,
                              dragDevices: {
                                PointerDeviceKind.mouse,
                                PointerDeviceKind.touch,
                                PointerDeviceKind.stylus,
                                PointerDeviceKind.trackpad,
                              },
                            ),
                            child: ListView.builder(
                              controller: horizontalController,
                              scrollDirection: Axis.horizontal,
                              itemCount: categoryPosts.length,
                              itemBuilder: (context, i) {
                                final post = categoryPosts[i];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      context.push(
                                        RouteNames.postDetails.replaceFirst(
                                          ':id',
                                          '${post.id}',
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 300,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Image.network(
                                                post.imageUrls[0],
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                              ),
                                            ),
                                          ),
                                          ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                ),
                                            title: Text(
                                              post.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            subtitle: Text(
                                              post.address,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            trailing: Text(
                                              "৳ ${post.dailyPrice.toStringAsFixed(2)} /Daily",
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
