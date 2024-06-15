import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;
import 'package:intl/intl.dart';

import '../Users/users.dart';

Future<String> getAccessToken() async {
  // Your client ID and client secret obtained from Google Cloud Console
  final serviceAccountJson = {
    "type": "service_account",
    "project_id": "elderring-9e5f6",
    "private_key_id": "your_key_here",
    "private_key": "your_key_here",
    "client_email": "firebase-adminsdk-73fus@elderring-9e5f6.iam.gserviceaccount.com",
    "client_id": "your_key_here",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-73fus%40elderring-9e5f6.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  };

  List<String> scopes = [
    "https://www.googleapis.com/auth/userinfo.email",
    "https://www.googleapis.com/auth/firebase.database",
    "https://www.googleapis.com/auth/firebase.messaging"
  ];

  final auth.ServiceAccountCredentials credentials = auth.ServiceAccountCredentials.fromJson(serviceAccountJson);

  final auth.AutoRefreshingAuthClient client = await auth.clientViaServiceAccount(credentials, scopes);

  // Obtain the access token
  final String accessToken = (await client.credentials).accessToken.data;

  // Return the access token
  return accessToken;
}



Future<void> sendFCMMessage() async {
  Users.fetchAssociatedCareProvider();
  String careProviderUsername = Users.getCareProviderUsername();
  String cp_token = '';

  if (careProviderUsername == '') {
    print('Failed to get care provider username');
    return;
  }

  final DocumentSnapshot result = await FirebaseFirestore.instance
      .collection('user_token')
      .doc(careProviderUsername)
      .get();

  if (result.exists) {
    cp_token = (result.data() as Map<String, dynamic>)?['token'];
  } else {
    print('Document does not exist on the database');
  }

  final String accessToken = await getAccessToken(); // Get the access token
  final String fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/elderring-9e5f6/messages:send'; // Corrected URL
  final String? currentFCMToken = cp_token;

  if (currentFCMToken == null) {
    print('Failed to get FCM token');
    return;
  }

  print("FCM Token: $currentFCMToken");

  final Map<String, dynamic> message = {
    'message': {
      'token': currentFCMToken, // Token of the device you want to send the message to
      'notification': {
        'body': 'This is an FCM notification message!',
        'title': 'FCM Message'
      },
      'data': {
        'current_user_fcm_token': currentFCMToken, // Include the current user's FCM token in data payload
      },
    }
  };

  final http.Response response = await http.post(
    Uri.parse(fcmEndpoint),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode(message),
  );

  if (response.statusCode == 200) {
    print('FCM message sent successfully');
  } else {
    print('Failed to send FCM message: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}

Future<void> sendSOSMessage() async {
  Users.fetchAssociatedCareProvider();
  String careProviderUsername = Users.getCareProviderUsername();
  String cp_token = '';

  if (careProviderUsername == '') {
    print('Failed to get care provider username');
    return;
  }

  final DocumentSnapshot result = await FirebaseFirestore.instance
      .collection('user_token')
      .doc(careProviderUsername)
      .get();

  if (result.exists) {
    cp_token = (result.data() as Map<String, dynamic>)?['token'];
  } else {
    print('Document does not exist on the database');
  }

  final String accessToken = await getAccessToken(); // Get the access token
  final String fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/elderring-9e5f6/messages:send'; // Corrected URL
  final String? currentFCMToken = cp_token;

  if (currentFCMToken == null) {
    print('Failed to get FCM token');
    return;
  }

  print("FCM Token: $currentFCMToken");

  final String time = DateTime.now().toIso8601String(); // Add this line

  final Map<String, dynamic> message = {
    'message': {
      'token': currentFCMToken,
      'notification': {
        'body': 'SOS Button has been pressed at time: $time !!',
        'title': 'SOS Notification'
      },
      'data': {
        'type': 'SOS',
        'time': DateTime.now().toIso8601String(),
        'current_user_fcm_token': currentFCMToken,
        'payload': 'SOS||$time'
      },
    }
  };

  final http.Response response = await http.post(
    Uri.parse(fcmEndpoint),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode(message),
  );

  if (response.statusCode == 200) {
    print('FCM message sent successfully');
    Fluttertoast.showToast(
        msg: "Your care provider has been notified. Please keep patience. For general guidelines, kindly visit emergency medication.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0
    );
  } else {
    print('Failed to send FCM message: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}

Future<void> sendMedicineMissNotification(String medicine_name, String time) async {
  Users.fetchAssociatedCareProvider();
  String careProviderUsername = Users.getCareProviderUsername();
  String cp_token = '';

  if (careProviderUsername == '') {
    print('Failed to get care provider username');
    return;
  }

  final DocumentSnapshot result = await FirebaseFirestore.instance
      .collection('user_token')
      .doc(careProviderUsername)
      .get();

  if (result.exists) {
    cp_token = (result.data() as Map<String, dynamic>)?['token'];
  } else {
    print('Document does not exist on the database');
  }

  final String accessToken = await getAccessToken(); // Get the access token
  final String fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/elderring-9e5f6/messages:send'; // Corrected URL
  final String? currentFCMToken = cp_token;

  if (currentFCMToken == null) {
    print('Failed to get FCM token');
    return;
  }

  print("FCM Token: $currentFCMToken");


  final Map<String, dynamic> message = {
    'message': {
      'token': currentFCMToken,
      'notification': {
        'body': 'Your elder has missed $medicine_name on $time!!',
        'title': 'Medicine Miss Notification'
      },
      'data': {
        'type': 'MedicineMiss',
        'time': time,
        'medicine_name': medicine_name,
        'current_user_fcm_token': currentFCMToken,
        'payload': 'MedicineMiss||$medicine_name||$time'
      },
    }
  };

  final http.Response response = await http.post(
    Uri.parse(fcmEndpoint),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode(message),
  );

  if (response.statusCode == 200) {
    print('FCM message sent successfully');
    Fluttertoast.showToast(
        msg: "Sorry to hear that",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0
    );
  } else {
    print('Failed to send FCM message: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}
