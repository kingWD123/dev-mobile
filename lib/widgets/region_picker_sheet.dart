import 'package:flutter/material.dart';
import '../data/senegal_regions.dart';
import '../theme/app_theme.dart';

/// Opens a bottom sheet listing every Senegal region so the user picks one
/// instead of typing a place name by hand. Returns null if dismissed.
Future<SenegalRegion?> pickSenegalRegion(
  BuildContext context, {
  required String title,
  SenegalRegion? current,
  SenegalRegion? disallow,
}) {
  return showModalBottomSheet<SenegalRegion>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      final muted = AppColors.muted(context);
      return DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                child: Text('Régions du Sénégal', style: TextStyle(fontSize: 12, color: muted)),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: SenegalRegions.all.length,
                  separatorBuilder: (_, _) => Divider(height: 1, indent: 56, color: Theme.of(context).dividerColor),
                  itemBuilder: (context, i) {
                    final region = SenegalRegions.all[i];
                    final selected = region == current;
                    final disabled = region == disallow;
                    return ListTile(
                      enabled: !disabled,
                      leading: Icon(
                        Icons.location_on_outlined,
                        color: disabled ? muted.withValues(alpha: 0.4) : (selected ? AppColors.primary : muted),
                      ),
                      title: Text(
                        region.name,
                        style: TextStyle(
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                          fontSize: 14.5,
                          color: disabled ? muted.withValues(alpha: 0.5) : null,
                        ),
                      ),
                      trailing: selected ? const Icon(Icons.check, color: AppColors.primary, size: 20) : null,
                      onTap: disabled ? null : () => Navigator.pop(context, region),
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
