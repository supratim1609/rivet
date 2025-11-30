import 'package:rivet/rivet.dart';

void main() async {
  final app = RivetServer();

  app.get('/', (req) {
    return RivetResponse.text('Hello World');
  });

  await app.listen(
    port: 3000,
    onStarted: () {
      print('Rivet Benchmark Server running on port 3000');
    },
  );
}
