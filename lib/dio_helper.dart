import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:live_chat_app/network/interceptors/app_interceptors.dart';
import 'package:live_chat_app/network/token_services/token_service.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioHelper {
  static late Dio dio;

  static Future<void> init() async {
    dio = Dio();
    Duration timeout = const Duration(milliseconds: 60000);

    Map<String, String> headers = {
      'Accept': 'application/json',
    };
    dio.options = BaseOptions(
        headers: headers,
        validateStatus: (status) => true,
        receiveDataWhenStatusError: true,
        connectTimeout: timeout,
        receiveTimeout: timeout);
    dio.interceptors.add(AppInterceptors(dio, TokenService()));
    // dio.interceptors.add(
    //   InterceptorsWrapper(
    //     onRequest: (options, handler) {
    //       // Add the access token to the request header
    //       options.headers['Authorization'] = 'Bearer $token';
    //       return handler.next(options);
    //     },
    //     onError: (DioException e, handler) async {
    //       if (e.response?.statusCode == 401) {
    //         // If a 401 response is received, refresh the access token
    //         String newAccessToken = await ApiServices.refreshToken();

    //         // Update the request header with the new access token
    //         e.requestOptions.headers['Authorization'] =
    //             'Bearer $newAccessToken';

    //         // Repeat the request with the updated header
    //         return handler.resolve(await dio.fetch(e.requestOptions));
    //       }
    //       return handler.next(e);
    //     },
    //   ),
    // );

    if (kDebugMode) {
      dio.interceptors.add(PrettyDioLogger(
          responseBody: true, requestHeader: true, responseHeader: true));
    }
  }

  static Future<Response> postImageData({
    required String url,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    required data,
  }) async {
    try {
      // Make the API request with headers and formData
      dio.options.headers = headers ?? {};
      Response response = await dio.post(
        url,
        queryParameters:
            query ?? {}, // Use provided query parameters or empty map
        data: data,
      );

      return response;
    } catch (e) {
      // Handle the error if the request fails
      print(e);
      throw Exception('Error in making POST request: $e');
    }
  }

  static Future<Response> patchImageData({
    required String url,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    required data,
  }) async {
    try {
      // Make the API request with headers and formData
      dio.options.headers = headers ?? {};
      Response response = await dio.patch(
        url,
        queryParameters:
            query ?? {}, // Use provided query parameters or empty map
        data: data,
      );

      return response;
    } catch (e) {
      // Handle the error if the request fails
      print(e);
      throw Exception('Error in making POST request: $e');
    }
  }

  static Future<Response> postData({
    required String url,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    required data,
  }) async {
    bool isFormData = false;

    // Check if the data contains any files and prepare MultipartFile for file uploads
    for (var entry in data.entries) {
      if (entry.value is List<File>) {
        isFormData = true;
        data[entry.key] = entry.value.map((file) {
          return MultipartFile.fromFileSync(
            file.path,
            filename: file.path.split('/').last,
          );
        }).toList();
      } else if (entry.value is File) {
        isFormData = true;
        data[entry.key] = MultipartFile.fromFileSync(
          entry.value.path,
          filename: entry.value.path.split('/').last,
        );
      }
    }

    // If FormData is needed, convert to FormData, else use original data
    final formData = isFormData ? FormData.fromMap(data) : data;

    try {
      // Make the API request with headers and formData
      dio.options.headers = headers ?? {};
      Response response = await dio.post(
        url,
        queryParameters:
            query ?? {}, // Use provided query parameters or empty map
        data: formData,
      );

      return response;
    } catch (e) {
      // Handle the error if the request fails
      print(e);
      throw Exception('Error in making POST request: $e');
    }
  }

  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    dio.options = BaseOptions(
        headers: headers,
        responseType: ResponseType.stream,
        contentType: 'text/event-stream');

    Response response = await makeApiRequest(() => dio.get(
          url,
          queryParameters: query ?? {},
        ));
    return response;
  }

  static Future<Response> putData({
    required String url,
    Map<String, dynamic>? query,
    required Map<String, dynamic> data,
    Map<String, dynamic>? headers,
  }) async {
    dio.options.headers = headers;
    Response response = await makeApiRequest(() => dio.put(
          url,
          queryParameters: query,
          data: data,
        ));
    log('eslam res:${response.data}');
    return response;
  }

  static Future<Response> deleteData({
    required String url,
    Map<String, dynamic>? query,
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
  }) async {
    dio.options.headers = headers;
    Response response = await dio.delete(
      url,
      queryParameters: query,
      data: data,
    );
    return response;
  }

  static Future<Response> makeApiRequest(
      Future<Response> Function() apiCall) async {
    try {
      return await apiCall();
    } catch (error) {
      if (error is DioException) {
        // Handle DioExceptions here
        List<String> errorMessages = [];

        if (error.response?.data['data'] != null &&
            error.response!.data['data'] is Map) {
          error.response!.data['data'].forEach((key, value) {
            if (value is List) {
              errorMessages.addAll(value.map((e) => " $e").toList());
            }
          });
        } else {
          errorMessages
              .add("An error occurred: ${error.response?.statusMessage}");
        }

//        showToastMsg(errorMessages);
      } else {
        // Handle other exceptions here
        //  showToastMsg("An unexpected error occurred: $error");
      }
      rethrow;
    }
  }

  static Future<Response> patchData({
    required String url,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    required data,
  }) async {
    bool isFormData = false;

    for (var entry in data.entries) {
      if (entry.value is List<File>) {
        isFormData = true;
        data[entry.key] = entry.value.map((file) {
          return MultipartFile.fromFileSync(
            file.path,
            filename: file.path.split('/').last,
            contentType: DioMediaType.parse("image/png"),
          );
        }).toList();
      } else if (entry.value is File) {
        isFormData = true;
        data[entry.key] = MultipartFile.fromFileSync(
          entry.value.path,
          filename: entry.value.path.split('/').last,
          contentType: DioMediaType.parse("image/png"),
        );
      }
    }

    final formData = isFormData ? FormData.fromMap(data) : data;

    try {
      dio.options.headers = headers ?? {};
      Response response = await dio.patch(
        url,
        queryParameters:
            query ?? {}, // Use provided query parameters or empty map
        data: formData,
      );

      return response;
    } catch (e) {
      // Handle the error if the request fails
      print(e);
      throw Exception('Error in making POST request: $e');
    }
  }
}
