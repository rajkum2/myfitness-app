import 'package:mighty_fitness/models/diet_response.dart';

import 'category_diet_response.dart';

class DietDashboardResponse {
  List<CategoryDietModel>? categoryDiet;
  List<DietModel>? bestDiet;
  List<DietModel>? diet;
  List<DietModel>? assignDiet;

  DietDashboardResponse({this.categoryDiet, this.bestDiet, this.diet, this.assignDiet});

  DietDashboardResponse.fromJson(Map<String, dynamic> json) {
    if (json['category_diet'] != null) {
      categoryDiet = <CategoryDietModel>[];
      json['category_diet'].forEach((v) {
        categoryDiet!.add(new CategoryDietModel.fromJson(v));
      });
    }
    if (json['best_diet'] != null) {
      bestDiet = <DietModel>[];
      json['best_diet'].forEach((v) {
        bestDiet!.add(new DietModel.fromJson(v));
      });
    }
    if (json['diet'] != null) {
      diet = <DietModel>[];
      json['diet'].forEach((v) {
        diet!.add(new DietModel.fromJson(v));
      });
    }
    if (json['assign_diet'] != null) {
      assignDiet = <DietModel>[];
      json['assign_diet'].forEach((v) {
        assignDiet!.add(new DietModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.categoryDiet != null) {
      data['category_diet'] =
          this.categoryDiet!.map((v) => v.toJson()).toList();
    }
    if (this.bestDiet != null) {
      data['best_diet'] = this.bestDiet!.map((v) => v.toJson()).toList();
    }
    if (this.diet != null) {
      data['diet'] = this.diet!.map((v) => v.toJson()).toList();
    }
    if (this.assignDiet != null) {
      data['assign_diet'] = this.assignDiet!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
