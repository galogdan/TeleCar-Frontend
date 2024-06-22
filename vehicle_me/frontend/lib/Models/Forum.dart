class Comment {
  final String userEmail;
  final String content;
  final String createdAt;

  Comment({required this.userEmail, required this.content, required this.createdAt});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      userEmail: json['user_email'],
      content: json['content'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_email': userEmail,
      'content': content,
      'created_at': createdAt,
    };
  }
}

class ForumPost {
  final String id;
  final String title;
  final String content;
  final String category;
  final String vehicleModel;
  final String vehicleBrand;
  final String createdAt;
  final List<Comment> comments;

  ForumPost({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.vehicleModel,
    required this.vehicleBrand,
    required this.createdAt,
    required this.comments,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    var list = json['comments'] as List;
    List<Comment> commentList = list.map((i) => Comment.fromJson(i)).toList();

    return ForumPost(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      vehicleModel: json['vehicle_model'],
      vehicleBrand: json['vehicle_brand'],
      createdAt: json['created_at'],
      comments: commentList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'vehicle_model': vehicleModel,
      'vehicle_brand': vehicleBrand,
      'created_at': createdAt,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }
}