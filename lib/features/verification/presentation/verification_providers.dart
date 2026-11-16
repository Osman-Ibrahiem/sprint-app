import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/features/identity/domain/user.dart';
import 'package:sprint/features/identity/domain/verification.dart';
import 'package:sprint/features/verification/domain/sheet_batch.dart';

/// The signed-in reviewer's id, or null for a guest.
final reviewerIdProvider = Provider.autoDispose<String?>(
  (ref) => ref.watch(currentSessionProvider.select((s) => s.user?.id)),
);

/// Re-runs the provider after every successful verification write.
void _refreshOnChanges(Ref ref) {
  final sub = ref
      .watch(verificationRepositoryProvider)
      .changes
      .listen((_) => ref.invalidateSelf());
  ref.onDispose(sub.cancel);
}

/// Pending requests in the reviewer's scope, oldest first (FR-031, FR-032).
final verificationQueueProvider =
    FutureProvider.autoDispose<Result<List<Verification>>>((ref) async {
      _refreshOnChanges(ref);
      final id = ref.watch(reviewerIdProvider);
      if (id == null) return const Err(NoAccess());
      return ref.watch(verificationRepositoryProvider).queue(id);
    });

/// One request with its full national ID, when it is in the reviewer's scope.
final verificationRequestProvider = FutureProvider.autoDispose
    .family<Result<Verification>, String>((ref, verificationId) async {
      _refreshOnChanges(ref);
      final id = ref.watch(reviewerIdProvider);
      if (id == null) return const Err(NoAccess());
      return ref
          .watch(verificationRepositoryProvider)
          .request(id, verificationId);
    });

/// The ID card photo of one request (FR-033).
final verificationPhotoProvider = FutureProvider.autoDispose
    .family<Result<Uint8List>, String>((ref, photoId) async {
      final id = ref.watch(reviewerIdProvider);
      if (id == null) return const Err(NoAccess());
      return ref.watch(verificationRepositoryProvider).photo(id, photoId);
    });

/// Earlier sheet uploads in the reviewer's scope, newest first.
final sheetBatchesProvider =
    FutureProvider.autoDispose<Result<List<SheetBatch>>>((ref) async {
      _refreshOnChanges(ref);
      final id = ref.watch(reviewerIdProvider);
      if (id == null) return const Err(NoAccess());
      return ref.watch(verificationRepositoryProvider).batches(id);
    });

/// The person behind a request (name only; never shown with a full ID).
final verificationPersonProvider = FutureProvider.autoDispose
    .family<User?, String>(
      (ref, userId) => ref.watch(identityRepositoryProvider).getUser(userId),
    );
