import 'package:rivet/rivet.dart';

void main() async {
  final app = RivetServer();

  // Serve static files from example/public
  app.use(createStaticHandler('example/public'));

  // Enable CORS
  app.use(cors());

  app.get('/hello', (req) {
    return RivetResponse.text('Hello Rivet!');
  });

  app.post('/echo', (req) async {
    final data = await req.text();
    return RivetResponse.text('You said: $data');
  });

  app.get('/users/:name', (req) {
    return RivetResponse.text('Hello ${req.params['name']}!');
  });

  app.get('/search', (req) {
    final q = req.query['q'] ?? '';
    final page = req.getInt('page') ?? 1;
    final active = req.getBool('active') ?? false;
    return RivetResponse.text('Searching for "$q" on page $page (active: $active)');
  });

  app.post('/upload', (req) async {
    await req.parseBody();
    final field = req.formFields['field'] ?? 'none';
    final file = req.files.isNotEmpty ? req.files.first : null;
    
    return RivetResponse.text(
      'Field: $field\n'
      'File: ${file?.filename} (${file?.data.length} bytes)',
    );
  });

  await app.listen(
      port: 3000,
      onStarted: () {
        print('Example server running at http://localhost:3000');
      });
}
