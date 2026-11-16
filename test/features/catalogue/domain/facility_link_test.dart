import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/catalogue/domain/facility_link.dart';

void main() {
  group('FacilityLink', () {
    test('path builds /facilities/<id>', () {
      expect(FacilityLink.path('f-pool'), '/facilities/f-pool');
    });

    test('a path round trips', () {
      expect(FacilityLink.parse(FacilityLink.path('f-pool')), 'f-pool');
    });

    test('no id is not a link', () {
      expect(FacilityLink.parse('/facilities'), isNull);
      expect(FacilityLink.parse('/facilities/'), isNull);
    });

    test('a nested path is not a facility link', () {
      expect(FacilityLink.parse('/facilities/a/b'), isNull);
      expect(FacilityLink.parse('/bookings/f-pool'), isNull);
      expect(FacilityLink.parse('/'), isNull);
    });

    test('a query, a fragment and a trailing slash are ignored', () {
      expect(FacilityLink.parse('/facilities/f-pool?x=1'), 'f-pool');
      expect(FacilityLink.parse('/facilities/f-pool#top'), 'f-pool');
      expect(FacilityLink.parse('/facilities/f-pool/'), 'f-pool');
      expect(FacilityLink.parse('/facilities/f-pool/?x=1'), 'f-pool');
    });

    test('the schedule suffix still names the facility', () {
      expect(FacilityLink.parse('/facilities/f-pool/schedule'), 'f-pool');
      expect(FacilityLink.parse('/facilities/f-pool/schedule?x=1'), 'f-pool');
    });

    test('an id with unusual characters stays exact', () {
      const id = 'f-pool_6.v2';
      expect(FacilityLink.parse(FacilityLink.path(id)), id);
    });
  });
}
