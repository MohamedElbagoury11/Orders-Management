import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projectmange/core/utils/whatsapp.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme_helper.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(AppStrings.plansPricing),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color.fromARGB(224, 16, 16, 164),
      ),
      body: Container(
        decoration: AppThemeHelper.getBackgroundGradientDecoration(context),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTrialHeader(context),
                const SizedBox(height: 32),
                _buildSectionTitle(context, AppStrings.WhyPremium),
                const SizedBox(height: 16),
                _buildFeaturesGrid(context),
                const SizedBox(height: 32),
                _buildSectionTitle(context, AppStrings.selectPlan),
                const SizedBox(height: 16),
                _buildPlanCard(
                  context,
                  title: AppStrings.monthlyPlan,
                  price: '100 EGP',
                  period: '/ ${AppStrings.period}',
                  features: [
                    AppStrings.unlimitedOrders,
                    AppStrings.fullAnalytics,
                    AppStrings.support247,
                  ],
                  gradient: const LinearGradient(
                    colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap:
                      () => _showPaymentDialog(
                        context,
                        '${AppStrings.monthlyPlan} (100 EGP)',
                      ),
                  offer: AppStrings.off50,
                ),
                const SizedBox(height: 16),
                _buildPlanCard(
                  context,
                  title: AppStrings.yearlyPlan,
                  price: '1000 EGP',
                  period: '/ 12 ${AppStrings.period}',
                  features: [
                    AppStrings.unlimitedOrders,
                    AppStrings.fullAnalytics,
                    AppStrings.support247,
                    AppStrings.save200EGPComparedToMonthly,
                  ],
                  gradient: const LinearGradient(
                    colors: [Color(0xFFBA68C8), Color(0xFF7B1FA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  isBestValue: true,
                  onTap:
                      () => _showPaymentDialog(
                        context,
                        '${AppStrings.yearlyPlan} (1000 EGP)',
                      ),
                  offer: AppStrings.off50,
                ),
                const SizedBox(height: 40),
                _buildPaymentInstructions(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildFeaturesGrid(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppThemeHelper.getCardDecoration(context),
      child: Column(
        children: [
          _buildFeatureRow(
            context,
            Icons.cloud_done_rounded,
            AppStrings.cloudSync,
            AppStrings.cloudSyncDescription,
          ),
          const Divider(height: 24),
          _buildFeatureRow(
            context,
            Icons.analytics_outlined,
            AppStrings.businessInsights,
            AppStrings.businessInsightsDescription,
          ),
          const Divider(height: 24),
          _buildFeatureRow(
            context,
            Icons.rocket_launch_rounded,
            AppStrings.prioritySupport,
            AppStrings.prioritySupportDescription,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrialHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, size: 48, color: Colors.white),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.freeTrialActive,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.exploreFeaturesFree,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required Gradient gradient,
    required VoidCallback onTap,
    bool isBestValue = false,
    String? offer,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (gradient as LinearGradient).colors.last.withOpacity(
                  0.3,
                ),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    period,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white24),
              const SizedBox(height: 20),
              ...features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        f,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: gradient.colors.last,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    AppStrings.choosePlan,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (offer != null)
          Positioned(
            top: -12,
            left: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5252),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                offer,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        if (isBestValue)
          Positioned(
            top: -12,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'BEST VALUE',
                style: TextStyle(
                  color: Color(0xFF5D4037),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentInstructions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, AppStrings.paymentMethods),
        const SizedBox(height: 16),
        _buildPaymentMethodTile(
          context,
          icon: Icons.phone_android_rounded,
          title: AppStrings.vodafoneCash,
          subtitle: '01091712619',
          color: const Color(0xFFE60000), // Vodafone Red
        ),
        const SizedBox(height: 16),
        _buildPaymentMethodTile(
          context,
          icon: Icons.account_balance_rounded,
          title: AppStrings.instapay,
          subtitle: '01020074013',
          color: const Color(0xFF00796B), // Instapay Teal
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppThemeHelper.getCardDecoration(
        context,
      ).copyWith(border: Border.all(color: color.withOpacity(0.1))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                Clipboard.setData(ClipboardData(text: subtitle));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppStrings.copiedToClipboard),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Icon(
                  Icons.copy_rounded,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, String plan) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              '${AppStrings.payForPlan} $plan',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.followSteps,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                _buildInstructionRow(context, '1', AppStrings.transferAmount),
                const SizedBox(height: 12),
                _buildInstructionRow(context, '2', AppStrings.takeScreenshot),
                const SizedBox(height: 12),
                _buildInstructionRow(
                  context,
                  '3',
                  AppStrings.sendWhatsAppActivation,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppStrings.cancel,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  WhatsApp().launchWhatsApp(
                    '201020074013',
                    'I have just paid for $plan. Here is my proof of payment:',
                  );
                },
                icon: const Icon(Icons.send),
                label: Text(AppStrings.sendToWhatsApp),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildInstructionRow(BuildContext context, String step, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.1),
          child: Text(
            step,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ],
    );
  }
}
