# Data Dictionary - Cattle Farm Manager

This document provides detailed specifications for all data entities, fields, and their constraints.

## Entities Overview

| Entity | Description | Relationships |
|--------|-------------|---------------|
| Owner | Farm owner or cattle keeper | Has many cattle |
| Cattle | Individual cattle/livestock | Belongs to owner, has many expenses, has one sale |
| Expense | Cost/expenditure record | Belongs to cattle (optional) |
| Sale | Cattle sale transaction | Belongs to cattle |

---

## Owner Entity

**Purpose**: Stores information about cattle owners/keepers

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTO INCREMENT | Unique identifier |
| name | TEXT | NOT NULL, MIN 2 chars | Owner's full name |
| phone | TEXT | OPTIONAL, valid format | Contact phone number |
| address | TEXT | OPTIONAL | Owner's address |
| created_at | DATETIME | AUTO, DEFAULT NOW | Record creation timestamp |

**Business Rules**:
- Owner name is required
- Phone and address are optional but recommended
- Cannot delete owner if they have cattle (unless cascade delete is enabled)

**Example Data**:
```json
{
    "id": 1,
    "name": "আব্দুল করিম",
    "phone": "+8801712345678",
    "address": "গ্রাম: পাটগ্রাম, উপজেলা: নাটোর সদর",
    "created_at": "2026-01-15T10:30:00"
}
```

---

## Cattle Entity

**Purpose**: Records individual cattle with purchase details

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTO INCREMENT | Unique identifier |
| owner_id | INTEGER | NOT NULL, FOREIGN KEY | Reference to owner |
| cattle_unique_id | TEXT | UNIQUE, NOT NULL | User-defined unique identifier (e.g., ear tag) |
| purchase_date | DATE | NOT NULL, cannot be future | Date of purchase |
| purchase_price | DECIMAL(10,2) | NOT NULL, > 0 | Price paid for cattle |
| is_sold | BOOLEAN | DEFAULT FALSE | Whether cattle has been sold |
| created_at | DATETIME | AUTO, DEFAULT NOW | Record creation timestamp |

**Business Rules**:
- cattle_unique_id must be unique across all cattle
- Purchase price must be greater than 0
- Purchase date cannot be in the future
- Once sold (is_sold = true), should not allow further expenses
- Cannot be deleted if it has expense or sale records (or use cascade delete)

**Example Data**:
```json
{
    "id": 101,
    "owner_id": 1,
    "cattle_unique_id": "COW-2026-001",
    "purchase_date": "2026-01-20",
    "purchase_price": 45000.00,
    "is_sold": false,
    "created_at": "2026-01-20T14:20:00"
}
```

---

## Expense Entity

**Purpose**: Tracks all expenses related to cattle or general farm expenses

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTO INCREMENT | Unique identifier |
| cattle_id | INTEGER | NULLABLE, FOREIGN KEY | Reference to specific cattle (null for general expenses) |
| date | DATE | NOT NULL, cannot be future | Date of expense |
| category | TEXT | NOT NULL, ENUM | Type of expense (see categories below) |
| amount | DECIMAL(10,2) | NOT NULL, > 0 | Expense amount |
| note | TEXT | OPTIONAL | Additional notes/description |
| created_at | DATETIME | AUTO, DEFAULT NOW | Record creation timestamp |

**Expense Categories**:
- `food` - Feed, fodder, grains
- `medicine` - Medicines, supplements
- `doctor` - Veterinary services, consultations
- `other` - Any other expenses

**Business Rules**:
- If cattle_id is NULL, it's a general farm expense
- If cattle_id is provided, must reference an existing cattle
- Amount must be greater than 0
- Date cannot be in the future
- Category must be one of the predefined values

**Example Data**:

Cattle-specific expense:
```json
{
    "id": 501,
    "cattle_id": 101,
    "date": "2026-02-10",
    "category": "food",
    "amount": 1500.00,
    "note": "খড় ও দানা খাবার",
    "created_at": "2026-02-10T09:15:00"
}
```

General farm expense:
```json
{
    "id": 502,
    "cattle_id": null,
    "date": "2026-02-15",
    "category": "other",
    "amount": 3000.00,
    "note": "খামার রক্ষণাবেক্ষণ",
    "created_at": "2026-02-15T11:30:00"
}
```

---

## Sale Entity

**Purpose**: Records cattle sale transactions and buyer information

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTO INCREMENT | Unique identifier |
| cattle_id | INTEGER | UNIQUE, NOT NULL, FOREIGN KEY | Reference to sold cattle |
| sale_date | DATE | NOT NULL | Date of sale |
| sale_price | DECIMAL(10,2) | NOT NULL, > 0 | Selling price |
| buyer_name | TEXT | OPTIONAL | Name of the buyer |
| created_at | DATETIME | AUTO, DEFAULT NOW | Record creation timestamp |

**Business Rules**:
- Each cattle can have only ONE sale record (cattle_id is UNIQUE)
- Sale price must be greater than 0
- Sale date should be after purchase date
- When sale is recorded, update cattle.is_sold to TRUE
- Cannot delete sale record if cattle is marked as sold (or implement proper cleanup)

**Example Data**:
```json
{
    "id": 201,
    "cattle_id": 101,
    "sale_date": "2026-06-15",
    "sale_price": 65000.00,
    "buyer_name": "করিম মিয়া",
    "created_at": "2026-06-15T16:45:00"
}
```

---

## Calculated Fields (Virtual/Computed)

These are not stored in the database but calculated on-demand:

### Total Cost (per cattle)
```
total_cost = purchase_price + SUM(expenses.amount WHERE expenses.cattle_id = cattle.id)
```

**Example**:
```
Purchase Price: 45,000 BDT
Expense 1 (food): 1,500 BDT
Expense 2 (medicine): 800 BDT
Expense 3 (doctor): 1,200 BDT
-----------------------------
Total Cost: 48,500 BDT
```

### Profit/Loss (per cattle)
```
profit_loss = sale_price - total_cost
```

**Example**:
```
Sale Price: 65,000 BDT
Total Cost: 48,500 BDT
-----------------------------
Profit: 16,500 BDT
```

### Profit Percentage
```
profit_percentage = ((sale_price - total_cost) / total_cost) × 100
```

**Example**:
```
Profit: 16,500 BDT
Total Cost: 48,500 BDT
-----------------------------
Profit %: 34.02%
```

---

## Data Validation Rules

### Input Validation

| Field Type | Validation Rules |
|------------|------------------|
| Name fields | Min 2 characters, max 100 characters, no special characters except spaces |
| Phone | Optional, but if provided: 10-15 digits, can include country code |
| Amount | Must be positive number, max 2 decimal places |
| Date | Must be valid date, cannot be in future (except for planned features) |
| Category | Must match one of predefined categories exactly |
| Unique ID | Required, alphanumeric with hyphens allowed, max 50 characters |

### Business Logic Validation

1. **Before adding expense**:
   - Verify cattle exists (if cattle_id provided)
   - Verify cattle is not sold (if adding to specific cattle)

2. **Before recording sale**:
   - Verify cattle exists
   - Verify cattle is not already sold
   - Verify sale_date >= purchase_date

3. **Before deleting owner**:
   - Check if owner has cattle
   - Either prevent deletion or cascade delete all related records

4. **Before deleting cattle**:
   - Check if cattle has expenses or sale records
   - Either prevent deletion or cascade delete all related records

---

## Field Length Constraints

| Field | Maximum Length | Notes |
|-------|---------------|-------|
| name | 100 characters | For all name fields |
| phone | 20 characters | Includes country code |
| address | 500 characters | Multi-line allowed |
| cattle_unique_id | 50 characters | User-defined format |
| note | 1000 characters | For expense notes |
| category | 20 characters | Predefined values |

---

## Display Formats

### Currency
- Format: `৳ 45,000.00` (Bangla) or `BDT 45,000.00` (English)
- Always show 2 decimal places
- Use thousand separators

### Date
- Storage: ISO 8601 format (YYYY-MM-DD)
- Display (Bangla): `১৫ জানুয়ারি ২০২৬`
- Display (English): `15 January 2026`

### Phone
- Storage: `+8801712345678`
- Display: `+880 171 234 5678` or `০১৭১২-৩৪৫৬৭৮`

---

## Data Migration Considerations

If extending the schema in the future:

1. **Adding new fields**: Use ALTER TABLE with DEFAULT values
2. **Changing field types**: Create new field, migrate data, drop old field
3. **Adding relationships**: Ensure foreign key constraints are properly defined
4. **Version tracking**: Maintain database version number for migrations

---

## Sample Complete Dataset

### Owner 1
```
ID: 1
Name: আব্দুল করিম
Phone: +8801712345678
Address: গ্রাম: পাটগ্রাম, নাটোর
```

### Cattle 1 (under Owner 1)
```
ID: 101
Owner: আব্দুল করিম (ID: 1)
Unique ID: COW-2026-001
Purchase Date: 2026-01-20
Purchase Price: ৳ 45,000.00
Status: Sold
```

### Expenses for Cattle 1
```
1. Food - 2026-02-10 - ৳ 1,500.00
2. Medicine - 2026-03-05 - ৳ 800.00
3. Doctor - 2026-04-12 - ৳ 1,200.00
Total Expenses: ৳ 3,500.00
```

### Sale Record for Cattle 1
```
Sale Date: 2026-06-15
Sale Price: ৳ 65,000.00
Buyer: করিম মিয়া
```

### Calculations
```
Total Cost: ৳ 45,000.00 + ৳ 3,500.00 = ৳ 48,500.00
Profit: ৳ 65,000.00 - ৳ 48,500.00 = ৳ 16,500.00
Profit %: 34.02%
```

---

## Notes for Developers

1. **Decimal Precision**: Use DECIMAL(10,2) for all monetary values to avoid floating-point errors
2. **Date Storage**: Store dates in UTC and convert to local timezone for display
3. **Null Values**: cattle_id in expenses can be NULL for general farm expenses
4. **Unique Constraints**: cattle_unique_id must be unique - enforce at both database and application level
5. **Cascading Deletes**: Consider business requirements before enabling CASCADE DELETE
6. **Indexes**: Create indexes on foreign keys and frequently queried fields for better performance
