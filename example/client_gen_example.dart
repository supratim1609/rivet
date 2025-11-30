import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rivet/rivet.dart';

part 'client_gen_example.g.dart';

// Define a controller with route annotations
class UserController {
  @Get('/users')
  static RivetResponse list(RivetRequest req) {
    return RivetResponse.json([]);
  }

  @Get('/users/:id')
  static RivetResponse show(RivetRequest req) {
    return RivetResponse.json({});
  }

  @Post('/users')
  static RivetResponse create(RivetRequest req) {
    return RivetResponse.created({});
  }
}

// Define the client to be generated
@RivetClient(controllers: [UserController])
abstract class MyApiClient {
  factory MyApiClient(String baseUrl, {http.Client? client}) = _MyApiClient;
}

void main() {
  print('Run "dart run build_runner build" to generate the client!');
}
