import 'package:sprint/features/assets/domain/asset.dart';
import 'package:sprint/features/assets/domain/asset_repository.dart';
import 'package:sprint/features/assets/domain/damage_report.dart';

class InMemoryAssetRepository implements AssetRepository {
  InMemoryAssetRepository({
    Iterable<Asset> assets = const [],
    Iterable<DamageReport> reports = const [],
  })  : _assets = {for (final a in assets) a.id: a},
        _reports = {for (final r in reports) r.id: r};

  final Map<String, Asset> _assets;
  final Map<String, DamageReport> _reports;

  @override
  Future<List<Asset>> assets(String facilityId) async =>
      _assets.values.where((a) => a.facilityId == facilityId).toList();

  @override
  Future<List<DamageReport>> damageReports({String? assetId}) async =>
      _reports.values.where((r) => assetId == null || r.assetId == assetId).toList();

  @override
  Future<void> saveAsset(Asset asset) async => _assets[asset.id] = asset;

  @override
  Future<void> saveDamageReport(DamageReport report) async =>
      _reports[report.id] = report;
}
