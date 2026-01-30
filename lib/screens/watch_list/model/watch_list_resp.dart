import '../../../video_players/model/video_model.dart';

class ListResponse {
  bool status;
  String message;
  String name;
  List<VideoPlayerModel> data;

  ListResponse({
    this.status = false,
    this.message = "",
    this.name = "",
    this.data = const <VideoPlayerModel>[],
  });

  factory ListResponse.fromJson(Map<String, dynamic> json) {
    return ListResponse(
      status: json['status'] is bool ? json['status'] : false,
      message: json['message'] is String ? json['message'] : "",
      name: json['name'] is String ? json['name'] : '',
      data: json['data'] is List ? List<VideoPlayerModel>.from(json['data'].map((x) => VideoPlayerModel.fromJson(x))) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'name': name,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}