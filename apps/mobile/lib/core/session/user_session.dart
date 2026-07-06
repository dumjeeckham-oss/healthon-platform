class UserSession {
  static String? userId;

  static void setUser(String id) {
    userId = id;
  }

  static void clear() {
    userId = null;
  }

  static bool get isLoggedIn => userId != null;
}
