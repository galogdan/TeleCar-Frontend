import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vehicle_me/Models/Forum.dart';
import 'package:vehicle_me/config.dart';

class ForumService {

  Future<List<ForumPost>> fetchPosts() async {
    final response = await http.get(Uri.parse('$currentIP/forum/posts/'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((post) => ForumPost.fromJson(post)).toList();
    } else {
      throw Exception('Failed to load forum posts');
    }
  }

  Future<ForumPost> createPost(String token, String title, String content, String category, String vehicleModel, String vehicleBrand) async {
    final response = await http.post(
      Uri.parse('$currentIP/forum/create_posts/'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'content': content,
        'category': category,
        'vehicle_model': vehicleModel,
        'vehicle_brand': vehicleBrand,
      }),
    );

    if (response.statusCode == 200) {
      return ForumPost.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create forum post');
    }
  }

  Future<void> addComment(String token, String postId, String comment) async {
    final response = await http.post(
      Uri.parse('$currentIP/forum/add_comment/'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'post_id': postId,
        'content': comment,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add comment');
    }
  }
}