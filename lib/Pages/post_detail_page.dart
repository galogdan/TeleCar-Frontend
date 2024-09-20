import 'package:flutter/material.dart';
import 'package:vehicle_me/Models/Forum.dart';
import 'package:vehicle_me/Models/User.dart';
import 'package:vehicle_me/Services/forum.dart';

class PostDetailPage extends StatefulWidget {
  final String authToken;
  final UserRegistration user;
  final ForumPost post;

  PostDetailPage({required this.authToken, required this.post, required this.user});

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final ForumService _forumService = ForumService();
  List<Comment> comments = [];

  @override
  void initState() {
    super.initState();
    comments = widget.post.comments;
  }

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      _forumService.addComment(widget.authToken, widget.post.id, _commentController.text).then((_) {
        setState(() {
          comments.add(Comment(
            userEmail: widget.user.email,
            content: _commentController.text,
            createdAt: DateTime.now().toIso8601String(),
          ));
          _commentController.clear();
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add comment: $error')));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade100,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          'Post Details',
          style: TextStyle(
            fontFamily: 'Oswald', // Apply the custom font
            fontSize: 28,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.post.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(widget.post.content, style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Category: ${widget.post.category}'),
            Text('Vehicle Model: ${widget.post.vehicleModel}'),
            Text('Vehicle Brand: ${widget.post.vehicleBrand}'),
            SizedBox(height: 16),
            Divider(),
            Text('Comments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(comments[index].content),
                    subtitle: Text(comments[index].userEmail),
                  );
                },
              ),
            ),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Add a comment',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
