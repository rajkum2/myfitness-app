import 'package:mighty_fitness/models/product_category_response.dart';
import 'package:mighty_fitness/models/product_response.dart';

class ProductDashboardResponse {
  List<ProductModel>? product;
  List<ProductCategoryModel>? productCategory;

  ProductDashboardResponse({this.product, this.productCategory});

  ProductDashboardResponse.fromJson(Map<String, dynamic> json) {
    if (json['product'] != null) {
      product = <ProductModel>[];
      json['product'].forEach((v) {
        product!.add(new ProductModel.fromJson(v));
      });
    }
    if (json['product_category'] != null) {
      productCategory = <ProductCategoryModel>[];
      json['product_category'].forEach((v) {
        productCategory!.add(new ProductCategoryModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.product != null) {
      data['product'] = this.product!.map((v) => v.toJson()).toList();
    }
    if (this.productCategory != null) {
      data['product_category'] =
          this.productCategory!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

