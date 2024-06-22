import 'package:flutter/material.dart';
import 'package:vehicle_me/Models/Forum.dart';
import 'package:vehicle_me/Services/forum.dart';
import 'package:vehicle_me/Models/User.dart';
import 'package:vehicle_me/Pages/PostDetailPage.dart';
import 'package:vehicle_me/Services/Loading.dart';

class ForumPage extends StatefulWidget {
  final String authToken;
  final UserRegistration user;

  ForumPage({required this.authToken, required this.user});

  @override
  _ForumPageState createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  final ForumService _forumService = ForumService();
  late Future<List<ForumPost>> futurePosts;
  String filterCategory = 'All';
  String filterTitle = '';

  @override
  void initState() {
    super.initState();
    futurePosts = _forumService.fetchPosts();
  }

  void _createPost(String title, String content, String category, String vehicleModel, String vehicleBrand) {
    _forumService.createPost(widget.authToken, title, content, category, vehicleModel, vehicleBrand).then((post) {
      setState(() {
        futurePosts = _forumService.fetchPosts();
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create post: $error')));
    });
  }

  void _filterPosts() {
    setState(() {
      futurePosts = _forumService.fetchPosts().then((posts) {
        if (filterCategory != 'All') {
          posts = posts.where((post) => post.category == filterCategory).toList();
        }
        if (filterTitle.isNotEmpty) {
          posts = posts.where((post) => post.title?.toLowerCase().contains(filterTitle.toLowerCase()) ?? false).toList();
        }
        return posts;
      });
    });
  }

  void _clearFilters() {
    setState(() {
      filterCategory = 'All';
      filterTitle = '';
      futurePosts = _forumService.fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forum'),
      ),
      body: Column(
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  String title = '';
                  String content = '';
                  String category = 'General';
                  String vehicleModel = '';
                  String vehicleBrand = '';
                  final _formKey = GlobalKey<FormState>();

                  return AlertDialog(
                    title: Text('Create Post'),
                    content: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextFormField(
                              onChanged: (value) {
                                title = value;
                              },
                              decoration: InputDecoration(hintText: 'Title'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a title';
                                }
                                return null;
                              },
                            ),
                            TextField(
                              onChanged: (value) {
                                content = value;
                              },
                              decoration: InputDecoration(hintText: 'Content'),
                            ),
                            DropdownButtonFormField<String>(
                              value: category,
                              onChanged: (String? newValue) {
                                setState(() {
                                  category = newValue!;
                                });
                              },
                              items: <String>['General', 'Help', 'Urgent', 'Vehicle Support', 'Other']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              decoration: InputDecoration(hintText: 'Category'),
                            ),
                            TextField(
                              onChanged: (value) {
                                vehicleModel = value;
                              },
                              decoration: InputDecoration(hintText: 'Vehicle Model'),
                            ),
                            TextField(
                              onChanged: (value) {
                                vehicleBrand = value;
                              },
                              decoration: InputDecoration(hintText: 'Vehicle Brand'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        child: Text('Post'),
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _createPost(title, content, category, vehicleModel, vehicleBrand);
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Text('Create Post'),
          ),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Filter Posts'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          DropdownButtonFormField<String>(
                            value: filterCategory,
                            onChanged: (String? newValue) {
                              setState(() {
                                filterCategory = newValue!;
                              });
                            },
                            items: <String>['All', 'General', 'Help', 'Urgent', 'Vehicle Support', 'Other']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            decoration: InputDecoration(hintText: 'Category'),
                          ),
                          TextField(
                            onChanged: (value) {
                              setState(() {
                                filterTitle = value;
                              });
                            },
                            decoration: InputDecoration(hintText: 'Title Keywords'),
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        child: Text('Filter'),
                        onPressed: () {
                          _filterPosts();
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        child: Text('Clear Filters'),
                        onPressed: () {
                          _clearFilters();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Text('Filter Posts'),
          ),
          Expanded(
            child: FutureBuilder<List<ForumPost>>(
              future: futurePosts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CustomLoadingIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No posts available'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      ForumPost post = snapshot.data![index];
                      return ListTile(
                        title: Text(post.title ?? 'No title'),
                        subtitle: Text('${post.vehicleModel ?? 'No model'} - ${post.vehicleBrand ?? 'No brand'}'),
                        trailing: Text(post.category ?? 'No category'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailPage(
                                authToken: widget.authToken,
                                post: post,
                                user: widget.user,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
