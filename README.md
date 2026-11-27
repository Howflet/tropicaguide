# TropicaGuide

**Collaborative Travel Planner built with Flutter & Firebase**

TropicaGuide turns group trip planning into one live, synchronized workspace. Instead of splitting plans across spreadsheets and group chats, travelers collaborate on dated itineraries, activity discovery, preparation checklists, and shared packing lists in real time.

## Developer
- **Author:** Howard Fletcher
- **Track:** Undergraduate Track
- **Repository:** `https://github.com/Howflet/tropicaguide`
- **Firebase Project:** `tropicaguide-mad26`

## Environment & Tooling
- **Flutter SDK:** `3.47.2` (stable)
- **Dart SDK:** `3.13.2`
- **Target Platforms:** Android, iOS, Web, macOS

## Architecture & Data Model
TropicaGuide normalizes trip data across dedicated Firestore collections linked by `tripId` so concurrent edits by group members remain isolated and conflict-safe:

| Collection | Purpose | Key Fields |
| :--- | :--- | :--- |
| `users` | Account profile & private preferences | `uid`, `email`, `displayName`, `preferences`, `savedDestinations`, `maxDailyBudget`, `travelPace` |
| `trips` | Group trip metadata & role permissions | `tripId`, `title`, `destination`, `startDate`, `endDate`, `ownerId`, `memberIds`, `memberRoles` |
| `itineraryItems` | Dated itinerary timeline items | `itemId`, `tripId`, `date`, `title`, `location`, `startTime`, `endTime`, `order` |
| `activities` | Filtered & cached activity catalog | `activityId`, `name`, `category`, `budget`, `location`, `source` |
| `checklists` | Shared trip preparation checklists | `checklistId`, `tripId`, `items[{ label, done, assignee }]` |
| `packingLists` | Shared group packing lists | `packingListId`, `tripId`, `items[{ label, packed, packedBy }]` |

## Security Rules & Access Control
- **Firestore (`firestore.rules`):** Enforces authenticated access, owner-only edits for `users/{uid}`, and trip-member/role checks (`owner`, `editor`, `viewer`) across `trips`, `itineraryItems`, `checklists`, and `packingLists`.
- **Storage (`storage.rules`):** Restricts trip media uploads to authenticated members with image content-type and file-size bounds.

## Getting Started

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```
