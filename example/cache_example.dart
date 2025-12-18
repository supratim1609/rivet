/// Example demonstrating caching with @CacheResponse decorator
library;

import 'package:rivet/rivet.dart';

class ProductController {
  // Simulate slow database query
  static int _callCount = 0;

  @Get('/products')
  @CacheResponse(ttl: 10) // Cache for 10 seconds
  Future<RivetResponse> list(RivetRequest req) async {
    _callCount++;
    print('🔍 Fetching products from database... (call #$_callCount)');
    
    // Simulate slow query
    await Future.delayed(Duration(seconds: 1));
    
    return RivetResponse.json([
      {'id': 1, 'name': 'Laptop', 'price': 999},
      {'id': 2, 'name': 'Mouse', 'price': 29},
      {'id': 3, 'name': 'Keyboard', 'price': 79},
    ]);
  }

  @Get('/products/:id')
  @CacheResponse(ttl: 30) // Cache for 30 seconds
  Future<RivetResponse> show(RivetRequest req) async {
    final id = req.params['id'];
    print('🔍 Fetching product $id from database...');
    
    await Future.delayed(Duration(milliseconds: 500));
    
    return RivetResponse.json({
      'id': id,
      'name': 'Product $id',
      'price': 99,
    });
  }

  @Get('/products/search')
  @CacheResponse(ttl: 60) // Cache for 1 minute
  Future<RivetResponse> search(RivetRequest req) async {
    final query = req.query['q'] ?? '';
    print('🔍 Searching for: $query');
    
    await Future.delayed(Duration(milliseconds: 800));
    
    return RivetResponse.json({
      'query': query,
      'results': [
        {'id': 1, 'name': 'Laptop'},
      ],
    });
  }

  @Get('/cache/stats')
  Future<RivetResponse> cacheStats(RivetRequest req) async {
    return RivetResponse.json(cache.stats);
  }

  @Post('/cache/clear')
  Future<RivetResponse> clearCache(RivetRequest req) async {
    await cache.clear();
    return RivetResponse.json({'message': 'Cache cleared'});
  }
}

void main() async {
  final app = RivetServer();

  app.registerController(ProductController());

  print('');
  print('🚀 Cache Example Server');
  print('');
  print('Try these commands:');
  print('  curl http://localhost:3000/products');
  print('  curl http://localhost:3000/products (again - should be instant!)');
  print('  curl http://localhost:3000/cache/stats');
  print('  curl -X POST http://localhost:3000/cache/clear');
  print('');

  await app.listen(port: 3000);
}
