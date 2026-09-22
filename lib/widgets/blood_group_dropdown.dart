import 'package:flutter/material.dart';
import 'package:suraksha_women_safety_app/localization/app_localizations.dart';
import 'package:suraksha_women_safety_app/widgets/blood_group_options.dart';

class BloodGroupDropdown extends StatelessWidget {
  const BloodGroupDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.showPrefixIcon = true,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final bool showPrefixIcon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = BloodGroupOptions.match(value);

    return DropdownButtonFormField<String>(
      key: ValueKey(selected ?? 'none'),
      initialValue: selected,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.t('bloodGroup'),
        hintText: l10n.t('bloodGroupSelect'),
        prefixIcon: showPrefixIcon
            ? const Icon(Icons.bloodtype_rounded)
            : null,
      ),
      items: BloodGroupOptions.all
          .map(
            (group) => DropdownMenuItem<String>(
              value: group,
              child: Text(group),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
