/// Complete example showing the auto-generated Flutter client in action
///
/// This demonstrates:
/// 1. Backend server with routes
/// 2. Auto-generated client
/// 3. Flutter app using the client
library;

import 'package:rivet/rivet.dart';

// ============================================================================
// BACKEND (Rivet Server)
// ============================================================================

void startServer() async {
  final app = RivetServer();

  // User routes
  app.get('/user/:id', (req) {
    return RivetResponse.json({
      'id': req.params['id'],
      'name': 'John Doe',
      'email': 'john@example.com',
    });
  });

  // Login route
  app.post('/login', (req) async {
    final body = await req.json();
    return RivetResponse.json({
      'token': 'jwt-token-here',
      'user': {'id': '123', 'name': body['email'], 'email': body['email']},
    });
  });

  // Posts route with pagination
  app.get('/posts', (req) {
    final page = req.query['page'] ?? '1';
    final limit = req.query['limit'] ?? '10';

    return RivetResponse.json([
      {
        'id': '1',
        'title': 'Hello World',
        'content': 'This is a post',
        'author': {'id': '123', 'name': 'John Doe'},
      },
      {
        'id': '2',
        'title': 'Another Post',
        'content': 'More content here',
        'author': {'id': '456', 'name': 'Jane Smith'},
      },
    ]);
  });

  await app.listen(port: 3000);
  print('🚀 Server running on http://localhost:3000');
}

// ============================================================================
// FLUTTER APP (Using Auto-Generated Client)
// ============================================================================

/*
// After running: rivet generate client
// The generated client can be used like this:

import 'package:flutter/material.dart';
import 'api_client.dart'; // Auto-generated

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UserScreen(),
    );
  }
}

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final client = RivetClient('http://localhost:3000');
  Map<String, dynamic>? user;
  List<dynamic>? posts;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      // Type-safe API calls!
      final userData = await client.get('/user/123');
      final postsData = await client.get('/posts', queryParams: {
        'page': '1',
        'limit': '10',
      });
      
      setState(() {
        user = userData;
        posts = postsData as List;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> login() async {
    try {
      final result = await client.post('/login', body: {
        'email': 'user@example.com',
        'password': 'secret',
      });
      
      print('Logged in! Token: ${result['token']}');
    } catch (e) {
      print('Login failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      body: Column(
        children: [
          ListTile(
            title: Text(user!['name']),
            subtitle: Text(user!['email']),
          ),
          ElevatedButton(
            onPressed: login,
            child: Text('Login'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: posts?.length ?? 0,
              itemBuilder: (context, index) {
                final post = posts![index];
                return ListTile(
                  title: Text(post['title']),
                  subtitle: Text(post['content']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    client.close();
    super.dispose();
  }
}
*/

// ============================================================================
// THE MAGIC
// ============================================================================

/*
What just happened?

1. You wrote your Rivet backend (routes above)
2. You ran: rivet generate client
3. You got a type-safe Flutter client for FREE
4. No manual API calls, no typos, no runtime errors

This is the killer feature that makes Rivet unique!
*/

void main() {
  print('🔥 Auto-Generated Flutter Client Example');
  print('');
  print('Step 1: Start your Rivet server');
  print('  dart run example/full_client_example.dart');
  print('');
  print('Step 2: Generate the client');
  print('  rivet generate client');
  print('');
  print('Step 3: Use it in your Flutter app');
  print('  final client = RivetClient(\'http://localhost:3000\');');
  print('  final user = await client.get(\'/user/123\');');
  print('');
  print('✨ Type-safe. Zero boilerplate. Pure magic.');
}
