import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:real_estate/UI/inputPost.dart';
import 'package:real_estate/UI/detailPost.dart';
// import 'package:post_app/UI/home/homepage.dart';
import 'package:real_estate/models/errMsg.dart';
import 'package:real_estate/models/post.dart';
import 'package:real_estate/services/api.dart';

class DataPosts extends StatefulWidget {
  const DataPosts({super.key});

  @override
  State<DataPosts> createState() => _DataPostsState();
}

class _DataPostsState extends State<DataPosts> {
  late ErrorMSG response;
  List<Post> _posts = [];
  bool _isLoading = false;
  void deletePost(id) async {
    response = await ApiStatic.deletePost(id);
    final snackBar = SnackBar(
      content: Text(response.message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (BuildContext context) => DataPosts()),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Post> Posts = await ApiStatic.getPost();
      setState(() {
        _posts = Posts;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error
      print('Failed to fetch posts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshPosts() async {
    await fetchPosts();
  }

  void _showPostDetail(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPost(post: post),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Posts'),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InputPost(
                        post: Post(
                            id: 0,
                            nama_property: '',
                            tipe_property: '',
                            image: '',
                            harga: '',
                            status: ''))));
          }),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _refreshPosts,
              child: ListView.builder(
                itemCount: _posts.length,
                itemBuilder: (BuildContext context, int index) {
                  if (index == _posts.length) {
                    if (_isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }
                  Post post = _posts[index];
                  return ListTile(
                    title: Text(post.nama_property),
                    subtitle: Text(post.tipe_property),
                    leading: Image.network(
                        ApiStatic.host + "/storage/" + post.image),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () {
                            // Logika yang akan dijalankan ketika tombol info ditekan
                            _showPostDetail(post);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        InputPost(post: post)));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Konfirmasi Hapus"),
                                  content: Text(
                                      "Apakah Anda yakin ingin menghapus post ini?"),
                                  actions: [
                                    TextButton(
                                      child: Text("Batal"),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Tutup dialog
                                      },
                                    ),
                                    TextButton(
                                      child: Text("Hapus"),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Tutup dialog
                                        deletePost(
                                            post.id); // Jalankan fungsi hapus
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
