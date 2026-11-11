import 'package:sprint/features/assets/domain/asset.dart';
import 'package:sprint/features/assets/domain/damage_report.dart';

abstract interface class AssetRepository {
  Future<List<Asset>> assets(String facilityId);
  Future<List<DamageReport>> damageReports({String? assetId});
  Future<void> saveAsset(Asset asset);
  Future<void> saveDamageReport(DamageReport report);
}
