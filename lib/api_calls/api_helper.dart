import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:odisha_air_map/utils/utility.dart';

import 'enum_values.dart';
import '../model/response_model.dart';



/// API WRAPPER to call all the APIs and handle the error status codes
class ApiHelper {

  final String _baseUrl = 'http://omap.okcl.org/api/patterns/detect/';

  /// Method to make all the requests inside the app like GET, POST, PUT, Delete
  Future<ResponseModel> makeRequest(
    String url,
    Request request,
    dynamic data,
   
    bool isLoading,
    Map<String, String> headers,
    { dynamic fileData}
  ) async {
    // if (await Utility.isNetworkAvailable()) {
      try {
        var uri = _baseUrl + url;
        http.Response response;

        if (isLoading) Utility.showLoader();

        switch (request) {
          case Request.get:
            response = await http
                .get(Uri.parse(uri), headers: headers)
                .timeout(const Duration(seconds: 60));
            break;
          case Request.post:
            response = await http
                .post(Uri.parse(uri), body: data, headers: headers)
                .timeout(const Duration(seconds: 60));
            break;
          case Request.put:
            response = await http
                .put(Uri.parse(uri), body: data, headers: headers)
                .timeout(const Duration(seconds: 60));
            break;
          case Request.patch:
            response = await http
                .patch(Uri.parse(uri), body: data, headers: headers)
                .timeout(const Duration(seconds: 60));
            break;
          case Request.delete:
            response = await http
                .delete(Uri.parse(uri),
                    body: jsonEncode(data), headers: headers)
                .timeout(const Duration(seconds: 60));
            break;
          case Request.exotelCall:
            response = await http
                .post(Uri.parse(url), body: data, headers: headers)
                .timeout(const Duration(seconds: 60));
            break;
             case Request.multipart:
    var requestMultipart = http.MultipartRequest('POST', Uri.parse(uri));
    
    // Set headers (remove Content-Type if it causes issues)
    requestMultipart.headers.addAll(headers);

    // Add file (assume `data['file']` is a File object and `data['fieldName']` is field name)
    // if (data['file'] != null && data['file'] is File) {
      requestMultipart.files.add(
       fileData
      );
    // }

    // Add any additional fields if needed
    // if (data['fields'] != null && data['fields'] is Map<String, String>) {
      requestMultipart.fields.addAll(data);
    // }

    var streamedResponse = await requestMultipart.send();
    var responseBody = await streamedResponse.stream.bytesToString();

    // Convert streamed response to http.Response for consistency
    response = http.Response(responseBody, streamedResponse.statusCode);
    break;
        }
        if (isLoading) Utility.closeDialog();
        log('URL: $uri\nHeaders: $headers\nData: $data\nResponse: ${response.statusCode} - ${response.body}');
        return returnResponse(response);
      } on TimeoutException catch (_) {
        if (isLoading) Utility.closeDialog();
        return ResponseModel(
          success: false,
          data: '{}', 
          hasError: true,
          message: "Request timed out",
        );
      } on SocketException catch(_){
   return ResponseModel(
    errorCode: 1000,
        success: false,
        data: '{}', 
        hasError: true,
        message:
            "No internet, please enable mobile data or Wi-Fi in your phone settings and try again",
      );
      } catch (e) {
        if (isLoading) Utility.closeDialog();
        return ResponseModel(
          success: false,
          data: '{}',
          hasError: true,
          message: "An error occurred: $e",
        );
      }
    // } else {
      // return ResponseModel(
      //   success: false,
      //   data: '{}', 
      //   hasError: true,
      //   message:
      //       "No internet, please enable mobile data or Wi-Fi in your phone settings and try again",
      // );
    // }
  }

  /// Method to return the API response based upon the status code of the server
  ResponseModel returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 202:
      case 203:
      case 205:
      case 208:
        return ResponseModel(
          success: true,
          data: response.body,
          hasError: false,
          message: "Request successful",
        );
      case 400:
      case 401:
      case 406:
      case 409:
      case 500:
      case 522:
        return ResponseModel(
          success: false,
          data: response.body,
          hasError: true,
          message: "Error: ${response.reasonPhrase}",
        );
      default:
        return ResponseModel(
          success: false,
          data: response.body,
          hasError: true,
          message: "Unexpected error occurred",
        );
    }
  }
}
