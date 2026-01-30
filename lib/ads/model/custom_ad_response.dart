class CustomAdResponse {
  final bool? success;
  final List<CustomAd>? data;

  CustomAdResponse({
    this.success,
    this.data,
  });

  factory CustomAdResponse.fromJson(Map<String, dynamic> json) => CustomAdResponse(
        success: json["success"],
        data: json["data"] == null ? [] : List<CustomAd>.from(json["data"]!.map((x) => CustomAd.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class CustomAd {
  final int? id;
  final String? name;
  final String? type;
  final String? urlType;
  final String? placement;
  final String? media;
  final String? redirectUrl;
  final String? targetContentType;
  final String? targetCategories;
  final int? status;
  final DateTime? startDate;
  final DateTime? endDate;

  CustomAd({
    this.id,
    this.name,
    this.type,
    this.urlType,
    this.placement,
    this.media,
    this.redirectUrl,
    this.targetContentType,
    this.targetCategories,
    this.status,
    this.startDate,
    this.endDate,
  });

  factory CustomAd.fromJson(Map<String, dynamic> json) => CustomAd(
        id: json["id"],
        name: json["name"],
        type: json["type"],
        urlType: json["url_type"],
        placement: json["placement"],
        media: json["media"],
        redirectUrl: json["redirect_url"],
        targetContentType: json["target_content_type"],
        targetCategories: json["target_categories"],
        status: json["status"],
        startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
        endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "url_type": urlType,
        "placement": placement,
        "media": media,
        "redirect_url": redirectUrl,
        "target_content_type": targetContentType,
        "target_categories": targetCategories,
        "status": status,
        "start_date": "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
        "end_date": "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
      };
}
