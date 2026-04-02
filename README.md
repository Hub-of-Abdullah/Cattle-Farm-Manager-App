# Cattle Farm Manager

A mobile application designed to help cattle farm owners manage their business operations, including cattle purchases, expenses tracking, and profit/loss calculations.

## Project Status

🚧 **Planning Phase** - This project is currently in the specification and design phase.

## Overview

Cattle Farm Manager is an **offline-first mobile application** designed specifically for farmers with minimal technical knowledge. The app helps farm owners:

- Manage cattle owner information
- Track multiple cattle under each owner
- Record cattle purchases and sales
- Monitor expenses per cattle or farm-wide
- Automatically calculate profit/loss
- Generate business reports

## Key Features

### Core Functionality
- **Owner Management**: Create, update, and manage cattle owner profiles
- **Cattle Management**: Track individual cattle with purchase details
- **Expense Tracking**: Record expenses by category (food, medicine, doctor, other)
- **Sales Management**: Record cattle sales and calculate profit/loss automatically
- **Reports**: View comprehensive reports on cattle count, expenses, and profitability

### Technical Features
- **Offline-First**: All data stored locally on the device
- **Multi-Language**: Full support for English and Bangla
- **Simple UI**: Clean, card-based design with large touch-friendly buttons
- **Automatic Calculations**: Real-time profit/loss computation

## Data Model

The application manages four main entities:

1. **Owners** - Farm owner information
2. **Cattle** - Individual cattle records with purchase details
3. **Expenses** - Expense tracking (cattle-specific or general farm expenses)
4. **Sales** - Sales records with buyer information and profit calculation

## Business Logic

```
Total Cost = Purchase Price + Total Expenses
Profit/Loss = Sale Price - Total Cost
```

## UI Design

- **Primary Color**: Green (#16A34A)
- **Design Style**: Mobile-first, card-based layout
- **Navigation**: Bottom navigation bar (Home, Owners, Cattle, Reports)
- **Language**: Switchable via Settings screen

## Technology Stack (Proposed)

- **Platform**: Mobile (iOS & Android)
- **Database**: Local storage (SQLite / Hive / Realm)
- **Languages**: Bangla & English

## Future Enhancements

- Cattle tag/ear tag tracking
- Weight tracking with history charts
- Vaccination record management
- Vaccination reminders

## Documentation

Detailed specifications and requirements can be found in:
- [docs/ui-instruction.md](docs/ui-instruction.md) - Complete application blueprint
- [docs/technical-architecture.md](docs/technical-architecture.md) - Technical specifications and architecture
- [docs/data-dictionary.md](docs/data-dictionary.md) - Data model specifications
- [docs/implementation-status.md](docs/implementation-status.md) - Development progress tracker

## License

© 2026 Cattle Farm Manager Project

---

**Note**: This is a specification document for a planned mobile application. Implementation has not yet started.
