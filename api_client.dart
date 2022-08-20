/// Add dio and dio_pretty_logger into your pubspec.yaml


import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String base_url = "";

class ApiClient {
  static final Dio dio = Dio();
  static final ApiClient _instance = ApiClient._internal();
  static ApiClient get instance => _instance;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal();

  static init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dio.options.baseUrl = base_url;
    dio.options.connectTimeout = 60000;
    dio.options.receiveTimeout = 60000;
    dio.options.headers = {
      HttpHeaders.acceptHeader: "application/json",
      HttpHeaders.contentTypeHeader: "application/json",
      if (prefs.getString("token") != null)
        "Authorization": "Bearer ${prefs.getString("token")}",
    };
    dio.interceptors
        .add(PrettyDioLogger(requestBody: true, requestHeader: true));
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions options, handler) {
      return handler.next(options);
    }, onResponse: (Response response, handler) {
      return handler.next(response);
    }, onError: (DioError e, handler) {
      return handler.next(e);
    }));
  }

  Future get({required String url, Map<String, dynamic>? params}) async {
    try {
      final response = await dio.get(url, queryParameters: params);
      return response.data;
    } on DioError {
      return null;
    }
  }

  Future post({required String url, Map<String, dynamic>? body}) async {
    try {
      final response = await dio.post(url, data: body);
      return response.data;
    } on DioError {
      return null;
    }
  }

  Future put({required String url, Map<String, dynamic>? body}) async {
    try {
      final response = await dio.put(url, data: body);
      return response.data;
    } on DioError {
      return null;
    }
  }

  Future delete({required String url, Map<String, dynamic>? body}) async {
    try {
      final response = await dio.delete(url, data: body);
      return response.data;
    } on DioError {
      return null;
    }
  }

  Future requestWithFile(
      {required String url,
      Map<String, dynamic>? body,
      required List<File> files}) async {
    try {
      FormData formData = FormData.fromMap(body ?? {});
      for (File file in files) {
        formData.files.add(MapEntry(
            "file",
            await MultipartFile.fromFile(file.path,
                filename: file.path.split("/").last)));
      }
      final response = await dio.post(url, data: formData);
      return response.data;
    } on DioError {
      return null;
    }
  }
}
