# Personal Expense Tracker

A Flutter app to record expenses and income, browse transactions by day and month, search the ledger, and view category breakdown charts. Data is stored locally with **Hive**.

Screenshots live in **`docs/screenshots/`** (JPEG files below).

---

## Tech stack

| Area | Packages / patterns |
|------|---------------------|
| UI | Flutter (Material 3) |
| State | `flutter_bloc` |
| Local DB | `hive` / `hive_flutter` |
| Charts | `fl_chart` |
| Utilities | `intl`, `equatable` |

Architecture follows a simple layered layout: **domain** (entities, repository contracts), **data** (Hive models, mappers, repository implementation), **presentation** (pages, widgets, blocs), and **core** (theme, routing helpers, shared widgets).

---

## Getting started

```bash
flutter pub get
flutter run
```

---

## Screens (with screenshots)

### Splash screen (`SplashScreen`)

Animated intro on a light blue background: wallet icon, **Expense Tracker** title and subtitle, then transition into the main app.

![Splash screen](docs/screenshots/splash_screen.jpeg)

---

### Home — Transactions list (`TransactionsListPage`)

Transactions grouped **by day** with headers, **month navigation**, calendar-style picking, optional **day filter**, and a summary area where balance visibility can be toggled. Opens **add transaction** and **detail** from rows.

**Default list**

![Transactions list](docs/screenshots/transcation_list_page.jpeg)

**Balance hidden**

![Transactions list — hide balance](docs/screenshots/transcation_list_page%28hide_balance%29.jpeg)

**Calendar / specific day selection**

![Transactions list — calendar specific day](docs/screenshots/transcation_list_page%28calender_specfic%29.jpeg)

**Filtered by selected date**

![Transactions list — date filter result](docs/screenshots/transcation_list_page%28date_filter_result%29.jpeg)

---

### Search (`TransactionSearchPage`)

Search titles, notes, and categories; filters and history. Results grouped by day.

**Search field & filters**

![Search page](docs/screenshots/search_page.jpeg)

**Search results**

![Search results](docs/screenshots/search_page%28result%29.jpeg)

---

### Charts (`ChartsPage`)

Donut chart by category for the focused month, with **expense** vs **income** views.

**Expense breakdown**

![Charts — expense](docs/screenshots/chart_page%28expense%29.jpeg)

**Income breakdown**

![Charts — income](docs/screenshots/chart_pge%28income%29.jpeg)

---

### Add / edit transaction (`AddTransactionPage`)

Expense vs income, emoji categories / tabs, custom keypad, currency and date, title and note. Four captures below walk through the create/edit UI (`create(1)` … `create(4)`).

![Create transaction — step 1](docs/screenshots/create%281%29.jpeg)

![Create transaction — step 2](docs/screenshots/create%282%29.jpeg)

![Create transaction — step 3](docs/screenshots/create%283%29.jpeg)

![Create transaction — step 4](docs/screenshots/create%284%29.jpeg)

---

### Transaction detail (`TransactionDetailPage`)

Large summary card (emoji, title, signed amount), full-field breakdown, **Edit** and **Delete**.

![Transaction detail](docs/screenshots/detail.jpeg)

---

## Testing

The project includes **unit tests** (`AmountInputBuffer`, fake repository) and **widget tests** (splash, bottom navigation, search tab).

Run all tests:

```bash
flutter test
```

Run individual files:

```bash
flutter test test/widget_test.dart
flutter test test/amount_input_buffer_test.dart
flutter test test/fake_transaction_repository_test.dart
```

---

## License

This project is for personal .
