import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../api/feat/post_api.dart';
import '../../../models/post_model.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  late Future<List<dynamic>> _commentsFuture;
  bool _isSubmitting = false;
  bool _isLiking = false;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  void _fetchComments() {
    _commentsFuture = PostApi().getComments(widget.post.id);
  }

  Future<void> _handleLike() async {
    if (_isLiking) return;

    setState(() => _isLiking = true);

    final originalIsLiked = widget.post.isLiked;
    final originalLikeCount = widget.post.likeCount;

    // Optimistic update
    setState(() {
      widget.post.isLiked = !widget.post.isLiked;
      widget.post.likeCount += widget.post.isLiked ? 1 : -1;
    });

    try {
      final result = await PostApi().toggleLike(widget.post.id);
      setState(() {
        widget.post.isLiked = result;
      });
    } catch (e) {
      setState(() {
        widget.post.isLiked = originalIsLiked;
        widget.post.likeCount = originalLikeCount;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่สามารถกดไลก์ได้ในขณะนี้')),
      );
    } finally {
      setState(() => _isLiking = false);
    }
  }

  // เพิ่ม method refresh ข้อมูลความเห็น
  void _refreshComments() {
    setState(() {
      _commentsFuture = PostApi().refreshComments(widget.post.id);
    });
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      await PostApi().addComment(widget.post.id, text);
      _commentController.clear();

      setState(() {
        _refreshComments(); // ใช้ method refresh ใหม่
        widget.post.commentCount += 1;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("เกิดข้อผิดพลาดในการคอมเมนต์: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _showUserProfile() async {
    if (mounted) {
      context.push(
        '/profile/${widget.post.userId}',
        extra: {
          'username': widget.post.username,
          'profileImage': widget.post.profileImage,
        },
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("โพสต์ของ ${widget.post.username}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          // Like button
          IconButton(
            icon: _isLiking
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.post.isLiked ? Colors.red : Colors.grey,
                      ),
                    ),
                  )
                : Icon(
                    widget.post.isLiked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.post.isLiked ? Colors.red : Colors.grey,
                  ),
            onPressed: _handleLike,
            tooltip: widget.post.isLiked ? 'เลิกไลค์' : 'ไลค์',
          ),
          // เพิ่มปุ่ม refresh ความเห็น
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshComments,
            tooltip: 'รีเฟรชชความเห็น',
          ),
        ],
      ),
      body: Column(
        children: [
          //แสดงข้อมูลโพสต์คอมเม้น
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Image.network(
                  widget.post.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 300,
                  errorBuilder: (_, __, ___) => Container(
                    height: 300,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 50),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Avatar
                          GestureDetector(
                            onTap: _showUserProfile,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage: widget.post.profileImage != null
                                  ? NetworkImage(widget.post.profileImage!)
                                  : null,
                              child: widget.post.profileImage == null
                                  ? const Icon(Icons.person, size: 20)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Username
                          Expanded(
                            child: GestureDetector(
                              onTap: _showUserProfile,
                              child: Text(
                                widget.post.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(
                                widget.post.isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: widget.post.isLiked
                                    ? Colors.red
                                    : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.post.likeCount}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(widget.post.caption ?? 'ไม่มีเนื้อหา'),
                    ],
                  ),
                ),
                const Divider(thickness: 1),

                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    "ความคิดเห็น",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                FutureBuilder<List<dynamic>>(
                  future: _commentsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text("ไม่สามารถโหลดคอมเมนต์ได้"),
                      );
                    }

                    final comments = snapshot.data ?? [];
                    if (comments.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            "ยังไม่มีความคิดเห็น",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final String username =
                            comment['username']?.toString() ?? 'ไม่ระบุชื่อ';
                        final String content =
                            comment['content']?.toString() ?? '';
                        final String? profileImageUrl =
                            comment['profile_image'];
                        final int? userId = comment['user_id'] != null
                            ? int.tryParse(comment['user_id'].toString())
                            : null;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar
                              GestureDetector(
                                onTap: () {
                                  if (userId != null) {
                                    context.push(
                                      '/profile/$userId',
                                      extra: {
                                        'username': username,
                                        'profileImage': profileImageUrl,
                                      },
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('ไม่พบข้อมูลผู้ใช้'),
                                      ),
                                    );
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundImage: profileImageUrl != null
                                      ? NetworkImage(profileImageUrl)
                                      : null,
                                  child: profileImageUrl == null
                                      ? const Icon(Icons.person, size: 20)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Comment content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (userId != null) {
                                          context.push(
                                            '/profile/$userId',
                                            extra: {
                                              'username': username,
                                              'profileImage': profileImageUrl,
                                            },
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'ไม่พบข้อมูลผู้ใช้',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Text(
                                        username,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(content),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // กล่องพิมพ์ข้อความ
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: "แสดงความคิดเห็น...",
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isSubmitting
                      ? const CircularProgressIndicator()
                      : IconButton(
                          icon: const Icon(Icons.send, color: Colors.blue),
                          onPressed: _submitComment,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
