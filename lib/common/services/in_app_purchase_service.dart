import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';

class IapHelper {
  static final _iap = InAppPurchase.instance;
  static const _productId = 'com.sunnyinnolab.worldMovieTrailer.ads_free';

  static Future<void> buyProduct(BuildContext context) async {
    final response = await _iap.queryProductDetails({_productId});
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint("Product not found: $_productId");
      return;
    }

    final product = response.productDetails.first;
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  static Future<void> restorePurchase(BuildContext context) async {
    await _iap.restorePurchases();
  }

  static void listenToPurchases(BuildContext context) {
    _iap.purchaseStream.listen((purchases) {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

      for (var purchase in purchases) {
        if (purchase.productID == _productId &&
            (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored)) {
          settingsProvider.updateIsAdsFree(true);
          break;
        }
      }
    });
  }
}
