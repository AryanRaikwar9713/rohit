import 'package:nb_utils/nb_utils.dart';

import '../app_common.dart';

extension NumExtension on num {
  String toPriceFormat() {
    final String prefix = () {
      if (isCurrencyPositionLeftWithSpace) {
        return '${appCurrency.value.currencySymbol} ';
      }
      if (isCurrencyPositionLeft) {
        return appCurrency.value.currencySymbol;
      }
      return '';
    }();

    final String suffix = () {
      if (isCurrencyPositionRightWithSpace) {
        return ' ${appCurrency.value.currencySymbol}';
      }
      if (isCurrencyPositionRight) {
        return appCurrency.value.currencySymbol;
      }
      return '';
    }();

    return "$prefix${toStringAsFixed(appCurrency.value.noOfDecimal).formatNumberWithComma()}$suffix";
  }
}
