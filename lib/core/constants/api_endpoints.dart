import 'package:flutter/foundation.dart';

base class ApiEndpoints {
  static const String socketUrl = _RemoteServer.socketUrl;
  static const String baseUrl = _RemoteServer.baseUrl;

  /// ### post
  static const String login = _Auth.login;
  static const String logout = _Auth.logout;
  static const String socialLogin = _Auth.socialLogin;
  static const String signup = _Auth.signup;
  static const String verifyCode = _Auth.verifyCode;
  static const String forgetPassword = _Auth.forgetPassword;
  static const String createNewPassword = _Auth.resetPassword;
  static const String refreshToken = _Auth.refreshToken;
  static const String helpSupport = _HelpSupport.helpSupport;
  static const String verification = _Verification.verification;

  //---------------report----------------

  /// ### post
  static const String sendReport = _Report.sendReport;

  //-------------------------Program--------------------------
  static const String getAllPrograms = _Program.getAllPrograms;
  static String getProgramDetail(String id) => _Program.getProgramDetails(id);

  static const String getAllLibrary = _Excerise.getAllLibrary;
  static String getLibraryDetail(String id) => _Excerise.getLibraryDetails(id);

  //------------notification----------------
  /// ### get
  static const String getAllNotifications = _Notification.getAllNotifications;
  static const String readAllNotifications = _Notification.readAllNotifications;

  /// ### patch
  static String markNotificationAsRead({required String notificationId}) =>
      _Notification.markNotificationAsRead(notificationId);

  /// ### patch
  static const String markAllAsRead = _Notification.markAllAsRead;

  // ---------------------- USER -----------------------------
  /// ### get
  static String getProfile = _User.getProfile;
  static String updateProfile = _User.updateProfile;
  static String changePassword = _User.changePassword;

  //-------------------------cart --------------------------
  static const String addToCart = _Cart.addToCart;
  static const String getAllCartItems = _Cart.getAllCartItems;
  static const String clearCart = _Cart.clearCart;
  static const String updateCart = _Cart.updateCart;

  //-------------------------Shop --------------------------
  static String getShop(String id) => _Shop.getShop(id);

  //------------------------- Order --------------------------
  static const String getMyOrders = _Order.getMyOrders;
  static const String createOrder = _Order.createOrder;

  //------------------------- Review --------------------------
  static const String addReview = _Review.addReview;

  //------------------------- WishList --------------------------
  static const String addWishList = _WishList.addWishList;
  static String removeWishList(String id) => _WishList.removeWishList(id);

  //-------------------------Messaging --------------------------
  static const String createChat = _Messaging.createChat;
  static const String sendMessage = _Messaging.sendMessage;
  static const String getAllChats = _Messaging.getAllChats;
  static String getChat(String id) => _Messaging.getChat(id);
}

//arrow360degree@gmail.com

class _RemoteServer {
  static const String socketUrl = 'https://disabilitymne-backend.onrender.com';

  static const String baseUrl =
      'https://disabilitymne-backend.onrender.com/api/v1';
}

class _Auth {
  @protected
  static const String _authRoute = '${ApiEndpoints.baseUrl}/auth';
  static const String login = '$_authRoute/login';
  static const String logout = '$_authRoute/logout';
  static const String socialLogin = '$_authRoute/social-login';
  static const String signup = '$_authRoute/register';
  static const String forgetPassword = '$_authRoute/forgot-password/send-otp';
  static const String refreshToken = '$_authRoute/refresh-token';
  static const String verifyCode = '$_authRoute/forgot-password/verify-otp';
  static const String resetPassword = '$_authRoute/forgot-password/reset';
}

//------------------------------ Help&Support -----------------------------
class _HelpSupport {
  static const String _helpSupportRoute = '${ApiEndpoints.baseUrl}/support';
  static const String helpSupport = '$_helpSupportRoute/';
}

//------------------------------ Program -----------------------------
class _Program {
  static const String _programRoute = '${ApiEndpoints.baseUrl}/programs';
  static const String getAllPrograms = '$_programRoute/all';
  static String getProgramDetails(String id) => '$_programRoute/$id';
}

class _Excerise {
  static const String _programRoute = '${ApiEndpoints.baseUrl}/exercises';
  static const String getAllLibrary = '$_programRoute/all';
  static String getLibraryDetails(String id) => '$_programRoute/$id';
}

// ---------------------- Verification -----------------------------
class _Verification {
  static const String _verificationRoute =
      '${ApiEndpoints.baseUrl}/verification';
  static const String verification = '$_verificationRoute/create';
}

// ---------------------- Report -----------------------------
class _Report {
  static const String _reportRoute = '${ApiEndpoints.baseUrl}/reports';
  static const String sendReport = '$_reportRoute/';
}

// ---------------------- Notification -----------------------------
class _Notification {
  static const String _notificationRoute =
      '${ApiEndpoints.baseUrl}/notifications';
  static String markNotificationAsRead(String notificationId) =>
      '$_notificationRoute/$notificationId/read/';
  static const String readAllNotifications =
      '$_notificationRoute/mark-all-as-read';
  static const String markAllAsRead = '$_notificationRoute/mark-all-as-read';
  static const String getAllNotifications = '$_notificationRoute/';
}

// ---------------------- USER -----------------------------
class _User {
  static const String _userRoute = '${ApiEndpoints.baseUrl}/users';
  static String getProfile = '$_userRoute/me';
  static String updateProfile = '$_userRoute/me';
  static String changePassword = '$_userRoute/me/change-password';
}

//---------------------- Cart -----------------------------
class _Cart {
  static const String _cartRoute = '${ApiEndpoints.baseUrl}/cart';
  static const String addToCart = '$_cartRoute/add';
  static const String getAllCartItems = '$_cartRoute/';
  static const String clearCart = '$_cartRoute/clear';
  static const String updateCart = '$_cartRoute/update';
}

//---------------------- Shop -----------------------------
class _Shop {
  static const String _shopRoute = '${ApiEndpoints.baseUrl}/shop';
  static String getShop(String id) => '$_shopRoute/$id';
}

//---------------------- Order -----------------------------
class _Order {
  static const String _orderRoute = '${ApiEndpoints.baseUrl}/order';
  static const String getMyOrders = '$_orderRoute/';
  static const String createOrder = '$_orderRoute/create';
}

//---------------------- Review -----------------------------
class _Review {
  static const String _reviewRoute = '${ApiEndpoints.baseUrl}/reviews';
  static const String addReview = '$_reviewRoute/';
}

//---------------------- WishList -----------------------------
class _WishList {
  static const String _wishListRoute = '${ApiEndpoints.baseUrl}/wishlist';
  static const String addWishList = '$_wishListRoute/toggle';
  static String removeWishList(String id) => '$_wishListRoute/$id';
}

//----------------------Message -----------------------------
class _Messaging {
  static const String _messagingRoute = '${ApiEndpoints.baseUrl}/chat';
  static String getChat(String id) => '$_messagingRoute/$id';
  static const String sendMessage = '$_messagingRoute/message';
  static const String createChat = '$_messagingRoute/';
  static const String getAllChats = '$_messagingRoute/';
}
