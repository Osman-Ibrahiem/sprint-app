# Contract: Routes

Rules from the Foundation's route contract stay (routes are built from destination data; paths come
from `AppPaths`, never hand-built strings; the web uses hash URLs). This feature adds the following.

## New paths and names

| Constant | Value | Screen |
| --- | --- | --- |
| `AppPaths.facilityDetails(id)` | `/facilities/<id>` | `FacilitiesScreen(selectedId: id)`; details alone on compact, list plus details pane on medium and up |
| `AppPaths.facilitySchedule(id)` | `/facilities/<id>/schedule` | the "قريبًا" screen (US3 scenario 9); feature 5 replaces its body with the day strip |
| `AppRouteNames.facilityDetails` | `facilityDetails` | |
| `AppRouteNames.facilitySchedule` | `facilitySchedule` | |

`AppPaths.facilities` (`/facilities`) and `AppPaths.home` (`/home`) already exist and keep their values.

## Structure

- Both new routes are `subRoutes` of the facilities destination: `/facilities/:id` with the child
  `schedule`. They sit inside the shell, so the navigation bar stays and the facilities tab stays
  selected.
- `ShellDestination.subRoutes` (optional, default empty) is the only change to the destination class.
- The route order of existing destinations is not changed.

## Behaviour

| Situation | Result |
| --- | --- |
| Open `/facilities/<id>` with a published id | details for that facility (FR-014 – FR-022) |
| Open `/facilities/<id>` with a missing or unpublished id | friendly not-found screen with a way to `/facilities` (FR-026); never a blank screen |
| Reload the page on web at `/#/facilities/<id>` | the same facility reopens (FR-025) |
| Back (button, system back, back gesture) from details on compact | `pop` to the list when there is one, else `go('/facilities')`; list scroll offset and filters are kept (FR-013, FR-023) |
| Window resized medium → compact with a facility open | the same facility shows full screen; back goes to the list |
| Window resized compact → medium with a facility open | list on the start side, the same facility in the pane |
| Tap "عرض المواعيد" | pushes `/facilities/<id>/schedule`; its back returns to the facility |
| Facility card tap on home | `go('/facilities/<id>')` so the facilities tab becomes active |
| Type chip tap on home | sets the filter then `go('/facilities')` |
| "عرض الكل" for bookings on home | goes to the bookings destination (`AppPaths.bookings`), whose screen is feature 7's |

## Share link

- Path: `FacilityLink.path(id)` = `/facilities/<id>`.
- Full URL on the web: origin + base href + `#` + path, e.g. `https://<host>/sprint-app/#/facilities/<id>`.
- Opening it signed out needs no sign-in: the catalogue routes are never behind a redirect.
