/// Example of using Rivet decorators
library;

import 'package:rivet/rivet.dart';

/// Example controller using decorators
class UserController {
  @Get('/users')
  Future<RivetResponse> list(RivetRequest req) async {
    return RivetResponse.json([
      {'id': 1, 'name': 'Alice'},
      {'id': 2, 'name': 'Bob'},
    ]);
  }

  @Get('/users/:id')
  Future<RivetResponse> show(RivetRequest req) async {
    final id = req.params['id'];
    return RivetResponse.json({'id': id, 'name': 'User $id'});
  }

  @Post('/users')
  @Validate([
    Required('name'),
    Email('email'),
  ])
  Future<RivetResponse> create(RivetRequest req) async {
    final data = req.jsonBody ?? {};
    return RivetResponse.created({
      'id': 3,
      ...data,
    });
  }

  @Put('/users/:id')
  @Validate([
    Required('name'),
  ])
  Future<RivetResponse> update(RivetRequest req) async {
    final id = req.params['id'];
    final data = req.jsonBody ?? {};
    return RivetResponse.json({
      'id': id,
      ...data,
    });
  }

  @Delete('/users/:id')
  Future<RivetResponse> delete(RivetRequest req) async {
    final id = req.params['id'];
    return RivetResponse.noContent();
  }
}

/// Example controller with auth
class AdminController {
  @Get('/admin/stats')
  @Auth()
  Future<RivetResponse> stats(RivetRequest req) async {
    return RivetResponse.json({
      'users': 100,
      'posts': 500,
    });
  }

  @Get('/admin/users')
  @Auth(roles: ['admin'])
  Future<RivetResponse> listUsers(RivetRequest req) async {
    return RivetResponse.json([
      {'id': 1, 'name': 'Alice', 'role': 'admin'},
      {'id': 2, 'name': 'Bob', 'role': 'user'},
    ]);
  }
}

void main() async {
  final app = RivetServer();

  // Register controllers
  app.registerController(UserController());
  app.registerController(AdminController());

  await app.listen(port: 3000);
}
