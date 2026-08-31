import 'package:cihcahul_plus/core/models/variable.dart';
import 'package:cihcahul_plus/core/services/localization_service.dart';
import 'package:cihcahul_plus/core/services/reactive_store.dart';
import 'package:cihcahul_plus/core/themes/app_themes.dart';
import 'package:flutter/material.dart';

Widget vacationNotice(BuildContext context) {
  Variable? navSelected = ReactiveStore.get("nav_selected");

  return Padding(
    padding: EdgeInsets.only(top: (navSelected?.get() == 0) ? 235 : 0),
    child: Center(
      child: Text(
        L10n.tr("vacation_notice"),
        style: context.theme.textTheme.bodyLarge!.copyWith(
          color: context.theme.textSecondary,
        ),
      ),
    ),
  );
}
