import '../utils/shared_import.dart';

class DashboardResponse {
  List<BodyPartModel>? bodypart;
  List<LevelModel>? level;
  List<EquipmentModel>? equipment;
  List<ExerciseModel>? exercise;
  List<Diet>? diet;
  List<Workouttype>? workouttype;
  List<WorkoutDetailModel>? workout;
  List<WorkoutDetailModel>? assignedWorkout;
  List<Diet>? featuredDiet;
  List<BannerSliderModel>? bannerSlider;
  String? subscription;
  DailyTrackingProgress? dailyTrackingProgress;

  DashboardResponse(
      {this.bodypart,
      this.level,
      this.equipment,
      this.exercise,
      this.diet,
      this.workouttype,
      this.workout,
      this.assignedWorkout,
      this.featuredDiet,
        this.bannerSlider,
      this.subscription,
      this.dailyTrackingProgress
      });

  DashboardResponse.fromJson(Map<String, dynamic> json) {
    if (json['bodypart'] != null) {
      bodypart = <BodyPartModel>[];
      json['bodypart'].forEach((v) {
        bodypart!.add(new BodyPartModel.fromJson(v));
      });
    }
    if (json['level'] != null) {
      level = <LevelModel>[];
      json['level'].forEach((v) {
        level!.add(new LevelModel.fromJson(v));
      });
    }
    if (json['equipment'] != null) {
      equipment = <EquipmentModel>[];
      json['equipment'].forEach((v) {
        equipment!.add(new EquipmentModel.fromJson(v));
      });
    }
    if (json['exercise'] != null) {
      exercise = <ExerciseModel>[];
      json['exercise'].forEach((v) {
        exercise!.add(new ExerciseModel.fromJson(v));
      });
    }
    if (json['diet'] != null) {
      diet = <Diet>[];
      json['diet'].forEach((v) {
        diet!.add(new Diet.fromJson(v));
      });
    }
    if (json['workouttype'] != null) {
      workouttype = <Workouttype>[];
      json['workouttype'].forEach((v) {
        workouttype!.add(new Workouttype.fromJson(v));
      });
    }
    if (json['workout'] != null) {
      workout = <WorkoutDetailModel>[];
      json['workout'].forEach((v) {
        workout!.add(new WorkoutDetailModel.fromJson(v));
      });
    }
    if (json['assign_workout'] != null) {
      assignedWorkout = <WorkoutDetailModel>[];
      json['assign_workout'].forEach((v) {
        assignedWorkout!.add(new WorkoutDetailModel.fromJson(v));
      });
    }
    subscription = json['subscription'];
    if (json['featured_diet'] != null) {
      featuredDiet = <Diet>[];
      json['featured_diet'].forEach((v) {
        featuredDiet!.add(new Diet.fromJson(v));
      });
    }
    if (json['banner_slider'] != null) {
      bannerSlider = <BannerSliderModel>[];
      json['banner_slider'].forEach((v) {
        bannerSlider!.add(new BannerSliderModel.fromJson(v));
      });
    }
    if (json['daily_tracking_progress'] != null) {
      dailyTrackingProgress =  DailyTrackingProgress.fromJson(json['daily_tracking_progress']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.bodypart != null) {
      data['bodypart'] = this.bodypart!.map((v) => v.toJson()).toList();
    }
    if (this.level != null) {
      data['level'] = this.level!.map((v) => v.toJson()).toList();
    }
    if (this.equipment != null) {
      data['equipment'] = this.equipment!.map((v) => v.toJson()).toList();
    }
    if (this.exercise != null) {
      data['exercise'] = this.exercise!.map((v) => v.toJson()).toList();
    }
    if (this.diet != null) {
      data['diet'] = this.diet!.map((v) => v.toJson()).toList();
    }
    if (this.workouttype != null) {
      data['workouttype'] = this.workouttype!.map((v) => v.toJson()).toList();
    }
    if (this.workout != null) {
      data['workout'] = this.workout!.map((v) => v.toJson()).toList();
    }
    if (this.assignedWorkout != null) {
      data['assign_workout'] = this.assignedWorkout!.map((v) => v.toJson()).toList();
    }
    data['subscription'] = this.subscription;
    if (this.featuredDiet != null) {
      data['featured_diet'] =
          this.featuredDiet!.map((v) => v.toJson()).toList();
    }
    if (this.bannerSlider != null) {
      data['banner_slider'] =
          this.bannerSlider!.map((v) => v.toJson()).toList();
    }
    if(this.dailyTrackingProgress != null){
      data['daily_tracking_progress'] = this.dailyTrackingProgress!.toJson();
    }
    return data;
  }
}

class Diet {
  int? id;
  String? title;
  String? calories;
  String? carbs;
  String? protein;
  String? fat;
  String? servings;
  String? totalTime;
  String? isFeatured;
  String? status;
  String? ingredients;
  String? description;
  String? dietImage;
  int? isPremium;
  int? categorydietId;
  String? categorydietTitle;
  String? createdAt;
  String? updatedAt;
  int? isFavourite;

  Diet(
      {this.id,
      this.title,
      this.calories,
      this.carbs,
      this.protein,
      this.fat,
      this.servings,
      this.totalTime,
      this.isFeatured,
      this.status,
      this.ingredients,
      this.description,
      this.dietImage,
      this.isPremium,
      this.categorydietId,
      this.categorydietTitle,
      this.createdAt,
      this.updatedAt,
      this.isFavourite});

  Diet.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    calories = json['calories'];
    carbs = json['carbs'];
    protein = json['protein'];
    fat = json['fat'];
    servings = json['servings'];
    totalTime = json['total_time'];
    isFeatured = json['is_featured'];
    status = json['status'];
    ingredients = json['ingredients'];
    description = json['description'];
    dietImage = json['diet_image'];
    isPremium = json['is_premium'];
    categorydietId = json['categorydiet_id'];
    categorydietTitle = json['categorydiet_title'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isFavourite = json['is_favourite'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['calories'] = this.calories;
    data['carbs'] = this.carbs;
    data['protein'] = this.protein;
    data['fat'] = this.fat;
    data['servings'] = this.servings;
    data['total_time'] = this.totalTime;
    data['is_featured'] = this.isFeatured;
    data['status'] = this.status;
    data['ingredients'] = this.ingredients;
    data['description'] = this.description;
    data['diet_image'] = this.dietImage;
    data['is_premium'] = this.isPremium;
    data['categorydiet_id'] = this.categorydietId;
    data['categorydiet_title'] = this.categorydietTitle;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['is_favourite'] = this.isFavourite;
    return data;
  }
}

class Workouttype {
  int? id;
  String? title;
  String? status;
  String? createdAt;
  String? updatedAt;

  Workouttype(
      {this.id, this.title, this.status, this.createdAt, this.updatedAt});

  Workouttype.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class DailyTrackingProgress {
  int? todaySteps;
  int? todayWater;
  int? stepGoal;
  int? waterGoal;

  DailyTrackingProgress(
      {this.todaySteps, this.todayWater, this.stepGoal, this.waterGoal});

  DailyTrackingProgress.fromJson(Map<String, dynamic> json) {
    todaySteps = json['today_steps'];
    todayWater = json['today_water'];
    stepGoal = json['step_goal'];
    waterGoal = json['water_goal'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['today_steps'] = this.todaySteps;
    data['today_water'] = this.todayWater;
    data['step_goal'] = this.stepGoal;
    data['water_goal'] = this.waterGoal;
    return data;
  }
}