import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:world_movie_trailer/common/log_helper.dart';
import 'package:world_movie_trailer/common/providers/settings_provider.dart';
import 'package:world_movie_trailer/common/translate.dart';

class IapHelper {
  static final _iap = InAppPurchase.instance;
  static bool _isPending = false;

  static String get _productId =>
      Platform.isIOS
          ? 'com.sunnyinnolab.worldMovieTrailer.ads_free'
          : 'com.sunnyinnolab.worldmovietrailer.ads_free';

  // 추가된 가격 변수
  static String _price = '';
  static String _currency = '';

  static String get price => _price; 
  static String get currency => _currency;

  // 가격을 업데이트하는 메서드
  static Future<void> fetchProductPrice(BuildContext context) async {
    final response = await _iap.queryProductDetails({_productId});

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint("Product not found: $_productId");
      return;
    }

    final product = response.productDetails.first;
    _price = product.price;
    _currency = product.currencyCode;

    // UI 업데이트를 위해 상태 변경
    Provider.of<SettingsProvider>(context, listen: false).notifyListeners();
  }

  static Future<void> buyProduct(BuildContext context) async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    if (_isPending) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(getDonationLabel(settingsProvider.language, "pending")))
      );
      return;
    }

    final response = await _iap.queryProductDetails({_productId});
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint("Product not found: $_productId");
      return;
    }

    final product = response.productDetails.first;
    final purchaseParam = PurchaseParam(productDetails: product);

    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      LogHelper().logEvent('pay_started', parameters: {
        'product_id': _productId,
        'price': _price,
        'currency': _currency
      });
    } catch (e) {
      LogHelper().logEvent('pay_failed_immediate', parameters: {
        'product_id': _productId,
        'reason': e.toString(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(getDonationLabel(settingsProvider.language, "retry")))
      );
    }
  }

  static Future<void> restorePurchase(BuildContext context) async {
    try {
      await _iap.restorePurchases();
    } catch (e) {
      LogHelper().logEvent('restore_failed_immediate', parameters: {
        'reason': e.toString(),
      });
    }
  }

  static void listenToPurchases(BuildContext context) {
    _iap.purchaseStream.listen((purchases) async {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

      if (purchases.isEmpty) {
        debugPrint("사용자가 결제창 닫음 (status 없음)");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(getDonationLabel(settingsProvider.language, "cancelDonation")))
        );
        return;
      }

      for (var purchase in purchases) {
        if (purchase.productID != _productId) continue;

        if (purchase.pendingCompletePurchase) {
          debugPrint('🔁 기존 미완료 트랜잭션 발견 → 완료 처리 시도');
          await _iap.completePurchase(purchase);
        }

        switch (purchase.status) {
          case PurchaseStatus.pending:
            _isPending = true;
            break;

          case PurchaseStatus.purchased:
            _isPending = false;
            settingsProvider.updateIsAdsFree(true);
            LogHelper().logEvent('pay_completed', parameters: {
              'product_id': _productId,
              'price': _price,
              'currency': _currency,
            });
            break;

          case PurchaseStatus.restored:
            _isPending = false;
            settingsProvider.updateIsAdsFree(true);
            LogHelper().logEvent('restore_completed', parameters: {
              'product_id': _productId,
            });
            break;

          case PurchaseStatus.error:
            _isPending = false;
            debugPrint("결제 실패 또는 취소: ${purchase.error?.message}");
            LogHelper().logEvent('pay_failed', parameters: {
              'product_id': _productId,
              'reason': purchase.error?.message ?? 'User canceled or unknown',
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(getDonationLabel(settingsProvider.language, "retry")))
            );
            break;

          default:
            _isPending = false;
            break;
        }
      }
    });
  }
}
