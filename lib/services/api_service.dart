import 'package:way_finder/utils/toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ApiService {
  final Dio _dio = Dio();
  // Singleton instance
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  Future<Map<String, dynamic>?> get(String path,
      {Map<String, dynamic>? params, required BuildContext context}) async {
    try {
      final response = await _dio.get(
        path,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
        queryParameters: params,
      );
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null && e.response!.data != null) {
        ToastUtil.showToast(
            e.response!.data['code'], e.response!.data['message']);
      }
      throw Exception('Failed to make GET request: $e');
    }
  }

  Future<Map<String, dynamic>?> post(String path,
      {Map<String, dynamic>? data, required BuildContext context}) async {
    try {
      final response = await _dio.post(
        path,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
        data: data,
      );
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null && e.response!.data != null) {
        ToastUtil.showToast(
            e.response!.data['code'], e.response!.data['message']);
      }
      throw Exception('Failed to make POST request: $e');
    }
  }

  Future<Map<String, dynamic>?> put(String path,
      {Map<String, dynamic>? data, required BuildContext context}) async {
    try {
      final response = await _dio.put(
        path,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
        data: data,
      );
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null && e.response!.data != null) {
        ToastUtil.showToast(
            e.response!.data['code'], e.response!.data['message']);
      }
      throw Exception('Failed to make PUT request: $e');
    }
  }

  Future<Map<String, dynamic>?> delete(String path,
      {Map<String, dynamic>? data, required BuildContext context}) async {
    try {
      final response = await _dio.delete(
        path,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
        data: data,
      );
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null && e.response!.data != null) {
        ToastUtil.showToast(
            e.response!.data['code'], e.response!.data['message']);
      }
      throw Exception('Failed to make DELETE request: $e');
    }
  }
}
