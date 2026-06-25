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
  static const String getExplorePrograms = _Program.getExplorePrograms;
  static const String getMyPrograms = _Program.getMyPrograms;
  static const String getAllPrograms = _Program.getAllPrograms;
  static String getProgramDetail(String id) => _Program.getProgramDetails(id);
  static String startProgram(String id) => _Program.startProgram(id);
  static const String completeWorkoutSession = _Program.completeWorkoutSession;

  static const String getAllLibrary = _Excerise.getAllLibrary;
  static String getLibraryDetail(String id) => _Excerise.getLibraryDetails(id);

  static const String getAllRecipies = _Recipies.getAllRecipies;
  static String getRecipeDetail(String id) => _Recipies.getRecipeDetails(id);
  static String toggleRecipeFavorite(String id) => _Recipies.toggleFavorite(id);

  static String getExcerisesData(String id) =>
      _ExceriseData.getExcerisesData(id);
  static String putExcerisesData(String id) =>
      _ExceriseData.putExcerisesData(id);

  //------------notification----------------
  /// ### get
  static const String getAllNotifications = _Notification.getAllNotifications;
  static String markNotificationAsRead({required String notificationId}) =>
      _Notification.markNotificationAsRead(notificationId);
  static const String markAllAsRead = _Notification.markAllAsRead;

  // ---------------------- USER -----------------------------
  /// ### get
  static String getProfile = _User.getProfile;
  static String updateProfile = _User.updateProfile;
  static String updateProfileImage = _User.updateProfileImage;
  static String changePassword = _User.changePassword;
  static String helpAndSupport = _User.helpAndSupport;

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

  //------------------------- Progress --------------------------
  /// ### get
  static const String getProgress = _Progress.progress;

  //-------------------------Messaging --------------------------
  static const String createChat = _Messaging.createChat;
  static const String sendMessage = _Messaging.sendMessage;
  static const String getAllChats = _Messaging.getAllChats;
  static String getChat(String id) => _Messaging.getChat(id);

  // Chat threads (admin chat)
  static const String chatThreads = _Messaging.chatThreads;
  static String chatThreadMessages(String threadId) =>
      _Messaging.chatThreadMessages(threadId);
  static String chatThreadSendMessage(String threadId) =>
      _Messaging.chatThreadSendMessage(threadId);
  static String chatThreadMarkRead(String threadId) =>
      _Messaging.chatThreadMarkRead(threadId);
  static const String uploadImage = _Uploads.image;
  static const String uploadVideo = _Uploads.video;

  //------------------------- Daily Tracker --------------------------
  /// ### get, patch
  static const String dailyTracker = _DailyTracker.dailyTracker;

  /// ### post
  static const String dailyTrackerNotes = _DailyTracker.dailyTrackerNotes;

  //------------------------- Nutrition --------------------------
  /// ### get
  static const String nutritionDiary = _Nutrition.diary;
  static const String nutritionHistory = _Nutrition.history;
  static const String nutritionFavorites = _Nutrition.favorites;
  static const String nutritionFavoriteSections = _Nutrition.favoriteSections;
  static const String nutritionFavoriteMeals = _Nutrition.favoriteMeals;
  static const String nutritionFoodSuggestions = _Nutrition.foodSuggestions;
  static const String nutritionFoodSearch = _Nutrition.foodSearch;
  static String nutritionFoodDetails(dynamic fdcId) =>
      _Nutrition.foodDetails(fdcId);
  static String nutritionDiaryEntryById(dynamic entryId) =>
      _Nutrition.diaryEntryById(entryId);
  static String nutritionFavoriteMealById(dynamic mealFavoriteId) =>
      _Nutrition.favoriteMealById(mealFavoriteId);

  /// ### post
  static const String nutritionDiaryEntries = _Nutrition.diaryEntries;

  // ---------------------- Payments -----------------------------
  /// ### get
  static const String paymentPlans = _Payments.plans;
  static const String paymentCheckout = _Payments.checkout;
  static const String paymentConfirmCheckout = _Payments.confirmCheckout;
}

//arrow360degree@gmail.com

class _RemoteServer {
  // static const String socketUrl = 'http://72.60.29.234:5001';

  // static const String baseUrl = 'http://72.60.29.234:5001/api/v1';
  // 'https://disabilitymne-backend.onrender.com/api/v1';
  static const String socketUrl = 'http://187.124.21.65';
  static const String baseUrl = 'http://187.124.21.65/api/v1';
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
  static const String getExplorePrograms = '$_programRoute/explore';
  static const String getMyPrograms = '$_programRoute/my';
  static const String getAllPrograms = '$_programRoute/all';
  static String getProgramDetails(String id) => '$_programRoute/$id';
  static String startProgram(String id) => '$_programRoute/$id/start';
  static const String completeWorkoutSession =
      '${ApiEndpoints.baseUrl}/users/me/workouts/sessions/complete';
}

class _Excerise {
  static const String _excercisesRoute = '${ApiEndpoints.baseUrl}/exercises';
  static const String getAllLibrary = '$_excercisesRoute/all';
  static String getLibraryDetails(String id) => '$_excercisesRoute/$id';
}

class _Recipies {
  static const String _recipesRoute = '${ApiEndpoints.baseUrl}/recipes';
  static const String getAllRecipies = '$_recipesRoute/all';
  static String getRecipeDetails(String id) => '$_recipesRoute/$id';
  static String toggleFavorite(String id) => '$_recipesRoute/$id/favorite';
}

class _ExceriseData {
  static const String _excersisesDataRoute =
      '${ApiEndpoints.baseUrl}/users/me/exercises';
  static String getExcerisesData(String id) =>
      '$_excersisesDataRoute/$id/settings';
  static String putExcerisesData(String id) =>
      '$_excersisesDataRoute/$id/settings';
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
  static const String _notificationRoute = '${ApiEndpoints.baseUrl}/users';
  static String markNotificationAsRead(String notificationId) =>
      '$_notificationRoute/me/notifications/$notificationId/read';
  static const String markAllAsRead =
      '$_notificationRoute/me/notifications/read-all';
  static const String getAllNotifications =
      '$_notificationRoute/me/notifications';
}

// ---------------------- USER -----------------------------
class _User {
  static const String _userRoute = '${ApiEndpoints.baseUrl}/users';
  static String getProfile = '$_userRoute/me';
  static String updateProfile = '$_userRoute/me';
  static String updateProfileImage = '$_userRoute/me/profile-image';
  static String changePassword = '$_userRoute/me/change-password';
  static String helpAndSupport = '$_userRoute/me/support/tickets';
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

//---------------------- Progress -----------------------------
class _Progress {
  static const String _progressRoute =
      '${ApiEndpoints.baseUrl}/users/me/progress';
  static const String progress = _progressRoute;
}

//---------------------- Daily Tracker -----------------------------
class _DailyTracker {
  static const String _route = '${ApiEndpoints.baseUrl}/users/me/daily-tracker';
  static const String dailyTracker = _route;
  static const String dailyTrackerNotes = '$_route/notes';
}

//---------------------- Nutrition -----------------------------
class _Nutrition {
  static const String _route = '${ApiEndpoints.baseUrl}/nutrition';
  static const String diary = '$_route/diary';
  static const String history = '$_route/history';
  static const String favorites = '$_route/favorites';
  static const String favoriteSections = '$_route/favorites/sections';
  static const String favoriteMeals = '$_route/favorites/meals';
  static const String foodSuggestions = '$_route/foods/suggestions';
  static const String foodSearch = '$_route/foods/search';
  static String foodDetails(dynamic fdcId) => '$_route/foods/$fdcId';
  static const String diaryEntries = '$_route/diary/entries';
  static String diaryEntryById(dynamic entryId) => '$diaryEntries/$entryId';
  static String favoriteMealById(dynamic mealFavoriteId) =>
      '$favoriteMeals/$mealFavoriteId';
}

//---------------------- Payments -----------------------------
class _Payments {
  static const String _route = '${ApiEndpoints.baseUrl}/payments';
  static const String plans = '$_route/plans';
  static const String checkout = '$_route/checkout';
  static const String confirmCheckout = '$_route/checkout/confirm';
}

class _Uploads {
  static const String _route = '${ApiEndpoints.baseUrl}/uploads';
  static const String image = '$_route/image';
  static const String video = '$_route/video';
}

//----------------------Message -----------------------------
class _Messaging {
  static const String _messagingRoute = '${ApiEndpoints.baseUrl}/chat';
  static String getChat(String id) => '$_messagingRoute/$id';
  static const String sendMessage = '$_messagingRoute/message';
  static const String createChat = '$_messagingRoute/';
  static const String getAllChats = '$_messagingRoute/';

  // Chat threads (admin chat) – dynamic API + socket
  static const String chatThreads = '$_messagingRoute/threads';
  static String chatThreadMessages(String threadId) =>
      '$_messagingRoute/threads/$threadId/messages';
  static String chatThreadSendMessage(String threadId) =>
      '$_messagingRoute/threads/$threadId/messages';
  static String chatThreadMarkRead(String threadId) =>
      '$_messagingRoute/threads/$threadId/read';
}
