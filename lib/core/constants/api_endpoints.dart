import 'package:flutter/foundation.dart';

base class ApiEndpoints {
  /// Release / App Store builds use production. Debug uses localhost.
  static String get socketUrl =>
      kDebugMode ? _DevServer.socketUrl : _ProdServer.socketUrl;
  static String get baseUrl =>
      kDebugMode ? _DevServer.baseUrl : _ProdServer.baseUrl;

  /// ### post
  static String get login => _Auth.login;
  static String get logout => _Auth.logout;
  static String get socialLogin => _Auth.socialLogin;
  static String get signup => _Auth.signup;
  static String get verifyCode => _Auth.verifyCode;
  static String get forgetPassword => _Auth.forgetPassword;
  static String get createNewPassword => _Auth.resetPassword;
  static String get refreshToken => _Auth.refreshToken;
  static String get helpSupport => _HelpSupport.helpSupport;
  static String get verification => _Verification.verification;

  //---------------report----------------

  /// ### post
  static String get sendReport => _Report.sendReport;

  //-------------------------Program--------------------------
  static String get getExplorePrograms => _Program.getExplorePrograms;
  static String get getMyPrograms => _Program.getMyPrograms;
  static String get getAllPrograms => _Program.getAllPrograms;
  static String getProgramDetail(String id) => _Program.getProgramDetails(id);
  static String startProgram(String id) => _Program.startProgram(id);
  static String get completeWorkoutSession => _Program.completeWorkoutSession;

  static String get getAllLibrary => _Excerise.getAllLibrary;
  static String getLibraryDetail(String id) => _Excerise.getLibraryDetails(id);

  static String get getAllRecipies => _Recipies.getAllRecipies;
  static String get getPublicRecipies => _Recipies.getPublicRecipies;
  static String getRecipeDetail(String id) => _Recipies.getRecipeDetails(id);
  static String getPublicRecipeDetail(String id) =>
      _Recipies.getPublicRecipeDetails(id);
  static String toggleRecipeFavorite(String id) => _Recipies.toggleFavorite(id);

  static String getExcerisesData(String id) =>
      _ExceriseData.getExcerisesData(id);
  static String putExcerisesData(String id) =>
      _ExceriseData.putExcerisesData(id);

  //------------notification----------------
  /// ### get
  static String get getAllNotifications => _Notification.getAllNotifications;
  static String markNotificationAsRead({required String notificationId}) =>
      _Notification.markNotificationAsRead(notificationId);
  static String get markAllAsRead => _Notification.markAllAsRead;

  // ---------------------- USER -----------------------------
  /// ### get
  static String get getProfile => _User.getProfile;
  static String get updateProfile => _User.updateProfile;
  static String get updateProfileImage => _User.updateProfileImage;
  static String get changePassword => _User.changePassword;
  static String get deleteAccount => _User.deleteAccount;
  static String get helpAndSupport => _User.helpAndSupport;

  //-------------------------cart --------------------------
  static String get addToCart => _Cart.addToCart;
  static String get getAllCartItems => _Cart.getAllCartItems;
  static String get clearCart => _Cart.clearCart;
  static String get updateCart => _Cart.updateCart;

  //-------------------------Shop --------------------------
  static String getShop(String id) => _Shop.getShop(id);

  //------------------------- Order --------------------------
  static String get getMyOrders => _Order.getMyOrders;
  static String get createOrder => _Order.createOrder;

  //------------------------- Review --------------------------
  static String get addReview => _Review.addReview;

  //------------------------- WishList --------------------------
  static String get addWishList => _WishList.addWishList;
  static String removeWishList(String id) => _WishList.removeWishList(id);

  //------------------------- Progress --------------------------
  /// ### get
  static String get getProgress => _Progress.progress;

  //-------------------------Messaging --------------------------
  static String get createChat => _Messaging.createChat;
  static String get sendMessage => _Messaging.sendMessage;
  static String get getAllChats => _Messaging.getAllChats;
  static String getChat(String id) => _Messaging.getChat(id);

  // Chat threads (admin chat)
  static String get chatThreads => _Messaging.chatThreads;
  static String chatThreadMessages(String threadId) =>
      _Messaging.chatThreadMessages(threadId);
  static String chatThreadSendMessage(String threadId) =>
      _Messaging.chatThreadSendMessage(threadId);
  static String chatThreadMarkRead(String threadId) =>
      _Messaging.chatThreadMarkRead(threadId);
  static String get uploadImage => _Uploads.image;
  static String get uploadVideo => _Uploads.video;

  //------------------------- Daily Tracker --------------------------
  /// ### get, patch
  static String get dailyTracker => _DailyTracker.dailyTracker;

  /// ### post
  static String get dailyTrackerNotes => _DailyTracker.dailyTrackerNotes;

  //------------------------- Nutrition --------------------------
  /// ### get
  static String get nutritionDiary => _Nutrition.diary;
  static String get nutritionHistory => _Nutrition.history;
  static String get nutritionFavorites => _Nutrition.favorites;
  static String get nutritionFavoriteSections => _Nutrition.favoriteSections;
  static String get nutritionFavoriteMeals => _Nutrition.favoriteMeals;
  static String get nutritionFoodSuggestions => _Nutrition.foodSuggestions;
  static String get nutritionFoodSearch => _Nutrition.foodSearch;
  static String nutritionFoodDetails(dynamic fdcId) =>
      _Nutrition.foodDetails(fdcId);
  static String nutritionDiaryEntryById(dynamic entryId) =>
      _Nutrition.diaryEntryById(entryId);
  static String nutritionFavoriteMealById(dynamic mealFavoriteId) =>
      _Nutrition.favoriteMealById(mealFavoriteId);

  /// ### post
  static String get nutritionDiaryEntries => _Nutrition.diaryEntries;

  // ---------------------- Payments -----------------------------
  /// ### get
  static String get paymentPlans => _Payments.plans;
  static String get paymentPremiumAvailability => _Payments.premiumAvailability;
  static String get paymentCheckout => _Payments.checkout;
  static String get paymentConfirmCheckout => _Payments.confirmCheckout;
  static String get paymentAppleVerify => _Payments.appleVerify;
  static String get paymentAppleRestore => _Payments.appleRestore;

  static String get myNutritionPlans => _NutritionPlans.my;
  static String nutritionPlanDetail(String id) => _NutritionPlans.detail(id);
}

class _DevServer {
  static const String socketUrl = 'http://localhost:8000';
  static const String baseUrl = 'http://localhost:8000/api/v1';
}

class _ProdServer {
  static const String socketUrl = 'http://187.124.21.65';
  static const String baseUrl = 'http://187.124.21.65/api/v1';
}

class _Auth {
  @protected
  static String get _authRoute => '${ApiEndpoints.baseUrl}/auth';
  static String get login => '$_authRoute/login';
  static String get logout => '$_authRoute/logout';
  static String get socialLogin => '$_authRoute/social-login';
  static String get signup => '$_authRoute/register';
  static String get forgetPassword => '$_authRoute/forgot-password/send-otp';
  static String get refreshToken => '$_authRoute/refresh-token';
  static String get verifyCode => '$_authRoute/forgot-password/verify-otp';
  static String get resetPassword => '$_authRoute/forgot-password/reset';
}

//------------------------------ Help&Support -----------------------------
class _HelpSupport {
  static String get _helpSupportRoute => '${ApiEndpoints.baseUrl}/support';
  static String get helpSupport => '$_helpSupportRoute/';
}

//------------------------------ Program -----------------------------
class _Program {
  static String get _programRoute => '${ApiEndpoints.baseUrl}/programs';
  static String get getExplorePrograms => '$_programRoute/explore';
  static String get getMyPrograms => '$_programRoute/my';
  static String get getAllPrograms => '$_programRoute/all';
  static String getProgramDetails(String id) => '$_programRoute/$id';
  static String startProgram(String id) => '$_programRoute/$id/start';
  static String get completeWorkoutSession =>
      '${ApiEndpoints.baseUrl}/users/me/workouts/sessions/complete';
}

class _Excerise {
  static String get _excercisesRoute => '${ApiEndpoints.baseUrl}/exercises';
  static String get getAllLibrary => '$_excercisesRoute/all';
  static String getLibraryDetails(String id) => '$_excercisesRoute/$id';
}

class _Recipies {
  static String get _recipesRoute => '${ApiEndpoints.baseUrl}/recipes';
  static String get getAllRecipies => '$_recipesRoute/all';
  static String get getPublicRecipies => '$_recipesRoute/public/all';
  static String getRecipeDetails(String id) => '$_recipesRoute/$id';
  static String getPublicRecipeDetails(String id) =>
      '$_recipesRoute/public/$id';
  static String toggleFavorite(String id) => '$_recipesRoute/$id/favorite';
}

class _ExceriseData {
  static String get _excersisesDataRoute =>
      '${ApiEndpoints.baseUrl}/users/me/exercises';
  static String getExcerisesData(String id) =>
      '$_excersisesDataRoute/$id/settings';
  static String putExcerisesData(String id) =>
      '$_excersisesDataRoute/$id/settings';
}

// ---------------------- Verification -----------------------------
class _Verification {
  static String get _verificationRoute =>
      '${ApiEndpoints.baseUrl}/verification';
  static String get verification => '$_verificationRoute/create';
}

// ---------------------- Report -----------------------------
class _Report {
  static String get _reportRoute => '${ApiEndpoints.baseUrl}/reports';
  static String get sendReport => '$_reportRoute/';
}

// ---------------------- Notification -----------------------------
class _Notification {
  static String get _notificationRoute => '${ApiEndpoints.baseUrl}/users';
  static String markNotificationAsRead(String notificationId) =>
      '$_notificationRoute/me/notifications/$notificationId/read';
  static String get markAllAsRead =>
      '$_notificationRoute/me/notifications/read-all';
  static String get getAllNotifications =>
      '$_notificationRoute/me/notifications';
}

// ---------------------- USER -----------------------------
class _User {
  static String get _userRoute => '${ApiEndpoints.baseUrl}/users';
  static String get getProfile => '$_userRoute/me';
  static String get updateProfile => '$_userRoute/me';
  static String get updateProfileImage => '$_userRoute/me/profile-image';
  static String get changePassword => '$_userRoute/me/change-password';
  static String get deleteAccount => '$_userRoute/me';
  static String get helpAndSupport => '$_userRoute/me/support/tickets';
}

//---------------------- Cart -----------------------------
class _Cart {
  static String get _cartRoute => '${ApiEndpoints.baseUrl}/cart';
  static String get addToCart => '$_cartRoute/add';
  static String get getAllCartItems => '$_cartRoute/';
  static String get clearCart => '$_cartRoute/clear';
  static String get updateCart => '$_cartRoute/update';
}

//---------------------- Shop -----------------------------
class _Shop {
  static String get _shopRoute => '${ApiEndpoints.baseUrl}/shop';
  static String getShop(String id) => '$_shopRoute/$id';
}

//---------------------- Order -----------------------------
class _Order {
  static String get _orderRoute => '${ApiEndpoints.baseUrl}/order';
  static String get getMyOrders => '$_orderRoute/';
  static String get createOrder => '$_orderRoute/create';
}

//---------------------- Review -----------------------------
class _Review {
  static String get _reviewRoute => '${ApiEndpoints.baseUrl}/reviews';
  static String get addReview => '$_reviewRoute/';
}

//---------------------- WishList -----------------------------
class _WishList {
  static String get _wishListRoute => '${ApiEndpoints.baseUrl}/wishlist';
  static String get addWishList => '$_wishListRoute/toggle';
  static String removeWishList(String id) => '$_wishListRoute/$id';
}

//---------------------- Progress -----------------------------
class _Progress {
  static String get _progressRoute =>
      '${ApiEndpoints.baseUrl}/users/me/progress';
  static String get progress => _progressRoute;
}

//---------------------- Daily Tracker -----------------------------
class _DailyTracker {
  static String get _route =>
      '${ApiEndpoints.baseUrl}/users/me/daily-tracker';
  static String get dailyTracker => _route;
  static String get dailyTrackerNotes => '$_route/notes';
}

//---------------------- Nutrition -----------------------------
class _Nutrition {
  static String get _route => '${ApiEndpoints.baseUrl}/nutrition';
  static String get diary => '$_route/diary';
  static String get history => '$_route/history';
  static String get favorites => '$_route/favorites';
  static String get favoriteSections => '$_route/favorites/sections';
  static String get favoriteMeals => '$_route/favorites/meals';
  static String get foodSuggestions => '$_route/foods/suggestions';
  static String get foodSearch => '$_route/foods/search';
  static String foodDetails(dynamic fdcId) => '$_route/foods/$fdcId';
  static String get diaryEntries => '$_route/diary/entries';
  static String diaryEntryById(dynamic entryId) => '$diaryEntries/$entryId';
  static String favoriteMealById(dynamic mealFavoriteId) =>
      '$favoriteMeals/$mealFavoriteId';
}

//---------------------- Payments -----------------------------
class _Payments {
  static String get _route => '${ApiEndpoints.baseUrl}/payments';
  static String get plans => '$_route/plans';
  static String get premiumAvailability => '$_route/premium-availability';
  static String get checkout => '$_route/checkout';
  static String get confirmCheckout => '$_route/checkout/confirm';
  static String get appleVerify => '$_route/apple/verify';
  static String get appleRestore => '$_route/apple/restore';
}

class _NutritionPlans {
  static String get _route => '${ApiEndpoints.baseUrl}/nutrition-plans';
  static String get my => '$_route/my';
  static String detail(String id) => '$_route/$id';
}

class _Uploads {
  static String get _route => '${ApiEndpoints.baseUrl}/uploads';
  static String get image => '$_route/image';
  static String get video => '$_route/video';
}

//----------------------Message -----------------------------
class _Messaging {
  static String get _messagingRoute => '${ApiEndpoints.baseUrl}/chat';
  static String getChat(String id) => '$_messagingRoute/$id';
  static String get sendMessage => '$_messagingRoute/message';
  static String get createChat => '$_messagingRoute/';
  static String get getAllChats => '$_messagingRoute/';

  // Chat threads (admin chat) – dynamic API + socket
  static String get chatThreads => '$_messagingRoute/threads';
  static String chatThreadMessages(String threadId) =>
      '$_messagingRoute/threads/$threadId/messages';
  static String chatThreadSendMessage(String threadId) =>
      '$_messagingRoute/threads/$threadId/messages';
  static String chatThreadMarkRead(String threadId) =>
      '$_messagingRoute/threads/$threadId/read';
}
