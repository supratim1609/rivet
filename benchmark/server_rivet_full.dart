import 'package:rivet/rivet.dart';

void main() async {
  final app = RivetServer();

  app.get('/hello', (req) {
    return RivetResponse.json({'message': 'Hello, World!'});
  });

  app.get('/user/:id', (req) {
    return RivetResponse.json({
      'id': req.params['id'],
      'name': 'User ${req.params['id']}'
    });
  });

  await app.listen(port: 3000);
}
