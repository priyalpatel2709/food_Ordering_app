import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Appearance'),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: 'Use dark theme throughout the app',
                value: settings.themeMode == ThemeMode.dark,
                onChanged: (val) => notifier.setThemeMode(
                  val ? ThemeMode.dark : ThemeMode.light,
                ),
              ),
              const Divider(height: 1),
              _buildTextScaleSelector(settings, notifier),
            ]),

            const SizedBox(height: 32),
            _buildSectionHeader('POS UI Customization'),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.image,
                title: 'Show Item Images',
                subtitle: 'Display product images in the grid',
                value: settings.showItemImages,
                onChanged: notifier.toggleItemImages,
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.category,
                title: 'Show Category Images',
                subtitle: 'Display images or icons in categories',
                value: settings.showCategoryImages,
                onChanged: notifier.toggleCategoryImages,
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.density_medium,
                title: 'Compact Layout',
                subtitle: 'Fit more items on the screen',
                value: settings.compactLayout,
                onChanged: notifier.toggleLayoutDensity,
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.swap_horiz,
                title: 'Left-Handed Mode',
                subtitle: 'Mirror the POS sidebar layout',
                value: settings.leftHandedMode,
                onChanged: notifier.toggleOrientation,
              ),
            ]),

            const SizedBox(height: 32),
            _buildSectionHeader('Operational Choices'),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.stars,
                title: 'Show Loyalty Points',
                subtitle: 'Show point balance in the sidebar',
                value: settings.showLoyaltyPoints,
                onChanged: notifier.toggleLoyaltyDisplay,
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.check_circle_outline,
                title: 'Auto-Settle Flow',
                subtitle: 'Close dialog immediately after payment',
                value: settings.autoSettle,
                onChanged: notifier.toggleAutoSettle,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildTextScaleSelector(
    AppSettings settings,
    SettingsNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.text_fields,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Text Scaling',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<TextScale>(
            segments: const [
              ButtonSegment(value: TextScale.small, label: Text('Small')),
              ButtonSegment(value: TextScale.medium, label: Text('Medium')),
              ButtonSegment(value: TextScale.large, label: Text('Large')),
            ],
            selected: {settings.textScale},
            onSelectionChanged: (val) => notifier.setTextScale(val.first),
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.primary,
              selectedForegroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
