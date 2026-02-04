import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/ads/model/custom_ad_response.dart';
import 'package:streamit_laravel/network/network_utils.dart';
import 'package:streamit_laravel/screens/coming_soon/model/coming_soon_response.dart';
import 'package:streamit_laravel/screens/genres/model/genres_model.dart';
import 'package:streamit_laravel/screens/home/model/dashboard_res_model.dart';
import 'package:streamit_laravel/screens/live_tv/live_tv_details/model/live_tv_details_response.dart';
import 'package:streamit_laravel/screens/live_tv/model/live_tv_dashboard_response.dart';
import 'package:streamit_laravel/screens/payment/model/pay_per_view_model.dart';
import 'package:streamit_laravel/screens/payment/model/subscription_model.dart';
import 'package:streamit_laravel/screens/profile/model/profile_detail_resp.dart';
import 'package:streamit_laravel/screens/profile/watching_profile/model/profile_watching_model.dart';
import 'package:streamit_laravel/screens/rented_content/model/rent_content_model.dart';
import 'package:streamit_laravel/screens/search/model/search_response.dart';
import 'package:streamit_laravel/screens/setting/model/faq_model.dart';
import 'package:streamit_laravel/screens/subscription/model/rental_history_model.dart';
import 'package:streamit_laravel/screens/subscription/model/subscription_model.dart';
import 'package:streamit_laravel/screens/video/video_details/model/video_details_resp.dart';
import 'package:streamit_laravel/screens/watch_list/model/watch_list_resp.dart';
import 'package:streamit_laravel/utils/app_common.dart';
import 'package:streamit_laravel/utils/constants.dart';
import 'package:streamit_laravel/video_players/model/vast_ad_response.dart';

import '../main.dart';
import '../models/base_response_model.dart';
import '../screens/auth/model/about_page_res.dart';
import '../screens/channel_list/model/channel_list_model.dart';
import '../screens/coupon/model/coupon_list_model.dart';
import '../screens/movie_details/model/movie_details_resp.dart';
import '../screens/person/model/person_model.dart';
import '../screens/person/person_list/model/person_list_resp.dart';
import '../screens/review_list/model/review_model.dart';
import '../screens/search/model/search_list_model.dart';
import '../screens/setting/account_setting/model/account_setting_response.dart';
import '../screens/subscription/model/subscription_plan_model.dart';
import '../screens/tv_show/episode/models/episode_model.dart';
import '../screens/tv_show/models/tv_show_model.dart';
import '../utils/api_end_points.dart';
import '../utils/common_base.dart';
import '../video_players/model/video_model.dart';

class CoreServiceApis {
  Future<DashboardDetailResponse> getDashboard() async {
    final List<String> params = [];
    if (loginUserData.value.id > -1) {
      params.add('user_id=${loginUserData.value.id}');
      if (profileId.value != 0) params.add('profile_id=${profileId.value}');
      if (selectedAccountProfile.value.isChildProfile.validate() == 1) {
        params.add('is_restricted=0');
      }
    }

    final DashboardDetailResponse dashboardDetailsResp =
        DashboardDetailResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(
            endPoint: APIEndPoints.dashboardDetails,
            params: params,
          ),
          manageApiVersion: true,
        ),
      ),
    );
    cachedDashboardDetailResponse = dashboardDetailsResp;
    setValue(
      SharedPreferenceConst.CACHE_DASHBOARD,
      dashboardDetailsResp.toJson(),
    );

    return dashboardDetailsResp;
  }

  Future<DashboardDetailResponse> getDashboardDetailOtherData() async {
    final List<String> params = [];
    if (loginUserData.value.id > -1) {
      params.add('user_id=${loginUserData.value.id}');
      if (profileId.value != 0) params.add('profile_id=${profileId.value}');
      if (selectedAccountProfile.value.isChildProfile.validate() == 1) {
        params.add('is_restricted=0');
      }
    }

    final DashboardDetailResponse dashboardDetailsResp =
        DashboardDetailResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(
              endPoint: APIEndPoints.dashboardDetailsOtherData, params: params,),
          manageApiVersion: true,
        ),
      ),
    );
    if (cachedDashboardDetailResponse != null) {
      final DashboardDetailResponse res = cachedDashboardDetailResponse ??
          DashboardDetailResponse(data: DashboardModel());
      cachedDashboardDetailResponse = dashboardDetailsResp;

      cachedDashboardDetailResponse?.data.slider = res.data.slider;
      cachedDashboardDetailResponse?.data.continueWatch =
          res.data.continueWatch;
      cachedDashboardDetailResponse?.data.top10List = res.data.top10List;
    }
    setValue(
      SharedPreferenceConst.CACHE_DASHBOARD,
      dashboardDetailsResp.toJson(),
    );

    return dashboardDetailsResp;
  }

  Future<LiveChannelDashboardResponse> getLiveDashboard() async {
    final LiveChannelDashboardResponse liveChannelDashboardResp =
        LiveChannelDashboardResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.liveTvDashboard,
          manageApiVersion: true,
        ),
      ),
    );
    cachedLiveTvDashboard = liveChannelDashboardResp;
    setValue(
      SharedPreferenceConst.CACHE_LIVE_TV_DASHBOARD,
      liveChannelDashboardResp.toJson(),
    );
    return liveChannelDashboardResp;
  }

  // Original Search Details
  Future<SearchResponse> getSearchDetails({required String search}) async {
    final List<String> params = [];
    if (loginUserData.value.id > -1) {
      if (selectedAccountProfile.value.isChildProfile.validate() == 1) {
        params.add('is_restricted=0');
      }
    }
    if (search.isNotEmpty) params.add('search=$search');
    return SearchResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.getSearchMovie, params: params),
        ),
      ),
    );
  }

  // Original Search List
  Future<SearchListResponse> getSearchList() async {
    final List<String> params = [];
    if (profileId.value != 0) params.add('profile_id=${profileId.value}');
    return SearchListResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.searchList, params: params),
        ),
      ),
    );
  }

  //Profile Details Screen
  Future<ProfileDetailResponse> getProfileDet() async {
    final List<String> params = [];
    if (profileId.value != 0) params.add('profile_id=${profileId.value}');
    final ProfileDetailResponse profileDetailResp =
        ProfileDetailResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.profileDetails, params: params),
          manageApiVersion: true,
        ),
      ),
    );
    cachedProfileDetails = profileDetailResp;
    setValue(
      SharedPreferenceConst.CACHE_PROFILE_DETAIL,
      profileDetailResp.toJson(),
    );
    return profileDetailResp;
  }

  //Account Setting Screen
  Future<AccountSettingResponse> getAccountSettingsResponse(
      {required String deviceId,}) async {
    final String id = deviceId.isNotEmpty ? "?device_id=$deviceId" : "";
    return AccountSettingResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          "${APIEndPoints.accountSetting}$id",
        ),
      ),
    );
  }

  //Live Show details
  Future<LiveShowDetailResponse> getLiveShowDetails(
      {required int channelId, int userId = -1,}) async {
    final List<String> params = [];
    if (loginUserData.value.id > -1) {
      params.add('user_id=${loginUserData.value.id}');
    }

    params.add('channel_id=$channelId');
    if (profileId.value != 0) params.add('profile_id=${profileId.value}');
    return LiveShowDetailResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.liveTvDetails, params: params),
        ),
      ),
    );
  }

  //Movie Details
  Future<MovieDetailResponse> getMovieDetails(
      {required int movieId, int userId = -1,}) async {
    final List<String> params = [];
    params.add('movie_id=$movieId');
    params.add('device_id=${yourDevice.value.deviceId}');
    if (loginUserData.value.id > -1) {
      params.add('user_id=${loginUserData.value.id}');
    }
    if (profileId.value != 0) params.add('profile_id=${profileId.value}');
    return MovieDetailResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.movieDetails, params: params),
          manageApiVersion: true,
        ),
      ),
    );
  }

  //Video Details
  Future<VideoDetailResponse> getVideoDetails(
      {required int movieId, int userId = -1,}) async {
    final List<String> params = [];
    if (loginUserData.value.id > -1) {
      params.add('user_id=${loginUserData.value.id}');
    }

    params.add('video_id=$movieId');
    params.add('device_id=${yourDevice.value.deviceId}');
    if (profileId.value != 0) params.add('profile_id=${profileId.value}');
    return VideoDetailResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.videoDetails, params: params),
        ),
      ),
    );
  }

  //Episode Details
  Future<EpisodeModel> episodeDetails(
      {required int episodeId,
      int userId = -1,
      required int tvShowId,
      required int seasonId,}) async {
    final List<String> params = [];
    if (loginUserData.value.id > -1) {
      params.add('user_id=${loginUserData.value.id}');
    }
    params.add('device_id=${yourDevice.value.deviceId}');
    params.add('episode_id=$episodeId');
    if (tvShowId > -1) params.add('tv_show=$tvShowId');
    if (seasonId > -1) params.add('season_id=$seasonId');

    if (profileId.value != 0) params.add('profile_id=${profileId.value}');
    final EpisodeDetailResponse episodeListResp =
        EpisodeDetailResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.episodeDetails, params: params),
          manageApiVersion: true,
        ),
      ),
    );
    return episodeListResp.data.first;
  }

  //TvShow Details
  Future<TvShowModel> getTvShowDetails(
      {required int showId, int userId = -1,}) async {
    final List<String> params = [];
    params.add('tvshow_id=$showId');
    params.add('device_id=${yourDevice.value.deviceId}');
    if (loginUserData.value.id > -1) {
      params.add('user_id=${loginUserData.value.id}');
    }
    if (profileId.value != 0) params.add('profile_id=${profileId.value}');
    return TvShowModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.tvShowDetails, params: params),
          manageApiVersion: true,
        ),
      ),
    );
  }

// Add/Edit Rating
  Future<BaseResponseModel> addRating({required Map request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.saveRating,
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  Future<BaseResponseModel> deleteRating({required Map request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.deleteRating,
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  // Save Download API
  Future<BaseResponseModel> saveDownload({required Map request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.saveDownload,
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  Future<BaseResponseModel> deleteFromDownload(
      {required List<int> idList,}) async {
    final List<String> params = [];
    params.add('id=${idList.join(',')}');
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.deleteDownloads, params: params),
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  // Save Continue Watch List API
  Future<BaseResponseModel> saveContinueWatch({required Map request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.saveContinueWatch,
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  // Like Movie
  Future<BaseResponseModel> likeMovie({required Map request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.saveLikes,
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  // Watch List Movie
  Future<BaseResponseModel> saveWatchList({required Map request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.saveWatchlist,
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  // Store View Movie
  Future<BaseResponseModel> storeViewDetails({required Map request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.saveEntertainmentViews,
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  // Save Reminder
  Future<BaseResponseModel> saveReminder({required Map request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.saveReminder,
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  // Save Subscription Details
  Future<SubscriptionResponseModel> saveSubscriptionDetails(
      {required Map request,}) async {
    return SubscriptionResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.saveSubscriptionDetails,
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  // Cancel Subscription Details
  Future<SubscriptionResponseModel> cancelSubscription(
      {required Map request,}) async {
    return SubscriptionResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.cancelSubscription,
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  //Get Genres List
  Future<RxList<GenreModel>> getGenresList({
    int page = 1,
    int? perPage,
    required List<GenreModel> getGenresList,
    Function(bool)? lastPageCallBack,
  }) async {
    perPage ??= determinePerPage();
    final genresDetails = GenresResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          "${APIEndPoints.genresDetails}?per_page=$perPage&page=$page",
        ),
      ),
    );
    if (page == 1) getGenresList.clear();
    getGenresList.addAll(genresDetails.data);
    lastPageCallBack?.call(genresDetails.data.length != perPage);
    return getGenresList.obs;
  }

  //Get Actor List
  Future<RxList<PersonModel>> getActorsList({
    String castType = "",
    int page = 1,
    int? perPage,
    required List<PersonModel> getActorList,
    Function(bool)? lastPageCallBack,
  }) async {
    final List<String> params = [];
    if (castType.isNotEmpty) params.add('type=$castType');
    perPage ??= determinePerPage();
    params.add('per_page=$perPage&page=$page');
    final actorDetails = PersonListResp.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.actorDetails, params: params),
        ),
      ),
    );
    if (page == 1) getActorList.clear();
    getActorList.addAll(actorDetails.data);
    lastPageCallBack?.call(actorDetails.data.length != perPage);
    cachedPersonList(getActorList);
    return getActorList.obs;
  }

  // Movie List API
  Future<RxList<VideoPlayerModel>> getMoviesList({
    int page = 1,
    int? perPage,
    int actorId = -1,
    int genresId = -1,
    String language = "",
    required List<VideoPlayerModel> getMovieList,
    Function(bool)? lastPageCallBack,
  }) async {
    final List<String> params = [];
    perPage ??= determinePerPage();
    params.add('per_page=$perPage&page=$page');
    if (loginUserData.value.id > -1) {
      params.add('user_id=${loginUserData.value.id}');
    }
    if (actorId > -1) params.add('actor_id=$actorId');
    if (genresId > -1) params.add('genre_id=$genresId');
    if (language.isNotEmpty) params.add('language=$language');
    if (loginUserData.value.id > -1) {
      if (selectedAccountProfile.value.isChildProfile.validate() == 1) {
        params.add('is_restricted=0');
      }
    }

    final ListResponse movieList = ListResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.movieLists, params: params),
          manageApiVersion: true,
        ),
      ),
    );
    if (page == 1) getMovieList.clear();
    getMovieList.addAll(movieList.data);
    lastPageCallBack?.call(movieList.data.validate().length != perPage);
    return getMovieList.obs;
  }

  Future<RxList<SliderModel>> getSliderDetail({
    required List<SliderModel> getBannerList,
    required String type,
  }) async {
    final List<String> params = [];
    params.add('type=$type');
    if (loginUserData.value.id > -1) {
      if (selectedAccountProfile.value.isChildProfile.validate() == 1) {
        params.add('is_restricted=0');
      }
    }

    final response = await handleResponse(
      await buildHttpResponse(
        getEndPoint(
          endPoint: APIEndPoints.bannerList,
          params: params,
        ),
      ),
    );
    if (response is Map &&
        response['data'] is Map &&
        response['data']['slider'] is List) {
      final bannerList = (response['data']['slider'] as List)
          .map((json) => SliderModel.fromJson(json))
          .toList();
      return RxList<SliderModel>(bannerList);
    } else {
      return RxList<SliderModel>();
    }
  }

// Movie List API
  Future<RxList<ChannelModel>> getChannelList({
    int page = 1,
    int perPage = 10,
    int category = -1,
    required List<ChannelModel> getChannelList,
    Function(bool)? lastPageCallBack,
  }) async {
    final List<String> params = [];
    params.add('per_page=$perPage&page=$page');
    if (category > -1) params.add('category_id=$category');
    final channelList = ChannelListModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.channelList, params: params),
        ),
      ),
    );
    if (page == 1) getChannelList.clear();
    getChannelList.addAll(channelList.data.channel);
    lastPageCallBack?.call(channelList.data.channel.length != perPage);
    return getChannelList.obs;
  }

  // TvShow List API
  Future<RxList<VideoPlayerModel>> getTvShowsList({
    int page = 1,
    int? perPage,
    required List<VideoPlayerModel> getTvShowList,
    Function(bool)? lastPageCallBack,
  }) async {
    final List<String> params = [];
    perPage ??= determinePerPage();
    params.add('per_page=$perPage&page=$page');
    if (loginUserData.value.id > -1) {
      if (selectedAccountProfile.value.isChildProfile.validate() == 1) {
        params.add('is_restricted=0');
      }

      params.add('user_id=${loginUserData.value.id}');
    }
    final tvshowList = ListResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.tvShowList, params: params),
          manageApiVersion: true,
        ),
      ),
    );
    if (page == 1) getTvShowList.clear();
    getTvShowList.addAll(tvshowList.data);
    lastPageCallBack?.call(tvshowList.data.length != perPage);

    return getTvShowList.obs;
  }

  // Plan List API
  Future<RxList<SubscriptionPlanModel>> getPlanList({
    required List<SubscriptionPlanModel> getPlanList,
  }) async {
    final planList = SubscriptionResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.planLists,
        ),
      ),
    );
    getPlanList.addAll(planList.data);
    return getPlanList.obs;
  }

  //Get Coming Soon List
  Future<RxList<ComingSoonModel>> getComingSoonList({
    int page = 1,
    int perPage = 10,
    required List<ComingSoonModel> getComingSoonList,
    Function(bool)? lastPageCallBack,
  }) async {
    final List<String> params = [];
    if (loginUserData.value.id > -1) {
      params.add('user_id=${loginUserData.value.id}');
    }
    if (profileId.value != 0) params.add('profile_id=${profileId.value}');
    params.add('per_page=$perPage&page=$page');
    final ComingSoonResponse comingSoonDetails = ComingSoonResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.comingSoon, params: params),
        ),
      ),
    );
    if (page == 1) getComingSoonList.clear();
    getComingSoonList.addAll(comingSoonDetails.data);
    lastPageCallBack?.call(comingSoonDetails.data.length != perPage);
    cachedComingSoonList(getComingSoonList);
    return getComingSoonList.obs;
  }

  //Get Continue Watching List

  Future<RxList<VideoPlayerModel>> getContinueWatchingList({
    int page = 1,
    int? perPage,
    required List<VideoPlayerModel> continueWatchList,
    Function(bool)? lastPageCallBack,
  }) async {
    final List<String> params = [];
    perPage ??= determinePerPage();
    if (profileId.value != 0) params.add('profile_id=${profileId.value}');
    if (isLoggedIn.value) params.add('user_id=${loginUserData.value.id}');
    params.add('per_page=$perPage&page=$page');

    final ListResponse listResponse = ListResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.continueWatchList, params: params),
        ),
      ),
    );
    if (page == 1) continueWatchList.clear();
    continueWatchList.addAll(listResponse.data);
    lastPageCallBack?.call(listResponse.data.length != perPage);
    return continueWatchList.obs;
  }

//region Remove from Continue Watching
  Future<BaseResponseModel> removeContinueWatching(
      {required int continueWatchingId,}) async {
    final List<String> params = [];
    params.add('id=$continueWatchingId');
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(
              endPoint: APIEndPoints.deleteContinueWatch, params: params,),
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

//Get Watch List
  Future<RxList<VideoPlayerModel>> getWatchList({
    int page = 1,
    int? perPage,
    required List<VideoPlayerModel> getWatchList,
    Function(bool)? lastPageCallBack,
  }) async {
    final List<String> params = [];
    perPage ??= determinePerPage();
    if (profileId.value != 0) params.add('profile_id=${profileId.value}');
    if (loginUserData.value.id > -1) {
      params.add('user_id=${loginUserData.value.id}');
    }
    params.add('per_page=$perPage&page=$page');

    final ListResponse listResponse = ListResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.watchList, params: params),
        ),
      ),
    );
    if (page == 1) getWatchList.clear();
    getWatchList.addAll(listResponse.data);
    lastPageCallBack?.call(listResponse.data.length != perPage);
    return getWatchList.obs;
  }

  Future<BaseResponseModel> deleteFromWatchlist(
      {required List<int> idList,}) async {
    final List<String> params = [];
    params.add('id=${idList.join(',')}');
    params.add("profile_id=${profileId.value}");
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.deleteWatchList, params: params),
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

//Get Video List
  Future<RxList<VideoPlayerModel>> getVideoList({
    int page = 1,
    int? perPage,
    required List<VideoPlayerModel> getVideoList,
    Function(bool)? lastPageCallBack,
  }) async {
    final List<String> params = [];
    perPage ??= determinePerPage();
    if (loginUserData.value.id > -1) {
      params.add('user_id=${loginUserData.value.id}');
    }
    params.add('per_page=$perPage&page=$page');
    if (loginUserData.value.id > -1) {
      if (selectedAccountProfile.value.isChildProfile.validate() == 1) {
        params.add('is_restricted=0');
      }
    }
    final videoList = ListResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.videoList, params: params),
        ),
      ),
    );
    if (page == 1) getVideoList.clear();
    getVideoList.addAll(videoList.data);
    lastPageCallBack?.call(videoList.data.length != perPage);
    return getVideoList.obs;
  }

//Get Episodes List
  Future<RxList<EpisodeModel>> getEpisodesList({
    int page = 1,
    int perPage = 10,
    required int showId,
    int seasonId = -1,
    required List<EpisodeModel> episodeList,
    Function(bool)? lastPageCallBack,
  }) async {
    final List<String> params = [];
    params.add('per_page=$perPage&page=$page');
    if (loginUserData.value.id > -1) {
      params.add('user_id=${loginUserData.value.id}');
    }
    if (seasonId > -1) params.add('season_id=$seasonId');
    if (showId > -1) params.add('show_id=$showId');
    final EpisodeDetailResponse it = EpisodeDetailResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.episodeList, params: params),
        ),
      ),
    );
    if (page == 1) episodeList.clear();

    lastPageCallBack?.call(it.data.length < perPage);
    episodeList.addAll(it.data);

    return episodeList.obs;
  }

//Get Review List
  Future<RxList<ReviewModel>> getReviewList({
    int page = 1,
    int perPage = 10,
    int movieId = -1,
    required List<ReviewModel> getReviewList,
    Function(bool)? lastPageCallBack,
  }) async {
    final List<String> params = [];
    params.add('per_page=$perPage&page=$page');
    if (movieId > -1) params.add('entertainment_id=$movieId');
    final reviewDetails = ReviewResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.reviewDetails, params: params),
        ),
      ),
    );
    if (page == 1) getReviewList.clear();
    getReviewList.addAll(reviewDetails.data);
    lastPageCallBack?.call(reviewDetails.data.length != perPage);
    return getReviewList.obs;
  }

//Edit Profile API
  Future<void> updateProfileReq({
    required Map<String, dynamic> request,
    List<File>? files,
    VoidCallback? onSuccess,
  }) async {
    final multiPartRequest =
        await getMultiPartRequest(APIEndPoints.editProfile);
    multiPartRequest.fields.addAll(
      await getMultipartFields(val: request),
    );

    if (files.validate().isNotEmpty) {
      multiPartRequest.files.add(
        await http.MultipartFile.fromPath(
          'file_url',
          files.validate().first.path.validate(),
        ),
      );
    }

    log("Multipart ${jsonEncode(multiPartRequest.fields)}");
    log("Multipart Files ${multiPartRequest.files.map((e) => e.filename)}");
    log("Multipart Extension ${multiPartRequest.files.map((e) => e.filename!.split(".").last)}");
    multiPartRequest.headers.addAll(buildHeaderTokens());

    await sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (temp) async {
        log("Response: ${jsonDecode(temp)}");
        final baseResponseModel = BaseResponseModel.fromJson(
          jsonDecode(temp),
        );
        toast(baseResponseModel.message, print: true);
        onSuccess?.call();
      },
      onError: (error, data) {
        throw error;
      },
    );
  }

//Page List Setting Screen
  Future<AboutPageResponse> getPageList() async {
    return AboutPageResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.pageList,
        ),
      ),
    );
  }

  Future<BaseResponseModel> saveViewCompleted({required Map request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.saveEntertainmentCompletedView,
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

//region Watching Profile
// Watching Profile List
  Future<RxList<WatchingProfileModel>> getWatchingProfileList({
    int page = 1,
    int perPage = 10,
    required List<WatchingProfileModel> profileList,
    Function(bool)? lastPageCallBack,
  }) async {
    final List<String> params = [];
    params.add('per_page=$perPage&page=$page');
    try {
      final WatchingProfileResponse profileResponseModel =
          WatchingProfileResponse.fromJson(
        await handleResponse(
          await buildHttpResponse(
            getEndPoint(
                endPoint: APIEndPoints.getWatchingProfileList, params: params,),
          ),
        ),
      );
      if (page == 1) profileList.clear();
      profileList.addAll(profileResponseModel.data);
      lastPageCallBack?.call(profileResponseModel.data.length != perPage);
    } catch (e) {
      rethrow;
    }
    return profileList.obs;
  }

// Watching Edit Profile
  Future<WatchingProfileResponse> updateWatchProfile({
    required Map<String, dynamic> request,
    List<File>? files,
    VoidCallback? onSuccess,
  }) async {
    final multiPartRequest =
        await getMultiPartRequest(APIEndPoints.editWatchingProfile);
    multiPartRequest.fields.addAll(await getMultipartFields(val: request));

    if (files.validate().isNotEmpty) {
      multiPartRequest.files.add(
        await http.MultipartFile.fromPath(
          'file_url',
          files.validate().first.path.validate(),
        ),
      );
    }

    multiPartRequest.headers.addAll(buildHeaderTokens());
    WatchingProfileResponse profileWatchingResponseModel =
        WatchingProfileResponse(newUserProfile: WatchingProfileModel());
    await sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (temp) async {
        profileWatchingResponseModel =
            WatchingProfileResponse.fromJson(jsonDecode(temp));
      },
      onError: (error, response) {
        profileWatchingResponseModel = WatchingProfileResponse(
          newUserProfile: WatchingProfileModel(),
        );
        if (response.statusCode == 406) {
          throw {
            "error": error,
            "status_code": response.statusCode,
          };
        } else {
          throw error;
        }
      },
    );
    return profileWatchingResponseModel;
  }

// Watching Delete Profile
  Future<BaseResponseModel> deleteWatchingProfile(
      {required Map request,}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.deleteWatchingProfile,
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  /// Search Apis
// Save search
  Future<WatchingProfileResponse> saveSearch({required Map request}) async {
    return WatchingProfileResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.saveSearch,
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

// Clear All
  Future<WatchingProfileResponse> clearAll(int? isProfileID) async {
    return WatchingProfileResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          "${APIEndPoints.deleteSearch}?profile_id=$isProfileID&type=clear_all",
        ),
      ),
    );
  }

// Particular Search Delete
  Future<BaseResponseModel> particularSearchDelete(
      int id, int profileId,) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          "${APIEndPoints.deleteSearch}?profile_id=$profileId&id=$id",
        ),
      ),
    );
  }

  Future<List<FAQModel>> getFAQList({
    int page = 1,
    int perPage = 10,
    required List<FAQModel> faqList,
    Function(bool)? lastPageCallBack,
  }) async {
    final List<String> params = [];
    params.add('per_page=$perPage&page=$page');
    final FAQResponse res = FAQResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.faqList, params: params),
        ),
      ),
    );
    if (page == 1) faqList.clear();
    lastPageCallBack?.call(res.data.length != perPage);
    faqList.addAll(res.data);

    return faqList;
  }

// Plan List API
  Future<RxList<SubscriptionPlanModel>> getSubscriptionHistory({
    int page = 1,
    int perPage = 10,
    required List<SubscriptionPlanModel> subscriptionHistoryList,
    Function(bool)? lastPageCallBack,
  }) async {
    final List<String> params = [];
    params.add('per_page=$perPage&page=$page');
    final SubscriptionResponse profileResponseModel =
        SubscriptionResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(
              endPoint: APIEndPoints.subscriptionHistory, params: params,),
        ),
      ),
    );
    if (page == 1) subscriptionHistoryList.clear();
    subscriptionHistoryList.addAll(profileResponseModel.data);
    lastPageCallBack?.call(profileResponseModel.data.length != perPage);
    return subscriptionHistoryList.obs;
  }

  //Get Coupon List
  Future<RxList<CouponDataModel>> getCouponListApi({
    int page = 1,
    String couponCode = "",
    int? perPage,
    required String planId,
    required List<CouponDataModel> couponList,
    Function(bool)? lastPageCallBack,
  }) async {
    final List<String> params = [];
    perPage ??= determinePerPage();
    params.add('plan_id=$planId');
    if (couponCode.isNotEmpty) params.add('coupon_code=$couponCode');
    params.add('per_page=$perPage&page=$page');

    final CouponListResponse couponListResponse = CouponListResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.couponList, params: params),
        ),
      ),
    );
    if (page == 1) couponList.clear();
    couponList.addAll(couponListResponse.data);
    lastPageCallBack?.call(couponListResponse.data.length != perPage);
    return couponList.obs;
  }

  Future<BaseResponseModel> changePin(String pin, String confirmPin) async {
    final List<String> params = [];
    params.add('pin=$pin');
    params.add('confirm_pin=$confirmPin');
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.changePin, params: params),
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  Future<BaseResponseModel> sendOtp(int userId) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          "${APIEndPoints.sendOtp}?user_id=$userId",
        ),
      ),
    );
  }

  Future<BaseResponseModel> verifyOtp(int userId, String otp) async {
    final List<String> params = [];
    params.add('user_id=$userId');
    params.add('otp=$otp');
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.verifyOtp, params: params),
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  Future<BaseResponseModel> updateParentalLock(
      Map<String, dynamic> request,) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.updateParentalLock),
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  // QR Code Scan Link TV API
  Future<BaseResponseModel> linkTvAPI({required Map request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.linkTv,
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  Future<PayPerViewModel> saveRentDetails({required Map request}) async {
    return PayPerViewModel.fromJson(await handleResponse(
        await buildHttpResponse(APIEndPoints.saveRentDetails,
            request: request, method: HttpMethodType.POST,),),);
  }

  Future<RxList<VideoPlayerModel>> getRentedContent({
    int page = 1,
    int? perPage,
    int actorId = -1,
    int genresId = -1,
    String language = "",
    required List<VideoPlayerModel> rentedContentList,
    Function(bool)? lastPageCallBack,
  }) async {
    final List<String> params = [];
    perPage ??= determinePerPage();
    params.add('per_page=$perPage&page=$page');
    if (loginUserData.value.id > -1) {
      params.add('user_id=${loginUserData.value.id}');
      if (selectedAccountProfile.value.isChildProfile.validate() == 1) {
        params.add('is_restricted=0');
      }
    }

    final RentedContent movieList = RentedContent.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.rentedContentList, params: params),
        ),
      ),
    );
    if (page == 1) rentedContentList.clear();
    rentedContentList.addAll(movieList.data.movies +
        movieList.data.tvshows +
        movieList.data.videos +
        movieList.data.episodes,);
    lastPageCallBack?.call((movieList.data.movies.length +
            movieList.data.tvshows.length +
            movieList.data.videos.length +
            movieList.data.episodes.length) !=
        perPage,);
    return rentedContentList.obs;
  }

  Future<RxList<VideoPlayerModel>> getPayPerViewList({
    int page = 1,
    int? perPage,
    required List<VideoPlayerModel> getPayPerViewList,
    Function(bool)? lastPageCallBack,
  }) async {
    final List<String> params = [];
    perPage ??= determinePerPage();
    params.add('per_page=$perPage&page=$page');
    if (loginUserData.value.id > -1) {
      params.add('user_id=${loginUserData.value.id}');
      if (selectedAccountProfile.value.isChildProfile.validate() == 1) {
        params.add('is_restricted=0');
      }
    }

    final ListResponse payPerViewList = ListResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.payPerViewList, params: params),
        ),
      ),
    );
    if (page == 1) getPayPerViewList.clear();
    getPayPerViewList.addAll(payPerViewList.data);
    lastPageCallBack?.call(payPerViewList.data.length != perPage);
    return getPayPerViewList.obs;
  }

  Future<BaseResponseModel> startDate({required Map request}) async {
    return BaseResponseModel.fromJson(await handleResponse(
        await buildHttpResponse(APIEndPoints.startDate,
            request: request, method: HttpMethodType.POST,),),);
  }

  Future<RxList<RentalHistoryItem>> getRentalHistory({
    int page = 1,
    int perPage = 10,
    required List<RentalHistoryItem> rentalList,
    Function(bool)? lastPageCallBack,
  }) async {
    final List<String> params = [];
    params.add('per_page=$perPage&page=$page');
    if (loginUserData.value.id > -1) {
      params.add('user_id=${loginUserData.value.id}');
    }

    final RentalHistoryModel res = RentalHistoryModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(
            endPoint: APIEndPoints.rentalHistory,
            params: params,
          ),
        ),
      ),
    );
    if (page == 1) rentalList.clear();
    lastPageCallBack?.call(res.data.length != perPage);
    rentalList.addAll(res.data);

    return rentalList.obs;
  }

  Future<VastAdResponse?> getVastAds() async {
    final VastAdResponse res = VastAdResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(
            endPoint: APIEndPoints.getActiveVastAds,
          ),
        ),
      ),
    );
    if (res.success.validate()) {
      return res;
    } else {
      return null;
    }
  }

  Future<CustomAdResponse?> getCustomAds() async {
    final CustomAdResponse res = CustomAdResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(
            endPoint: APIEndPoints.getCustomAds,
          ),
        ),
      ),
    );
    if (res.success.validate()) {
      return res;
    } else {
      return null;
    }
  }

  // Social Media APIs
  Future<BaseResponseModel> createSocialPost({
    required Map<String, dynamic> request,
    List<File>? files,
  }) async {
    try {
      log('=== Creating Social Post API Call ===');
      log('URL: ${APIEndPoints.createSocialPost}');
      log('Request: $request');
      log('Files: ${files?.length ?? 0}');

      // Create multipart request directly to the social API
      final multipartRequest = http.MultipartRequest(
        'POST',
        Uri.parse(APIEndPoints.createSocialPost),
      );

      // Add form fields
      request.forEach((key, value) {
        multipartRequest.fields[key] = value.toString();
      });

      // Add image file if provided
      if (files != null && files.isNotEmpty) {
        final file = files.first;
        log('Adding image file: ${file.path}');
        multipartRequest.files.add(
          await http.MultipartFile.fromPath(
            'image',
            file.path,
          ),
        );
      }

      // Add headers
      multipartRequest.headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      });

      log('Sending multipart request...');
      final streamedResponse = await multipartRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return BaseResponseModel.fromJson(responseData);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      log('Error in createSocialPost: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSocialPosts({
    int page = 1,
    int perPage = 10,
    int? userId,
    required void Function(Map<String, dynamic>) onSuccess,
    required void Function(Map<String, dynamic>) onFailure,
    required void Function(String) onError,
  }) async {
    final List<String> params = [];
    params.add('action=get_user_posts');
    if (userId != null) params.add('user_id=$userId');
    params.add('page=$page');
    params.add('per_page=$perPage');

    // Build the URL directly since it's a full URL
    String url = APIEndPoints.getSocialPosts;
    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        onSuccess(jsonDecode(response.body));
        return jsonDecode(response.body);
      } else {
        onFailure(jsonDecode(response.body));
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      onError('Error in getSocialPosts: $e');
      log('Error in getSocialPosts: $e');
      rethrow;
    }
  }
}
