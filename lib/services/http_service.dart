
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import '../app/app_config.dart';
import '../core/cache_helper.dart';
import '../data/constants/api_constants.dart';
import '../data/models/user_model.dart';

class HttpService {
  String? host;

  BaseOptions? baseOptions;
  Dio? dio;
  CookieJar cookieJar = CookieJar();
  int connectTimeout = 60000;
  int receiveTimeout = 60000;

  Future<Map<String, String>> getHeaders() async {
    String? token = await getAuthBearerToken();
    return {
      HttpHeaders.acceptHeader: "application/json",
      if(token != null) HttpHeaders.authorizationHeader: "Token $token",
    };
  }

  HttpService() {
    initHttpService();
  }

  //get the remote config
  Future<void> initHttpService() async {
    host = AppConfig.shared.baseUrl;
    //initialize dio
    baseOptions = BaseOptions(
        baseUrl: host!,
        connectTimeout: const Duration(seconds: 120),
        receiveTimeout: const Duration(seconds: 120),
        validateStatus: (status) {
          return status! <= 500;
        });
    dio = Dio(baseOptions);
    dio!.interceptors.add(CookieManager(cookieJar));
  }

  //get user token from login details


  //TODO: this is to get the bearer token for the app to maintain session
  Future<String?> getAuthBearerToken() async {
    var authDetails = await CacheHelper.instance.readModel(CacheHelper.authKey);
    return authDetails == null ? "" : AuthModel.fromJson(authDetails).token;
  }

  //get method
  Future<Response> get(String url,
      {Map<String, dynamic>? queryParameters,
        CancelToken? token,
        bool useCSRFToken = false}) async {
    String uri = "$host$url";
    debugPrint("GET URL: $uri");
    String? token = await getAuthBearerToken();
    return dio!.get(
      uri,
      options: Options(
        headers: useCSRFToken
            ? {
          HttpHeaders.acceptHeader: "application/json",
          if(token != null) "X-CSRFToken": token,
        }
            : await getHeaders(),
      ),
      queryParameters: queryParameters,
    );
  }


  //get callback url
  Future<Response> getCallback(String url,
      {Map<String, dynamic>? queryParameters,
        CancelToken? token,
        bool useCSRFToken = false}) async {
    String uri = url;
    debugPrint("GET CALLBACK URL: $uri");
    String? token = await getAuthBearerToken();
    return dio!.get(
      uri,
      options: Options(
        headers: useCSRFToken
            ? {
          HttpHeaders.acceptHeader: "application/json",
          if(token != null) "X-CSRFToken": token,
        }
            : await getHeaders(),
      ),
      queryParameters: queryParameters,
    );
  }

  Future<Response> getWithoutHost(String url,
      {Map<String, dynamic>? queryParameters, CancelToken? token}) async {
    String uri = url;
    debugPrint("GET URL: $uri");
    return dio!.get(
      uri,
      options: Options(
        headers: await getHeaders(),
      ),
      queryParameters: queryParameters,
    );
  }

  //get no user
  Future<Response> getNoAuth(String url,
      {Map<String, dynamic>? queryParameters, CancelToken? token}) async {
    String uri = "$host$url";
    debugPrint("GET URL: $uri");
    return dio!.get(
      uri,
      options: Options(headers: {
        HttpHeaders.acceptHeader: "application/json",
      }),
      queryParameters: queryParameters,
    );
  }

  //post method
  Future<Response> post(String url, {dynamic body, CancelToken? token}) async {
    String uri = "$host$url";
    debugPrint("POST URL: $uri");
    return dio!.post(
      uri,
      data: body,
      cancelToken: token,
      options: Options(
        headers: await getHeaders(),
      ),
    );
  }

  //unique login post
  Future<Response> loginPost(String url,
      {dynamic body, CancelToken? token}) async {
    String uri = "$host$url";
    debugPrint("LOGIN POST URL: $uri");
    return dio!.post(
      uri,
      data: body,
      cancelToken: token,
      options: Options(headers: {
        HttpHeaders.acceptHeader: "application/json",
      }),
    );
  }

  //patch from database
  Future<Response> patch(String url, body, {CancelToken? token}) async {
    String uri = "$host$url";
    debugPrint("PATCH URL: $uri");
    return dio!.patch(
      uri,
      data: body,
      options: Options(
        headers: await getHeaders(),
      ),
    );
  }

  // put into database
  Future<Response> put(String url,
      {Map<String, dynamic>? queryParameters,
        dynamic body,
        CancelToken? token}) async {
    String uri = "$host$url";
    debugPrint("PUT URL: $uri");
    return dio!.put(uri,
        data: body,
        options: Options(
          headers: await getHeaders(),
        ),
        queryParameters: queryParameters);
  }

  //detele from database
  Future<Response> delete(String url,
      {dynamic body, CancelToken? token}) async {
    String uri = "$host$url";
    return dio!.delete(
      uri,
      data: body,
      options: Options(
        headers: await getHeaders(),
      ),
    );
  }

  //getCsrftoken
  Future<String?> getCsrfToken(String host) async {
    try {
      // Make a GET request to an endpoint that sets the CSRF cookie
      Response response = await dio!.get(
        '$host${Api.register}', // Replace with an endpoint like '/get-csrf-token/' or any accessible endpoint
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status! < 500,
        ),
      );

      // Extract cookies from response
      List<Cookie> cookies = await cookieJar.loadForRequest(Uri.parse('$host${Api.register}'));
      String? csrfToken;

      // Find the csrftoken cookie
      for (var cookie in cookies) {
        if (cookie.name == 'csrftoken') {
          csrfToken = cookie.value;
          break;
        }
      }

      return csrfToken;
    } catch (e) {
      return null;
    }
  }
}