import 'package:flutter/material.dart';
import 'package:film_randomizer/generated/localization_accessors.dart';

Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
  return (await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(L10nAccessor.get(context, "confirmation")),
      titleTextStyle: Theme.of(context).textTheme.titleLarge,
      content: Text(L10nAccessor.get(context, "delete_confirmation_title")),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              return Colors.red;
            }),
          ),
          child: Text(L10nAccessor.get(context, "delete")),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(L10nAccessor.get(context, "cancel")),
        ),
      ],
    ),
  )) ?? false;
}
