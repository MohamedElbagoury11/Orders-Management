class ErrorMessages {
  static String getAuthErrorMessage(String error, {String? email, String? method}) {
    final errorLower = error.toLowerCase();
    
    // Google Sign-In Errors
    if (errorLower.contains('pigeonuserdetails')) {
      return method == 'google' 
          ? 'Google Sign-In completed but encountered a configuration issue. Please try again or use email/password login.'
          : 'Authentication completed but encountered a configuration issue. Please try again.';
    }
    if (errorLower.contains('network_error')) {
      return 'Network error. Please check your internet connection and try again.';
    }
    if (errorLower.contains('sign_in_canceled')) {
      return 'Sign-in was cancelled.';
    }
    if (errorLower.contains('sign_in_failed')) {
      return method == 'google' 
          ? 'Google Sign-In failed. Please try again or use email/password login.'
          : 'Sign-in failed. Please try again.';
    }
    if (errorLower.contains('developer_error')) {
      return method == 'google' 
          ? 'Google Sign-In developer error. Please use email/password login.'
          : 'Authentication error. Please try again.';
    }
    if (errorLower.contains('invalid_account')) {
      return 'Invalid Google account. Please try with a different account.';
    }
    
    // Email/Password Errors
    if (errorLower.contains('email-already-in-use')) {
      return email != null 
          ? 'An account with email "$email" already exists. Please sign in instead.'
          : 'An account with this email already exists. Please sign in instead.';
    }
    if (errorLower.contains('weak-password')) {
      return 'Password is too weak. Please choose a stronger password with at least 6 characters.';
    }
    if (errorLower.contains('invalid-email')) {
      return email != null 
          ? 'The email "$email" is not valid. Please enter a valid email address.'
          : 'Please enter a valid email address.';
    }
    if (errorLower.contains('user-not-found')) {
      return email != null 
          ? 'No account found with email "$email". Please sign up instead.'
          : 'No account found with this email. Please sign up instead.';
    }
    if (errorLower.contains('wrong-password')) {
      return 'Incorrect password. Please check your password and try again.';
    }
    if (errorLower.contains('too-many-requests')) {
      return 'Too many failed attempts. Please wait a few minutes and try again.';
    }
    if (errorLower.contains('operation-not-allowed')) {
      return 'This sign-in method is not enabled. Please contact support.';
    }
    if (errorLower.contains('user-disabled')) {
      return 'This account has been disabled. Please contact support.';
    }
    
    // General Errors
    if (errorLower.contains('network')) {
      return 'Network error. Please check your connection and try again.';
    }
    if (errorLower.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    if (errorLower.contains('permission')) {
      return 'Permission denied. Please try again.';
    }
    
    // Default error message
    return 'An error occurred. Please try again.';
  }
  
  static String getAuthErrorTitle(String error, {String? method}) {
    final errorLower = error.toLowerCase();
    
    if (errorLower.contains('pigeonuserdetails')) {
      return method == 'google' ? 'Google Configuration Issue' : 'Configuration Issue';
    }
    if (errorLower.contains('network')) {
      return 'Connection Error';
    }
    if (errorLower.contains('email-already-in-use')) {
      return 'Account Exists';
    }
    if (errorLower.contains('user-not-found')) {
      return 'Account Not Found';
    }
    if (errorLower.contains('wrong-password')) {
      return 'Incorrect Password';
    }
    if (errorLower.contains('weak-password')) {
      return 'Weak Password';
    }
    if (errorLower.contains('invalid-email')) {
      return 'Invalid Email';
    }
    if (errorLower.contains('sign_in_canceled')) {
      return 'Sign-In Cancelled';
    }
    if (errorLower.contains('too-many-requests')) {
      return 'Too Many Attempts';
    }
    if (errorLower.contains('user-disabled')) {
      return 'Account Disabled';
    }
    
    return 'Authentication Error';
  }
  
  static String getActionText(String error, {String? method}) {
    final errorLower = error.toLowerCase();
    
    if (errorLower.contains('email-already-in-use')) {
      return 'Sign In Instead';
    }
    if (errorLower.contains('user-not-found')) {
      return 'Sign Up';
    }
    if (errorLower.contains('pigeonuserdetails')) {
      return method == 'google' ? 'Use Email/Password' : 'Try Again';
    }
    if (errorLower.contains('network')) {
      return 'Try Again';
    }
    if (errorLower.contains('wrong-password')) {
      return 'Try Again';
    }
    if (errorLower.contains('weak-password')) {
      return 'Change Password';
    }
    if (errorLower.contains('invalid-email')) {
      return 'Fix Email';
    }
    if (errorLower.contains('too-many-requests')) {
      return 'Wait & Try';
    }
    
    return 'OK';
  }
  
  static String getRecoveryMessage(String error, {String? method}) {
    final errorLower = error.toLowerCase();
    
    if (errorLower.contains('pigeonuserdetails')) {
      return method == 'google' 
          ? 'Your Google account was successfully authenticated. You can now use the app.'
          : 'Your account was successfully created. You can now use the app.';
    }
    if (errorLower.contains('email-already-in-use')) {
      return 'You can sign in with your existing account.';
    }
    if (errorLower.contains('user-not-found')) {
      return 'You can create a new account with this email.';
    }
    
    return 'Please try again.';
  }
} 