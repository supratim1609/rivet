import 'package:test/test.dart';
import 'package:rivet/src/router/router.dart';

void main() {
  group('Router', () {
    late Router router;

    setUp(() {
      router = Router();
    });

    test('matches exact path', () {
      router.get('/hello', (_) {});
      final result = router.match('GET', '/hello');
      expect(result, isNotNull);
      expect(result!.params, isEmpty);
    });

    test('matches path with parameter', () {
      router.get('/users/:id', (_) {});
      final result = router.match('GET', '/users/123');
      expect(result, isNotNull);
      expect(result!.params, equals({'id': '123'}));
    });

    test('matches path with multiple parameters', () {
      router.get('/posts/:postId/comments/:commentId', (_) {});
      final result = router.match('GET', '/posts/10/comments/20');
      expect(result, isNotNull);
      expect(result!.params, equals({'postId': '10', 'commentId': '20'}));
    });

    test('does not match incorrect path', () {
      router.get('/hello', (_) {});
      final result = router.match('GET', '/world');
      expect(result, isNull);
    });

    test('does not match incorrect method', () {
      router.get('/hello', (_) {});
      final result = router.match('POST', '/hello');
      expect(result, isNull);
    });

    test('prioritizes exact match over parameter', () {
      router.get('/users/new', (_) {});
      router.get('/users/:id', (_) {});

      final resultNew = router.match('GET', '/users/new');
      expect(resultNew, isNotNull);
      expect(resultNew!.params, isEmpty); // Should match /users/new

      final resultId = router.match('GET', '/users/123');
      expect(resultId, isNotNull);
      expect(resultId!.params, equals({'id': '123'}));
    });
  });
}
