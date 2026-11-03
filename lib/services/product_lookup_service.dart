import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/app_exception.dart';
import '../models/food_item.dart';

/// Produto encontrado pelo código de barras.
class ProductInfo {
  const ProductInfo({required this.name, required this.category});

  final String name;
  final FoodCategory category;
}

/// Busca nome e categoria na API pública do Open Food Facts (RF18).
class ProductLookupService {
  ProductLookupService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  /// Retorna `null` se o produto não estiver cadastrado na base.
  Future<ProductInfo?> lookup(String barcode) async {
    final uri = Uri.https(
      'world.openfoodfacts.org',
      '/api/v2/product/$barcode.json',
      {'fields': 'product_name,product_name_pt,brands,categories_tags'},
    );
    final http.Response response;
    try {
      response = await _client
          .get(uri, headers: {'User-Agent': 'GestaoAlimentos/1.0 (estudo)'})
          .timeout(const Duration(seconds: 10));
    } on Exception {
      throw const AppException(
        'Sem conexão para buscar o produto. Preencha manualmente.',
      );
    }
    // A API responde 404 quando o código não existe na base.
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw const AppException(
        'Não foi possível buscar o produto. Preencha manualmente.',
      );
    }
    return parseProduct(jsonDecode(response.body) as Map<String, dynamic>);
  }
}

/// Converte a resposta da API em [ProductInfo]; `null` se não houver nome.
ProductInfo? parseProduct(Map<String, dynamic> json) {
  if (json['status'] != 1) return null;
  final product = json['product'] as Map<String, dynamic>? ?? const {};
  String text(String key) => (product[key] as String? ?? '').trim();

  final name = text('product_name_pt').isNotEmpty
      ? text('product_name_pt')
      : text('product_name');
  if (name.isEmpty) return null;

  final tags = (product['categories_tags'] as List? ?? const [])
      .whereType<String>()
      .toList();
  return ProductInfo(name: name, category: categoryFromTags(tags));
}

// Ordem importa: tags mais específicas antes (ex.: aves antes de carnes).
const _categoryTags = <FoodCategory, List<String>>{
  FoodCategory.poultry: ['en:poultry', 'en:chickens'],
  FoodCategory.fish: ['en:fishes', 'en:seafood'],
  FoodCategory.meat: ['en:meats'],
  FoodCategory.eggs: ['en:eggs'],
  FoodCategory.dairy: ['en:dairies', 'en:milks', 'en:cheeses', 'en:yogurts'],
  FoodCategory.canned: ['en:canned-foods'],
  FoodCategory.beverages: ['en:beverages'],
  FoodCategory.bakery: ['en:breads'],
  FoodCategory.grains: [
    'en:cereals-and-their-products',
    'en:pastas',
    'en:rices',
  ],
  FoodCategory.produce: ['en:fruits', 'en:vegetables'],
};

/// Mapeia as categorias do Open Food Facts para as do app.
FoodCategory categoryFromTags(List<String> tags) {
  for (final entry in _categoryTags.entries) {
    if (entry.value.any(tags.contains)) return entry.key;
  }
  return FoodCategory.other;
}
