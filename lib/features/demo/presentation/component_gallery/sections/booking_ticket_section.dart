import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/booking_ticket/booking_ticket.dart';
import 'package:sprint/core/widgets/status_badge/sprint_status.dart';
import 'package:sprint/features/booking/domain/booking_repository.dart';
import 'package:sprint/features/catalogue/domain/catalogue_repository.dart';
import 'package:sprint/features/demo/presentation/component_gallery/gallery_section.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Upcoming, today, past and cancelled tickets from a seed booking and its
/// `qrTokenFor` token, plus the loading form (FR-066).
class BookingTicketSection extends ConsumerWidget {
  const BookingTicketSection({required this.l10n, super.key});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(bookingRepositoryProvider);
    final catalogue = ref.watch(catalogueRepositoryProvider);
    final format = SprintFormat(Localizations.localeOf(context).languageCode);
    return GallerySection(
      title: l10n.galleryBookingTicketSection,
      caption: l10n.gallerySampleNote,
      children: [
        FutureBuilder<List<Widget>>(
          future: _tickets(repo, catalogue, format),
          builder: (context, snapshot) => Wrap(
            spacing: SprintSpacing.space4,
            runSpacing: SprintSpacing.space4,
            children: [
              ...?snapshot.data,
              const SizedBox(
                width: SprintExtras.ticketWidth,
                child: BookingTicket.loading(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<List<Widget>> _tickets(
    BookingRepository repo,
    CatalogueRepository catalogue,
    SprintFormat format,
  ) async {
    final bookings =
        await repo.listForUser(SeedIds.bookerInternal);
    if (bookings.isEmpty) return const [];
    final b = bookings.first;
    final facility = await catalogue.getFacility(b.facilityId);
    final unit = await catalogue.getUnit(b.unitId);
    Widget ticket(BookingTicketState state, SprintStatus status) => SizedBox(
          width: SprintExtras.ticketWidth,
          child: BookingTicket(
            state: state,
            status: status,
            facilityName: facility?.name ?? '',
            unitName: unit?.name ?? '',
            start: b.start,
            end: b.end,
            qrToken: b.qrToken,
            code: b.code,
            paid: format.price(b.priceAtBooking),
            cancelUntil: state == BookingTicketState.past
                ? null
                : b.start.subtract(const Duration(hours: 24)),
          ),
        );
    return [
      ticket(BookingTicketState.upcoming, SprintStatus.confirmed),
      ticket(BookingTicketState.today, SprintStatus.confirmed),
      ticket(BookingTicketState.past, SprintStatus.attended),
      ticket(BookingTicketState.upcoming, SprintStatus.cancelled),
    ];
  }
}
