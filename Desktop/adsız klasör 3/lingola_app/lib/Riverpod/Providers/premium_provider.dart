import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// GELİŞTİRME MODU İÇİN KISA YOL:
/// true yaparsan uygulama her zaman premium gibi davranır (RevenueCat'e bakmadan).
/// PROD'A ÇIKARKEN MUTLAKA false YAP.
const bool kForcePremiumForDev = true;

/// RevenueCat dashboard'da tanımlı entitlement identifier (örn. "premium").
const String kPremiumEntitlementId = 'premium';

/// Kullanıcının premium (abonelik) durumunu RevenueCat'ten okur.
/// Satın alma veya restore sonrası [ref.refresh(premiumProvider)] ile güncellenir.
final premiumProvider = FutureProvider<bool>((ref) async {
  if (kForcePremiumForDev) return true;
  try {
    final info = await Purchases.getCustomerInfo();
    if (info.entitlements.active.containsKey(kPremiumEntitlementId)) return true;
    return info.entitlements.active.isNotEmpty;
  } catch (_) {
    return false;
  }
});
