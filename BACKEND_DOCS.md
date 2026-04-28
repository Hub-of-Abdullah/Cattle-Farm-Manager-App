# Cattle Farm Manager — NestJS Backend Documentation

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Tech Stack](#2-tech-stack)
3. [Project Structure](#3-project-structure)
4. [Database Schema](#4-database-schema)
5. [Modules & Entities](#5-modules--entities)
6. [API Reference](#6-api-reference)
   - [Auth](#61-auth)
   - [Owners](#62-owners)
   - [Cattle](#63-cattle)
   - [Expenses](#64-expenses)
   - [Sales](#65-sales)
   - [Firm Deposits](#66-firm-deposits)
   - [Dashboard](#67-dashboard)
   - [Reports](#68-reports)
7. [DTOs](#7-dtos)
8. [Guards & Middleware](#8-guards--middleware)
9. [Environment Variables](#9-environment-variables)
10. [Error Handling](#10-error-handling)

---

## 1. Project Overview

The Cattle Farm Manager backend is a RESTful API built with NestJS that serves the Flutter mobile application. It manages livestock ownership, cattle inventory, expenses, sales, and the firm's financial account.

**Core features:**
- Multi-owner cattle management
- Per-owner expense tracking (food, medicine, doctor, take profit, other/custom)
- Cattle sales with automatic firm account deposits
- Firm account ledger (deposits and withdrawals)
- Dashboard stats and per-owner financial reports
- JWT-based authentication

---

## 2. Tech Stack

| Layer | Technology |
|---|---|
| Framework | NestJS (Node.js) |
| Language | TypeScript |
| ORM | TypeORM |
| Database | PostgreSQL (production) / SQLite (dev) |
| Auth | JWT + Passport.js |
| Validation | class-validator + class-transformer |
| Documentation | Swagger (OpenAPI) |
| Testing | Jest |

**Install dependencies:**

```bash
npm install @nestjs/common @nestjs/core @nestjs/platform-express
npm install @nestjs/typeorm typeorm pg
npm install @nestjs/jwt @nestjs/passport passport passport-jwt
npm install class-validator class-transformer
npm install @nestjs/swagger swagger-ui-express
npm install @nestjs/config
npm install bcrypt
npm install -D @types/passport-jwt @types/bcrypt
```

---

## 3. Project Structure

```
src/
├── app.module.ts
├── main.ts
│
├── auth/
│   ├── auth.module.ts
│   ├── auth.controller.ts
│   ├── auth.service.ts
│   ├── jwt.strategy.ts
│   ├── jwt-auth.guard.ts
│   └── dto/
│       ├── login.dto.ts
│       └── register.dto.ts
│
├── owners/
│   ├── owners.module.ts
│   ├── owners.controller.ts
│   ├── owners.service.ts
│   ├── owner.entity.ts
│   └── dto/
│       ├── create-owner.dto.ts
│       └── update-owner.dto.ts
│
├── cattle/
│   ├── cattle.module.ts
│   ├── cattle.controller.ts
│   ├── cattle.service.ts
│   ├── cattle.entity.ts
│   └── dto/
│       ├── create-cattle.dto.ts
│       └── update-cattle.dto.ts
│
├── expenses/
│   ├── expenses.module.ts
│   ├── expenses.controller.ts
│   ├── expenses.service.ts
│   ├── expense.entity.ts
│   └── dto/
│       ├── create-expense.dto.ts
│       └── update-expense.dto.ts
│
├── sales/
│   ├── sales.module.ts
│   ├── sales.controller.ts
│   ├── sales.service.ts
│   ├── sale.entity.ts
│   └── dto/
│       └── create-sale.dto.ts
│
├── firm-deposits/
│   ├── firm-deposits.module.ts
│   ├── firm-deposits.controller.ts
│   ├── firm-deposits.service.ts
│   ├── firm-deposit.entity.ts
│   └── dto/
│       └── create-firm-deposit.dto.ts
│
├── dashboard/
│   ├── dashboard.module.ts
│   ├── dashboard.controller.ts
│   └── dashboard.service.ts
│
└── reports/
    ├── reports.module.ts
    ├── reports.controller.ts
    └── reports.service.ts
```

---

## 4. Database Schema

### Entity Relationship Diagram (text)

```
users
  └──< owners (created_by → users.id)
         └──< cattle (owner_id → owners.id)  [CASCADE DELETE]
         │      └──o sale (cattle_id → cattle.id)  [CASCADE DELETE, UNIQUE]
         └──< expenses (owner_id → owners.id)  [CASCADE DELETE]

firm_deposits  (independent ledger)
```

### SQL Schema

```sql
CREATE TABLE users (
  id          SERIAL PRIMARY KEY,
  email       VARCHAR(255) UNIQUE NOT NULL,
  password    VARCHAR(255) NOT NULL,  -- bcrypt hash
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE owners (
  id          SERIAL PRIMARY KEY,
  name        VARCHAR(255) NOT NULL,
  phone       VARCHAR(50),
  address     TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE cattle (
  id                SERIAL PRIMARY KEY,
  owner_id          INTEGER NOT NULL REFERENCES owners(id) ON DELETE CASCADE,
  cattle_unique_id  VARCHAR(100) UNIQUE NOT NULL,
  purchase_date     DATE NOT NULL,
  purchase_price    DECIMAL(12,2) NOT NULL,
  is_sold           BOOLEAN NOT NULL DEFAULT FALSE,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE sales (
  id          SERIAL PRIMARY KEY,
  cattle_id   INTEGER UNIQUE NOT NULL REFERENCES cattle(id) ON DELETE CASCADE,
  sale_date   DATE NOT NULL,
  sale_price  DECIMAL(12,2) NOT NULL,
  buyer_name  VARCHAR(255),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE expenses (
  id               SERIAL PRIMARY KEY,
  owner_id         INTEGER REFERENCES owners(id) ON DELETE CASCADE,
  date             DATE NOT NULL,
  category         VARCHAR(50) NOT NULL,   -- food | medicine | doctor | takeProfit | other
  custom_category  VARCHAR(255),           -- filled when category = 'other'
  amount           DECIMAL(12,2) NOT NULL,
  note             TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE firm_deposits (
  id          SERIAL PRIMARY KEY,
  amount      DECIMAL(12,2) NOT NULL,  -- positive = deposit, negative = withdrawal
  date        DATE NOT NULL,
  note        TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_cattle_owner  ON cattle(owner_id);
CREATE INDEX idx_cattle_sold   ON cattle(is_sold);
CREATE INDEX idx_expenses_owner ON expenses(owner_id);
CREATE INDEX idx_sales_cattle  ON sales(cattle_id);
```

---

## 5. Modules & Entities

### 5.1 Owner Entity

```typescript
// owners/owner.entity.ts
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn,
         OneToMany } from 'typeorm';
import { Cattle } from '../cattle/cattle.entity';
import { Expense } from '../expenses/expense.entity';

@Entity('owners')
export class Owner {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @Column({ nullable: true })
  phone: string;

  @Column({ nullable: true })
  address: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @OneToMany(() => Cattle, (cattle) => cattle.owner)
  cattle: Cattle[];

  @OneToMany(() => Expense, (expense) => expense.owner)
  expenses: Expense[];
}
```

### 5.2 Cattle Entity

```typescript
// cattle/cattle.entity.ts
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn,
         ManyToOne, JoinColumn, OneToOne } from 'typeorm';
import { Owner } from '../owners/owner.entity';
import { Sale } from '../sales/sale.entity';

@Entity('cattle')
export class Cattle {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'owner_id' })
  ownerId: number;

  @ManyToOne(() => Owner, (owner) => owner.cattle, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'owner_id' })
  owner: Owner;

  @Column({ name: 'cattle_unique_id', unique: true })
  cattleUniqueId: string;

  @Column({ name: 'purchase_date', type: 'date' })
  purchaseDate: string;

  @Column({ name: 'purchase_price', type: 'decimal', precision: 12, scale: 2 })
  purchasePrice: number;

  @Column({ name: 'is_sold', default: false })
  isSold: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @OneToOne(() => Sale, (sale) => sale.cattle)
  sale: Sale;
}
```

### 5.3 Expense Entity

```typescript
// expenses/expense.entity.ts
export enum ExpenseCategory {
  FOOD       = 'food',
  MEDICINE   = 'medicine',
  DOCTOR     = 'doctor',
  TAKE_PROFIT = 'takeProfit',
  OTHER      = 'other',
}

@Entity('expenses')
export class Expense {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'owner_id', nullable: true })
  ownerId: number;

  @ManyToOne(() => Owner, (owner) => owner.expenses, {
    nullable: true, onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'owner_id' })
  owner: Owner;

  @Column({ type: 'date' })
  date: string;

  @Column({ type: 'enum', enum: ExpenseCategory })
  category: ExpenseCategory;

  @Column({ name: 'custom_category', nullable: true })
  customCategory: string;

  @Column({ type: 'decimal', precision: 12, scale: 2 })
  amount: number;

  @Column({ nullable: true })
  note: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
```

### 5.4 Sale Entity

```typescript
// sales/sale.entity.ts
@Entity('sales')
export class Sale {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'cattle_id', unique: true })
  cattleId: number;

  @OneToOne(() => Cattle, (cattle) => cattle.sale, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'cattle_id' })
  cattle: Cattle;

  @Column({ name: 'sale_date', type: 'date' })
  saleDate: string;

  @Column({ name: 'sale_price', type: 'decimal', precision: 12, scale: 2 })
  salePrice: number;

  @Column({ name: 'buyer_name', nullable: true })
  buyerName: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
```

### 5.5 FirmDeposit Entity

```typescript
// firm-deposits/firm-deposit.entity.ts
@Entity('firm_deposits')
export class FirmDeposit {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'decimal', precision: 12, scale: 2 })
  amount: number;  // positive = deposit, negative = withdrawal

  @Column({ type: 'date' })
  date: string;

  @Column({ nullable: true })
  note: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
```

---

## 6. API Reference

**Base URL:** `https://api.cattlefarm.com/v1`

All endpoints (except `/auth/*`) require:
```
Authorization: Bearer <jwt_token>
```

---

### 6.1 Auth

#### POST `/auth/register`
Register a new user account.

**Request body:**
```json
{
  "email": "admin@farm.com",
  "password": "SecurePass123"
}
```

**Response `201`:**
```json
{
  "id": 1,
  "email": "admin@farm.com",
  "createdAt": "2026-04-28T10:00:00Z"
}
```

---

#### POST `/auth/login`
Authenticate and receive a JWT token.

**Request body:**
```json
{
  "email": "admin@farm.com",
  "password": "SecurePass123"
}
```

**Response `200`:**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 86400
}
```

---

### 6.2 Owners

#### GET `/owners`
List all owners, ordered by name.

**Response `200`:**
```json
[
  {
    "id": 1,
    "name": "Rahim Uddin",
    "phone": "01700000000",
    "address": "Dhaka, Bangladesh",
    "createdAt": "2026-04-01T00:00:00Z"
  }
]
```

---

#### POST `/owners`
Create a new owner.

**Request body:**
```json
{
  "name": "Rahim Uddin",
  "phone": "01700000000",
  "address": "Dhaka, Bangladesh"
}
```

**Response `201`:** Created owner object.

---

#### GET `/owners/:id`
Get a single owner by ID.

**Response `200`:** Owner object.
**Response `404`:** Owner not found.

---

#### GET `/owners/:id/details`
Get owner with cattle list, expense summary, and financial totals.

**Response `200`:**
```json
{
  "id": 1,
  "name": "Rahim Uddin",
  "phone": "01700000000",
  "address": "Dhaka, Bangladesh",
  "createdAt": "2026-04-01T00:00:00Z",
  "cattle": [
    {
      "id": 10,
      "cattleUniqueId": "C-001",
      "purchaseDate": "2026-01-15",
      "purchasePrice": 50000,
      "isSold": true
    }
  ],
  "summary": {
    "totalCattle": 5,
    "activeCattle": 3,
    "soldCattle": 2,
    "totalPurchaseCost": 250000,
    "totalExpenses": 12000,
    "totalRevenue": 140000,
    "grandTotal": 262000
  }
}
```

---

#### PATCH `/owners/:id`
Update an owner.

**Request body (partial):**
```json
{
  "phone": "01711111111",
  "address": "Chittagong, Bangladesh"
}
```

**Response `200`:** Updated owner object.

---

#### DELETE `/owners/:id`
Delete an owner. Cascades to their cattle and expenses.

**Response `200`:**
```json
{ "message": "Owner deleted successfully" }
```

---

### 6.3 Cattle

#### GET `/cattle`
List all cattle, newest first.

**Query params:**

| Param | Type | Description |
|---|---|---|
| `ownerId` | number | Filter by owner |
| `isSold` | boolean | Filter by sold status |

**Response `200`:**
```json
[
  {
    "id": 10,
    "ownerId": 1,
    "cattleUniqueId": "C-001",
    "purchaseDate": "2026-01-15",
    "purchasePrice": 50000,
    "isSold": false,
    "createdAt": "2026-01-15T08:00:00Z"
  }
]
```

---

#### POST `/cattle`
Add new cattle.

**Request body:**
```json
{
  "ownerId": 1,
  "cattleUniqueId": "C-001",
  "purchaseDate": "2026-01-15",
  "purchasePrice": 50000
}
```

**Response `201`:** Created cattle object.
**Response `409`:** `cattleUniqueId` already exists.

---

#### GET `/cattle/:id`
Get a single cattle record with its sale info (if sold).

**Response `200`:**
```json
{
  "id": 10,
  "ownerId": 1,
  "cattleUniqueId": "C-001",
  "purchaseDate": "2026-01-15",
  "purchasePrice": 50000,
  "isSold": true,
  "createdAt": "2026-01-15T08:00:00Z",
  "sale": {
    "id": 3,
    "saleDate": "2026-03-10",
    "salePrice": 70000,
    "buyerName": "Karim"
  }
}
```

---

#### PATCH `/cattle/:id`
Update cattle details (cannot change `ownerId` or `cattleUniqueId`).

**Request body (partial):**
```json
{
  "purchasePrice": 52000,
  "purchaseDate": "2026-01-16"
}
```

**Response `200`:** Updated cattle object.

---

#### DELETE `/cattle/:id`
Delete cattle. Cascades to its sale record.

**Response `200`:**
```json
{ "message": "Cattle deleted successfully" }
```

---

### 6.4 Expenses

#### GET `/expenses`
List all expenses, newest first.

**Query params:**

| Param | Type | Description |
|---|---|---|
| `ownerId` | number | Filter by owner |
| `category` | string | Filter by category |
| `from` | date (YYYY-MM-DD) | Start date filter |
| `to` | date (YYYY-MM-DD) | End date filter |

**Response `200`:**
```json
[
  {
    "id": 5,
    "ownerId": 1,
    "date": "2026-04-10",
    "category": "medicine",
    "customCategory": null,
    "amount": 1500,
    "note": "Antibiotic for C-001",
    "createdAt": "2026-04-10T09:00:00Z"
  },
  {
    "id": 6,
    "ownerId": 1,
    "date": "2026-04-12",
    "category": "other",
    "customCategory": "Transport",
    "amount": 800,
    "note": null,
    "createdAt": "2026-04-12T11:00:00Z"
  }
]
```

---

#### POST `/expenses`
Record a new expense.

**Request body:**
```json
{
  "ownerId": 1,
  "date": "2026-04-10",
  "category": "medicine",
  "customCategory": null,
  "amount": 1500,
  "note": "Antibiotic for C-001"
}
```

> When `category` is `"other"`, `customCategory` must be provided.

**Response `201`:** Created expense object.

---

#### GET `/expenses/:id`
Get a single expense.

**Response `200`:** Expense object.

---

#### PATCH `/expenses/:id`
Update an expense.

**Request body (partial):**
```json
{
  "amount": 2000,
  "note": "Updated note"
}
```

**Response `200`:** Updated expense object.

---

#### DELETE `/expenses/:id`
Delete an expense.

**Response `200`:**
```json
{ "message": "Expense deleted successfully" }
```

---

### 6.5 Sales

#### GET `/sales`
List all sales.

**Response `200`:**
```json
[
  {
    "id": 3,
    "cattleId": 10,
    "saleDate": "2026-03-10",
    "salePrice": 70000,
    "buyerName": "Karim",
    "createdAt": "2026-03-10T14:00:00Z"
  }
]
```

---

#### POST `/sales`
Record a cattle sale. Also marks the cattle as `isSold = true`.

**Request body:**
```json
{
  "cattleId": 10,
  "saleDate": "2026-03-10",
  "salePrice": 70000,
  "buyerName": "Karim",
  "addToFirmAccount": true,
  "firmAccountAmount": 70000
}
```

> If `addToFirmAccount` is `true`, a `FirmDeposit` entry is automatically created with `firmAccountAmount` (defaults to `salePrice` if not provided) and note `"Sale: <cattleUniqueId>"`.

**Response `201`:**
```json
{
  "sale": {
    "id": 3,
    "cattleId": 10,
    "saleDate": "2026-03-10",
    "salePrice": 70000,
    "buyerName": "Karim",
    "createdAt": "2026-03-10T14:00:00Z"
  },
  "firmDeposit": {
    "id": 12,
    "amount": 70000,
    "date": "2026-03-10",
    "note": "Sale: C-001",
    "createdAt": "2026-03-10T14:00:00Z"
  }
}
```

**Response `409`:** Cattle already sold.
**Response `404`:** Cattle not found.

---

#### DELETE `/sales/:id`
Delete a sale record and mark the cattle as `isSold = false`.

**Response `200`:**
```json
{ "message": "Sale deleted and cattle marked as active" }
```

---

### 6.6 Firm Deposits

#### GET `/firm-deposits`
List all firm deposit/withdrawal transactions, newest first.

**Response `200`:**
```json
[
  {
    "id": 12,
    "amount": 70000,
    "date": "2026-03-10",
    "note": "Sale: C-001",
    "createdAt": "2026-03-10T14:00:00Z"
  },
  {
    "id": 11,
    "amount": -5000,
    "date": "2026-03-05",
    "note": "Fuel expense",
    "createdAt": "2026-03-05T10:00:00Z"
  }
]
```

> `amount > 0` = deposit, `amount < 0` = withdrawal.

---

#### POST `/firm-deposits`
Add a deposit or withdrawal.

**Request body:**
```json
{
  "amount": 20000,
  "date": "2026-04-28",
  "note": "Capital injection"
}
```

> Send a negative `amount` for withdrawals (e.g. `"amount": -5000`).

**Response `201`:** Created firm deposit object.

---

#### DELETE `/firm-deposits/:id`
Delete a transaction.

**Response `200`:**
```json
{ "message": "Transaction deleted successfully" }
```

---

### 6.7 Dashboard

#### GET `/dashboard`
Returns all stats needed for the home dashboard in one call.

**Response `200`:**
```json
{
  "totalOwners": 5,
  "totalCattle": 42,
  "activeCattle": 28,
  "soldCattle": 14,
  "totalRevenue": 980000,
  "totalExpenses": 74000,
  "totalPurchaseCost": 1260000,
  "totalDeposits": 200000,
  "firmBalance": -154000
}
```

**firmBalance formula:**
```
firmBalance = totalRevenue + totalDeposits - totalPurchaseCost - totalExpenses
```

---

### 6.8 Reports

#### GET `/reports/summary`
Full financial summary report.

**Response `200`:**
```json
{
  "overview": {
    "totalCattle": 42,
    "activeCattle": 28,
    "soldCattle": 14
  },
  "financial": {
    "totalRevenue": 980000,
    "totalExpenses": 74000,
    "totalPurchaseCostSold": 640000,
    "profitLoss": 340000
  },
  "firmAccount": {
    "totalRevenue": 980000,
    "totalDeposits": 200000,
    "totalPurchaseCost": 1260000,
    "totalExpenses": 74000,
    "balance": -154000
  },
  "expensesByCategory": {
    "food": 30000,
    "medicine": 18000,
    "doctor": 12000,
    "takeProfit": 5000,
    "other": 9000
  }
}
```

---

#### GET `/reports/per-owner`
Financial breakdown for each owner.

**Response `200`:**
```json
[
  {
    "owner": {
      "id": 1,
      "name": "Rahim Uddin"
    },
    "totalCattle": 10,
    "activeCattle": 7,
    "soldCattle": 3,
    "totalPurchaseCost": 300000,
    "totalExpenses": 15000,
    "totalRevenue": 210000,
    "balance": -105000
  }
]
```

---

#### GET `/reports/per-cattle`
Profit/loss for each sold cattle.

**Response `200`:**
```json
[
  {
    "cattle": {
      "id": 10,
      "cattleUniqueId": "C-001",
      "purchasePrice": 50000
    },
    "salePrice": 70000,
    "profitLoss": 20000
  }
]
```

---

#### GET `/reports/transactions`
Unified transaction history (firm deposits + sales + expenses), sorted newest first.

**Query params:**

| Param | Type | Description |
|---|---|---|
| `from` | date | Start date |
| `to` | date | End date |

**Response `200`:**
```json
[
  {
    "type": "sale",
    "date": "2026-03-10",
    "amount": 70000,
    "title": "Sale: C-001",
    "subtitle": "Buyer: Karim",
    "icon": "sell"
  },
  {
    "type": "expense",
    "date": "2026-04-10",
    "amount": -1500,
    "title": "Expense: Medicine",
    "subtitle": "Rahim Uddin",
    "icon": "receipt_long"
  },
  {
    "type": "deposit",
    "date": "2026-04-01",
    "amount": 20000,
    "title": "Add Money",
    "subtitle": "Capital injection",
    "icon": "add_circle_outline",
    "deletable": true,
    "id": 11
  }
]
```

---

## 7. DTOs

### create-owner.dto.ts

```typescript
import { IsString, IsNotEmpty, IsOptional, MaxLength } from 'class-validator';

export class CreateOwnerDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(255)
  name: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  phone?: string;

  @IsOptional()
  @IsString()
  address?: string;
}
```

---

### create-cattle.dto.ts

```typescript
import { IsString, IsNotEmpty, IsInt, IsPositive,
         IsDateString, MaxLength } from 'class-validator';

export class CreateCattleDto {
  @IsInt()
  @IsPositive()
  ownerId: number;

  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  cattleUniqueId: string;

  @IsDateString()
  purchaseDate: string;

  @IsPositive()
  purchasePrice: number;
}
```

---

### create-expense.dto.ts

```typescript
import { IsEnum, IsDateString, IsPositive, IsOptional,
         IsString, IsInt, ValidateIf } from 'class-validator';
import { ExpenseCategory } from '../expense.entity';

export class CreateExpenseDto {
  @IsInt()
  @IsOptional()
  ownerId?: number;

  @IsDateString()
  date: string;

  @IsEnum(ExpenseCategory)
  category: ExpenseCategory;

  @ValidateIf((o) => o.category === ExpenseCategory.OTHER)
  @IsString()
  @IsOptional()
  customCategory?: string;

  @IsPositive()
  amount: number;

  @IsOptional()
  @IsString()
  note?: string;
}
```

---

### create-sale.dto.ts

```typescript
import { IsInt, IsPositive, IsDateString, IsOptional,
         IsBoolean, IsString } from 'class-validator';

export class CreateSaleDto {
  @IsInt()
  @IsPositive()
  cattleId: number;

  @IsDateString()
  saleDate: string;

  @IsPositive()
  salePrice: number;

  @IsOptional()
  @IsString()
  buyerName?: string;

  @IsOptional()
  @IsBoolean()
  addToFirmAccount?: boolean;

  @IsOptional()
  @IsPositive()
  firmAccountAmount?: number;
}
```

---

### create-firm-deposit.dto.ts

```typescript
import { IsNumber, IsDateString, IsOptional, IsString, IsNotEmpty } from 'class-validator';

export class CreateFirmDepositDto {
  @IsNumber()
  @IsNotEmpty()
  amount: number;  // negative for withdrawal

  @IsDateString()
  date: string;

  @IsOptional()
  @IsString()
  note?: string;
}
```

---

## 8. Guards & Middleware

### JWT Auth Guard

All routes are protected by default. Apply `@UseGuards(JwtAuthGuard)` at the controller level or globally.

```typescript
// main.ts
app.useGlobalGuards(new JwtAuthGuard());
```

### Validation Pipe

```typescript
// main.ts
app.useGlobalPipes(new ValidationPipe({
  whitelist: true,         // strip unknown fields
  forbidNonWhitelisted: true,
  transform: true,         // auto-transform types (string → number, etc.)
}));
```

### Swagger Setup

```typescript
// main.ts
const config = new DocumentBuilder()
  .setTitle('Cattle Farm Manager API')
  .setDescription('REST API for the Cattle Farm Manager mobile app')
  .setVersion('1.0')
  .addBearerAuth()
  .build();
const document = SwaggerModule.createDocument(app, config);
SwaggerModule.setup('api/docs', app, document);
```

---

## 9. Environment Variables

Create a `.env` file at the project root:

```env
# App
PORT=3000
NODE_ENV=production

# Database
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=your_db_password
DB_NAME=cattle_farm

# JWT
JWT_SECRET=your_super_secret_jwt_key_here
JWT_EXPIRES_IN=86400   # seconds (24 hours)
```

### app.module.ts (config wiring)

```typescript
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (cfg: ConfigService) => ({
        type: 'postgres',
        host: cfg.get('DB_HOST'),
        port: +cfg.get('DB_PORT'),
        username: cfg.get('DB_USERNAME'),
        password: cfg.get('DB_PASSWORD'),
        database: cfg.get('DB_NAME'),
        autoLoadEntities: true,
        synchronize: cfg.get('NODE_ENV') !== 'production',
      }),
    }),
    OwnersModule,
    CattleModule,
    ExpensesModule,
    SalesModule,
    FirmDepositsModule,
    DashboardModule,
    ReportsModule,
    AuthModule,
  ],
})
export class AppModule {}
```

---

## 10. Error Handling

All error responses follow this shape:

```json
{
  "statusCode": 404,
  "message": "Owner with id 99 not found",
  "error": "Not Found"
}
```

### Common HTTP Status Codes

| Code | Meaning | When |
|---|---|---|
| `200` | OK | Successful GET, PATCH, DELETE |
| `201` | Created | Successful POST |
| `400` | Bad Request | Validation failure |
| `401` | Unauthorized | Missing or invalid JWT |
| `404` | Not Found | Resource does not exist |
| `409` | Conflict | Duplicate `cattleUniqueId`, cattle already sold |
| `500` | Internal Server Error | Unexpected server failure |

### Global Exception Filter

```typescript
// common/filters/http-exception.filter.ts
import { ExceptionFilter, Catch, ArgumentsHost,
         HttpException } from '@nestjs/common';

@Catch(HttpException)
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: HttpException, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse();
    const status = exception.getStatus();

    response.status(status).json({
      statusCode: status,
      message: exception.message,
      timestamp: new Date().toISOString(),
    });
  }
}
```

Apply globally in `main.ts`:
```typescript
app.useGlobalFilters(new HttpExceptionFilter());
```

---

*Generated for Cattle Farm Manager App — Flutter + NestJS backend*
