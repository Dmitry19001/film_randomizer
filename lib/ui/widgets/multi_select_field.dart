import 'package:film_randomizer/models/base/localizable.dart';
import 'package:film_randomizer/ui/themes/custom_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class MultiSelectField<T> extends StatelessWidget {
  const MultiSelectField({
    super.key,
    required this.context,
    required this.items,
    required this.title,
    required this.buttonText,
    required this.selectedItems,
    required this.onConfirm,
    required this.onChipTap,
    required this.buttonIconData,
  });

  final BuildContext context;
  final List<Localizable> items;
  final String title;
  final String buttonText;
  final List<Localizable> selectedItems;
  final Function(Set<T> p1) onConfirm;
  final Function(Object? p1) onChipTap;
  final IconData buttonIconData;

  @override
  Widget build(BuildContext context) {
    final List<MultiSelectItem<Localizable>> multiSelectItems = items
        .map((item) => MultiSelectItem<Localizable>(item, item.localizedName(context)))
        .toList();

    return MultiSelectBottomSheetField(
      initialChildSize: 0.4,
      listType: MultiSelectListType.CHIP,
      initialValue: selectedItems,
      searchable: true,
      buttonText: Text(buttonText),
      buttonIcon: Icon(buttonIconData),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Text(title),
      ),
      selectedColor: Theme.of(context).hoverColor,
      selectedItemsTextStyle: Theme.of(context).customExtension.textStyle,
      itemsTextStyle: Theme.of(context).customExtension.textStyle,
      items: multiSelectItems,
      onConfirm: (values) {
        onConfirm(Set.from(values.cast<T>()));
      },
      chipDisplay: MultiSelectChipDisplay(
        chipColor: Theme.of(context).customExtension.chipColor,
        textStyle: Theme.of(context).customExtension.textStyle,
        onTap: (item) {
          onChipTap(item);
        },
      ),
    );
  }
}