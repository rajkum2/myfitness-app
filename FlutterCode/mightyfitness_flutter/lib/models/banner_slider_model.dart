class BannerSliderModel {
  int? id;
  String? title;
  String? slug;
  String? type;
  int? workoutId;
  String? url;
  String? bannersliderImage;
  String? createdAt;
  String? updatedAt;

  BannerSliderModel(
      {this.id,
        this.title,
        this.slug,
        this.type,
        this.workoutId,
        this.url,
        this.bannersliderImage,
        this.createdAt,
        this.updatedAt});

  BannerSliderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    slug = json['slug'];
    type = json['type'];
    workoutId = json['workout_id'];
    url = json['url'];
    bannersliderImage = json['bannerslider_image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['slug'] = this.slug;
    data['type'] = this.type;
    data['workout_id'] = this.workoutId;
    data['url'] = this.url;
    data['bannerslider_image'] = this.bannersliderImage;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
