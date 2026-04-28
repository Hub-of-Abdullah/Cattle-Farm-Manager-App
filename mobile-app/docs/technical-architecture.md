# Technical Architecture - Cattle Farm Manager

## Overview

This document outlines the technical architecture, database schema, and implementation guidelines for the Cattle Farm Manager mobile application.

## Technology Stack Recommendations

### Mobile Framework Options

**Option 1: Flutter (Recommended)**
- Cross-platform (iOS & Android) from single codebase
- Excellent offline-first capabilities
- Strong localization support
- Rich UI component library
- Database: Hive or Drift (formerly Moor)
- State Management: Provider or Riverpod

**Option 2: React Native**
- JavaScript/TypeScript ecosystem
- Database: Realm or SQLite
- State Management: Redux Toolkit or Zustand

**Option 3: Native Development**
- iOS: Swift + SwiftUI + CoreData
- Android: Kotlin + Jetpack Compose + Room

## Database Schema

### Tables

#### owners
```sql
CREATE TABLE owners (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    phone TEXT,
    address TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

#### cattle
```sql
CREATE TABLE cattle (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    owner_id INTEGER NOT NULL,
    cattle_unique_id TEXT UNIQUE NOT NULL,
    purchase_date DATE NOT NULL,
    purchase_price DECIMAL(10,2) NOT NULL,
    is_sold BOOLEAN DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES owners(id) ON DELETE CASCADE
);
```

#### expenses
```sql
CREATE TABLE expenses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cattle_id INTEGER NULL,
    date DATE NOT NULL,
    category TEXT NOT NULL CHECK(category IN ('food', 'medicine', 'doctor', 'other')),
    amount DECIMAL(10,2) NOT NULL,
    note TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cattle_id) REFERENCES cattle(id) ON DELETE CASCADE
);
```

#### sales
```sql
CREATE TABLE sales (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cattle_id INTEGER NOT NULL UNIQUE,
    sale_date DATE NOT NULL,
    sale_price DECIMAL(10,2) NOT NULL,
    buyer_name TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cattle_id) REFERENCES cattle(id) ON DELETE CASCADE
);
```

### Indexes for Performance

```sql
CREATE INDEX idx_cattle_owner ON cattle(owner_id);
CREATE INDEX idx_expenses_cattle ON expenses(cattle_id);
CREATE INDEX idx_sales_cattle ON sales(cattle_id);
CREATE INDEX idx_cattle_sold ON cattle(is_sold);
```

## Data Relationships

```
owners (1) ──────── (N) cattle
                      │
                      ├──── (N) expenses
                      │
                      └──── (1) sales
```

- One owner can have multiple cattle
- One cattle can have multiple expenses
- One cattle can have at most one sale record
- Expenses can be cattle-specific or general (cattle_id = NULL)

## Calculation Logic

### Total Cost Per Cattle

```
function calculateTotalCost(cattleId):
    cattle = getCattle(cattleId)
    expenses = getExpenses(cattleId)

    totalExpenses = sum(expenses.map(e => e.amount))
    totalCost = cattle.purchase_price + totalExpenses

    return totalCost
```

### Profit/Loss Calculation

```
function calculateProfitLoss(cattleId):
    sale = getSale(cattleId)
    if not sale:
        return null  // Not yet sold

    totalCost = calculateTotalCost(cattleId)
    profitLoss = sale.sale_price - totalCost

    return {
        totalCost: totalCost,
        salePrice: sale.sale_price,
        profitLoss: profitLoss,
        isProfitable: profitLoss > 0
    }
```

### Dashboard Statistics

```
function getDashboardStats():
    return {
        totalCattle: count(cattle),
        activeCattle: count(cattle where is_sold = 0),
        soldCattle: count(cattle where is_sold = 1),
        totalExpenses: sum(expenses.amount),
        totalRevenue: sum(sales.sale_price),
        totalProfit: totalRevenue - (sum of all costs),
        totalOwners: count(owners)
    }
```

## State Management Strategy

### Application State Structure

```
AppState:
    - owners: List<Owner>
    - cattle: List<Cattle>
    - expenses: List<Expense>
    - sales: List<Sale>
    - settings: AppSettings
        - language: 'en' | 'bn'
        - theme: 'light' | 'dark' (future)
    - ui:
        - currentScreen: String
        - loading: Boolean
        - error: String?
```

### Local Database Operations

All CRUD operations should:
1. Update local database first
2. Update in-memory state
3. Trigger UI refresh
4. Handle errors gracefully with user-friendly messages

## Folder Structure

### Flutter Example

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── colors.dart
│   │   └── strings.dart
│   ├── database/
│   │   ├── database_helper.dart
│   │   └── tables.dart
│   └── utils/
│       ├── date_formatter.dart
│       └── currency_formatter.dart
├── models/
│   ├── owner.dart
│   ├── cattle.dart
│   ├── expense.dart
│   └── sale.dart
├── providers/
│   ├── owner_provider.dart
│   ├── cattle_provider.dart
│   ├── expense_provider.dart
│   ├── sale_provider.dart
│   └── settings_provider.dart
├── l10n/
│   ├── app_en.json
│   └── app_bn.json
├── screens/
│   ├── splash/
│   │   └── splash_screen.dart
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   ├── owners/
│   │   ├── owner_list_screen.dart
│   │   ├── owner_details_screen.dart
│   │   └── add_owner_screen.dart
│   ├── cattle/
│   │   ├── cattle_list_screen.dart
│   │   ├── cattle_details_screen.dart
│   │   └── add_cattle_screen.dart
│   ├── expenses/
│   │   ├── expense_list_screen.dart
│   │   └── add_expense_screen.dart
│   ├── sales/
│   │   └── sell_cattle_screen.dart
│   ├── reports/
│   │   └── reports_screen.dart
│   └── settings/
│       └── settings_screen.dart
└── widgets/
    ├── common/
    │   ├── custom_button.dart
    │   ├── custom_card.dart
    │   └── loading_indicator.dart
    └── specific/
        ├── cattle_card.dart
        ├── owner_card.dart
        └── expense_item.dart
```

## Localization Implementation

### English (en)
```json
{
    "app_title": "Cattle Farm Manager",
    "owner": "Owner",
    "cattle": "Cattle",
    "expense": "Expense",
    "purchase_price": "Purchase Price",
    "sale_price": "Sale Price",
    "profit": "Profit",
    "loss": "Loss",
    "add_owner": "Add Owner",
    "add_cattle": "Add Cattle"
}
```

### Bangla (bn)
```json
{
    "app_title": "গবাদি পশু খামার ব্যবস্থাপক",
    "owner": "মালিক",
    "cattle": "গবাদি পশু",
    "expense": "খরচ",
    "purchase_price": "কেনার দাম",
    "sale_price": "বিক্রির দাম",
    "profit": "লাভ",
    "loss": "ক্ষতি",
    "add_owner": "মালিক যোগ করুন",
    "add_cattle": "পশু যোগ করুন"
}
```

## Error Handling

### Database Operations
- Wrap all DB operations in try-catch blocks
- Show user-friendly error messages
- Log errors for debugging
- Provide retry mechanisms for failed operations

### Validation Rules
- Owner name: Required, min 2 characters
- Phone: Optional, but if provided must be valid format
- Purchase price: Required, must be > 0
- Sale price: Required, must be > 0
- Expense amount: Required, must be > 0
- Dates: Cannot be in the future

## Performance Considerations

1. **Lazy Loading**: Load data as needed, not all at once
2. **Pagination**: For large lists (>100 items), implement pagination
3. **Indexing**: Database indexes on foreign keys and frequently queried fields
4. **Caching**: Cache frequently accessed data in memory
5. **Debouncing**: Debounce search inputs to reduce database queries

## Security & Data Privacy

1. **Local Data Only**: No cloud sync, data stays on device
2. **No Authentication**: Single-user app, no login required
3. **Backup/Export**: Provide data export functionality (CSV/Excel)
4. **Data Deletion**: Cascade delete when owner is deleted

## Testing Strategy

1. **Unit Tests**: Test all calculation functions
2. **Widget Tests**: Test individual UI components
3. **Integration Tests**: Test complete user flows
4. **Database Tests**: Test CRUD operations

## Development Roadmap

### Phase 1: Core Features (MVP)
- [ ] Database setup
- [ ] Owner management (CRUD)
- [ ] Cattle management (CRUD)
- [ ] Expense tracking
- [ ] Sales recording
- [ ] Basic profit/loss calculation

### Phase 2: UI/UX Enhancement
- [ ] Splash screen
- [ ] Dashboard with statistics
- [ ] Bottom navigation
- [ ] Card-based layouts
- [ ] Loading states and animations

### Phase 3: Localization
- [ ] English localization
- [ ] Bangla localization
- [ ] Language switcher in settings

### Phase 4: Reports & Analytics
- [ ] Profit/loss per cattle
- [ ] Total expenses breakdown
- [ ] Monthly/yearly reports
- [ ] Export reports

### Phase 5: Future Enhancements
- [ ] Cattle tag/ear tag system
- [ ] Weight tracking
- [ ] Vaccination records
- [ ] Backup/restore functionality
- [ ] Dark mode

## Conclusion

This architecture provides a solid foundation for building a reliable, offline-first cattle farm management application that is simple enough for farmers with minimal technical knowledge while being robust enough for real-world farm management needs.
