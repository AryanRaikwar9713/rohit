import 'package:streamit_laravel/screens/watch_list/model/watch_list_resp.dart';

import '../../../video_players/model/video_model.dart';
import '../../genres/model/genres_model.dart';
import '../../person/model/person_model.dart';

class DashboardDetailResponse {
  bool status;
  String message;
  DashboardModel data;

  DashboardDetailResponse({
    this.status = false,
    this.message = "",
    required this.data,
  });

  factory DashboardDetailResponse.fromJson(Map<String, dynamic> json) {
    return DashboardDetailResponse(
      status: json['status'] is bool ? json['status'] : false,
      message: json['message'] is String ? json['message'] : "",
      data: json['data'] is Map ? DashboardModel.fromJson(json['data']) : DashboardModel(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class DashboardModel {
  List<SliderModel>? slider;
  List<VideoPlayerModel> continueWatch;
  ListResponse? top10List;
  ListResponse? latestList;
  ListResponse? topChannelList;
  ListResponse? popularMovieList;
  ListResponse? popularTvShowList;
  ListResponse? popularVideoList;
  List<VideoPlayerModel> likeMovieList;
  List<VideoPlayerModel> viewedMovieList;
  List<VideoPlayerModel> trendingMovieList;
  List<VideoPlayerModel> trendingInCountryMovieList;
  List<VideoPlayerModel> basedOnLastWatchMovieList;
  List<VideoPlayerModel> payPerView;

  ListResponse? freeMovieList;
  GenresResponse? genreList;
  ListResponse? popularLanguageList;
  PersonModelResponse? actorList;
  List<GenreModel> favGenreList;
  List<PersonModel> favActorList;

  DashboardModel({
    this.slider = const <SliderModel>[],
    this.continueWatch = const <VideoPlayerModel>[],
    this.top10List,
    this.latestList,
    this.topChannelList,
    this.popularMovieList,
    this.popularTvShowList,
    this.popularVideoList,
    this.likeMovieList = const <VideoPlayerModel>[],
    this.viewedMovieList = const <VideoPlayerModel>[],
    this.trendingMovieList = const <VideoPlayerModel>[],
    this.trendingInCountryMovieList = const <VideoPlayerModel>[],
    this.basedOnLastWatchMovieList = const <VideoPlayerModel>[],
    this.payPerView = const <VideoPlayerModel>[],
    this.freeMovieList,
    this.genreList,
    this.popularLanguageList,
    this.favActorList = const <PersonModel>[],
    this.favGenreList = const <GenreModel>[],
    this.actorList,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      slider: json['slider'] is List ? List<SliderModel>.from(json['slider'].map((x) => SliderModel.fromJson(x))) : [],
      top10List: json['top_10'] is Map ? ListResponse.fromJson(json['top_10']) : ListResponse(data: []),
      continueWatch: json['continue_watch'] is List ? List<VideoPlayerModel>.from(json['continue_watch'].map((x) => VideoPlayerModel.fromJson(x))) : [],
      latestList: json['latest_movie'] is Map ? ListResponse.fromJson(json['latest_movie']) : ListResponse(data: []),
      topChannelList: json['top_channel'] is Map ? ListResponse.fromJson(json['top_channel']) : ListResponse(data: []),
      popularMovieList: json['popular_movie'] is Map ? ListResponse.fromJson(json['popular_movie']) : ListResponse(data: []),
      popularTvShowList: json['popular_tvshow'] is Map ? ListResponse.fromJson(json['popular_tvshow']) : ListResponse(data: []),
      popularVideoList: json['popular_videos'] is Map ? ListResponse.fromJson(json['popular_videos']) : ListResponse(data: []),
      likeMovieList: json['likedMovies'] is List ? List<VideoPlayerModel>.from(json['likedMovies'].map((x) => VideoPlayerModel.fromJson(x))) : [],
      viewedMovieList: json['viewedMovies'] is List ? List<VideoPlayerModel>.from(json['viewedMovies'].map((x) => VideoPlayerModel.fromJson(x))) : [],
      trendingMovieList: json['tranding_movie'] is List ? List<VideoPlayerModel>.from(json['tranding_movie'].map((x) => VideoPlayerModel.fromJson(x))) : [],
      trendingInCountryMovieList: json['trendingMovies'] is List ? List<VideoPlayerModel>.from(json['trendingMovies'].map((x) => VideoPlayerModel.fromJson(x))) : [],
      basedOnLastWatchMovieList: json['base_on_last_watch'] is List ? List<VideoPlayerModel>.from(json['base_on_last_watch'].map((x) => VideoPlayerModel.fromJson(x))) : [],
      payPerView: json['pay_per_view'] is List ? List<VideoPlayerModel>.from(json['pay_per_view'].map((x) => VideoPlayerModel.fromJson(x))) : [],
      freeMovieList: json['free_movie'] is Map ? ListResponse.fromJson(json['free_movie']) : ListResponse(data: []),
      genreList: json['genres'] is Map ? GenresResponse.fromJson(json['genres']) : GenresResponse(data: []),
      popularLanguageList: json['popular_language'] is Map ? ListResponse.fromJson(json['popular_language']) : ListResponse(data: []),
      actorList: json['personality'] is Map ? PersonModelResponse.fromJson(json['personality']) : PersonModelResponse(data: []),
      favGenreList: json['favorite_gener'] is List ? List<GenreModel>.from(json['favorite_gener'].map((x) => GenreModel.fromJson(x))) : [],
      favActorList: json['favorite_personality'] is List ? List<PersonModel>.from(json['favorite_personality'].map((x) => PersonModel.fromJson(x))) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slider': slider?.map((e) => e.toJson()).toList(),
      'continue_watch': continueWatch.map((e) => e.toJson()).toList(),
      'top_10': top10List?.toJson(),
      'latest_movie': latestList?.toJson(),
      'top_channel': topChannelList?.toJson(),
      'popular_movie': popularMovieList?.toJson(),
      'popular_tvshow': popularTvShowList?.toJson(),
      'popular_videos': popularVideoList?.toJson(),
      'likedMovies': likeMovieList.map((e) => e.toJson()).toList(),
      'viewedMovies': viewedMovieList.map((e) => e.toJson()).toList(),
      'tranding_movie': trendingMovieList.map((e) => e.toJson()).toList(),
      'trendingMovies': trendingInCountryMovieList.map((e) => e.toJson()).toList(),
      'base_on_last_watch': basedOnLastWatchMovieList.map((e) => e.toJson()).toList(),
      'pay_per_view': payPerView.map((e) => e.toJson()).toList(),
      'free_movie': freeMovieList?.toJson(),
      'genres': genreList?.toJson(),
      'popular_language': popularLanguageList?.toJson(),
      'personality': actorList?.toJson(),
      'favorite_gener': favGenreList.map((e) => e.toJson()).toList(),
      'favorite_personality': favActorList.map((e) => e.toJson()).toList(),
    };
  }
}

class SliderModel {
  int id;
  String title;
  String fileUrl;
  String type;
  String bannerURL;
  VideoPlayerModel data;

  SliderModel({
    this.id = -1,
    this.title = "",
    this.fileUrl = "",
    this.bannerURL = "",
    this.type = "",
    required this.data,
  });

  factory SliderModel.fromJson(Map<String, dynamic> json) {
    return SliderModel(
      id: json['id'] is int ? json['id'] : -1,
      title: json['title'] is String ? json['title'] : "",
      fileUrl: json['file_url'] is String ? json['file_url'] : "",
      bannerURL: json['poster_url'] is String ? json['poster_url'] : "",
      type: json['type'] is String ? json['type'] : "",
      data: json['data'] is Map ? VideoPlayerModel.fromJson(json['data']) : VideoPlayerModel(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'file_url': fileUrl,
      'poster_url': bannerURL,
      'type': type,
      'data': data.toJson(),
    };
  }
}

class CategoryListModel {
  String name;
  String sectionType;
  List<dynamic> data;
  bool showViewAll;

  CategoryListModel({
    this.name = "",
    this.sectionType = "",
    this.data = const <dynamic>[],
    this.showViewAll = false,
  });
}

class LangaugeModel {
  int id;
  String name;
  String type;
  String value;
  int sequence;
  dynamic subType;
  int status;
  dynamic createdBy;
  dynamic updatedBy;
  dynamic deletedBy;
  String createdAt;
  String updatedAt;
  dynamic deletedAt;
  String featureImage;
  List<dynamic> media;

  LangaugeModel({
    this.id = -1,
    this.name = "",
    this.type = "",
    this.value = "",
    this.sequence = -1,
    this.subType,
    this.status = -1,
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
    this.createdAt = "",
    this.updatedAt = "",
    this.deletedAt,
    this.featureImage = "",
    this.media = const [],
  });

  factory LangaugeModel.fromJson(Map<String, dynamic> json) {
    return LangaugeModel(
      id: json['id'] is int ? json['id'] : -1,
      name: json['name'] is String ? json['name'] : "",
      type: json['type'] is String ? json['type'] : "",
      value: json['value'] is String ? json['value'] : "",
      sequence: json['sequence'] is int ? json['sequence'] : -1,
      subType: json['sub_type'],
      status: json['status'] is int ? json['status'] : -1,
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      deletedBy: json['deleted_by'],
      createdAt: json['created_at'] is String ? json['created_at'] : "",
      updatedAt: json['updated_at'] is String ? json['updated_at'] : "",
      deletedAt: json['deleted_at'],
      featureImage: json['feature_image'] is String ? json['feature_image'] : "",
      media: json['media'] is List ? json['media'] : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'value': value,
      'sequence': sequence,
      'sub_type': subType,
      'status': status,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'deleted_by': deletedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'feature_image': featureImage,
      'media': [],
    };
  }
}