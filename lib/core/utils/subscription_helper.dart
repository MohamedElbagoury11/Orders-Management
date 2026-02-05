import '../../domain/entities/user.dart';

class SubscriptionHelper {
  static const int freeOrderLimit = 5;
  static const int warningThreshold = 4; // Warn when user has 4 orders (1 left)

  /// Check if user is on a paid plan (Monthly or Yearly)
  static bool isPaidPlan(User user) {
    return user.isPro ||
        user.subscriptionType == 'monthly' ||
        user.subscriptionType == 'yearly';
  }

  /// Check if user has reached the free plan order limit
  static bool hasReachedFreeLimit(User user) {
    if (isPaidPlan(user)) return false;
    return user.orderCount >= freeOrderLimit;
  }

  /// Get remaining orders for free plan users
  static int getRemainingOrders(User user) {
    if (isPaidPlan(user)) return -1; // Unlimited for paid plans
    final remaining = freeOrderLimit - user.orderCount;
    return remaining > 0 ? remaining : 0;
  }

  /// Check if user should see a warning (1 order left)
  static bool shouldShowWarning(User user) {
    if (isPaidPlan(user)) return false;
    return user.orderCount >= warningThreshold &&
        user.orderCount < freeOrderLimit;
  }

  /// Get subscription status string
  static String getSubscriptionStatus(User user) {
    if (user.isPro) return 'Pro Plan';
    if (user.subscriptionType == 'monthly') return 'Monthly Plan';
    if (user.subscriptionType == 'yearly') return 'Yearly Plan';

    // Free plan
    final remaining = getRemainingOrders(user);
    if (remaining == 0) return 'Free Plan - Limit Reached';
    return 'Free Plan: $remaining/${freeOrderLimit} orders left';
  }

  /// Get subscription type display name
  static String getSubscriptionTypeName(User user) {
    if (user.isPro) return 'Pro';
    if (user.subscriptionType == 'monthly') return 'Monthly';
    if (user.subscriptionType == 'yearly') return 'Yearly';
    return 'Free';
  }

  /// Check if user can create more orders
  static bool canCreateOrder(User user) {
    return !hasReachedFreeLimit(user);
  }

  /// Get warning message for users approaching limit
  static String? getWarningMessage(User user) {
    if (!shouldShowWarning(user)) return null;
    final remaining = getRemainingOrders(user);
    return 'You have $remaining order${remaining == 1 ? '' : 's'} remaining on the free plan. Subscribe to continue creating orders.';
  }

  /// Get expiration alert message
  static String? getExpiryAlert(User user) {
    if (user.isPro || user.subscriptionExpiry == null) return null;

    final now = DateTime.now();
    final difference = user.subscriptionExpiry!.difference(now);

    if (user.subscriptionType == 'monthly') {
      // Alert 3 days before expiry
      if (difference.inDays >= 0 && difference.inDays <= 3) {
        return 'Your monthly subscription will expire in ${difference.inDays} days. Please renew to continue.';
      }
    } else if (user.subscriptionType == 'yearly') {
      // Alert 1 month (30 days) before expiry
      if (difference.inDays >= 0 && difference.inDays <= 30) {
        if (difference.inDays <= 7) {
          return 'Your yearly subscription will expire in ${difference.inDays} days. Please renew to continue.';
        }
        return 'Your yearly subscription will expire in 1 month. Please renew to continue.';
      }
    }
    return null;
  }
}
