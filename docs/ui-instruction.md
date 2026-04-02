You are a senior mobile application architect and product designer.

Design a **complete blueprint for a mobile application called "Cattle Farm Manager"** that helps farm owners manage cattle purchases, expenses, and profit/loss tracking.

The application must be **simple, offline-first, and designed for farmers with minimal technical knowledge**.

The app must support **two languages: Bangla and English**, with the ability to switch language from settings.

All data must be stored **locally on the device** using a local database (SQLite / Hive / Realm).

---

APP PURPOSE

The app allows users to:

• Manage cattle owners
• Manage multiple cattle under each owner
• Record cattle purchase information
• Track expenses for each cattle
• Record cattle sales
• Automatically calculate total cost and profit/loss

---

DATA MODEL REQUIREMENTS

There must be four main entities:

1. Owners

* id
* name
* phone
* address
* created_at

2. Cattle

* id
* owner_id
* cattle_unique_id
* purchase_date
* purchase_price

3. Expenses

* id
* cattle_id (nullable - can be null for general farm expenses)
* date
* category (food, medicine, doctor, other)
* amount
* note

4. Sales

* id
* cattle_id
* sale_date
* sale_price
* buyer_name

---

BUSINESS LOGIC

Total Cost Formula:
Total Cost = Purchase Price + Total Expenses

Profit/Loss Formula:
Profit or Loss = Sale Price - Total Cost

---

FEATURE REQUIREMENTS

Owner Management
• Create owner
• Update owner
• Delete owner
• View owner's cattle

Cattle Management
• Add cattle under owner
• View cattle details
• Update cattle
• Track total cost

Expense Tracking
• Add expenses per cattle
• View expense history
• Edit/Delete expense
• Show total expense

Sales Management
• Sell cattle
• Store buyer information
• Calculate profit/loss automatically

Reports
• Total cattle
• Total expenses
• Total profit
• Profit/Loss per cattle

---

MULTI-LANGUAGE SUPPORT

The app must support **Bangla and English**.

Example UI labels:

English → Bangla

Owner → মালিক
Cattle → গবাদি পশু
Expense → খরচ
Purchase Price → কেনার দাম
Selling Price → বিক্রির দাম
Profit → লাভ
Loss → ক্ষতি
Add Owner → মালিক যোগ করুন
Add Cattle → পশু যোগ করুন

Language should be changeable from **Settings screen**.

---

UI SCREENS

Generate wireframes and UI descriptions for:

1. Splash Screen
2. Dashboard
3. Owner List
4. Add Owner
5. Owner Details
6. Cattle List
7. Add Cattle
8. Cattle Details
9. Add Expense
10. Expense History
11. Sell Cattle
12. Profit Report
13. Settings (Language Switch)

---

UI DESIGN STYLE

Mobile-first design

Primary Color: Green (#16A34A)

Design Guidelines:
• Clean layout
• Large buttons
• Card-based design
• Touch-friendly spacing
• Minimal text
• Icons for cattle, owners, money, reports

Navigation:
Bottom Navigation Bar with:

Home
Owners
Cattle
Reports

---

TECHNICAL ARCHITECTURE

Provide:

• Database schema
• App folder structure
• Local storage implementation
• State management strategy
• Data relationships
• Calculation logic
• Suggested development stack

---

OUTPUT FORMAT

Provide the response in structured sections:

1. App Overview
2. Feature Breakdown
3. Database Schema
4. UI Screen Flow
5. UI Design Guidelines
6. Architecture
7. Folder Structure
8. Development Roadmap

---

UI BEHAVIOUR

Add Expense Screen

Fields required:

• Owner (auto-selected based on current context)
• Cattle (optional dropdown - can be empty for general farm expenses)
• Category (dropdown: Food, Medicine, Doctor, Other)
• Amount (numeric input)
• Date (date picker)
• Note (text input, optional)

Behaviour:
• If adding expense from cattle details page, owner and cattle are pre-selected
• If adding from owner details page, owner is pre-selected, cattle is optional
• General farm expenses can be added without selecting any cattle

---

ADDITIONAL FEATURES (FUTURE ENHANCEMENTS)

1. Cattle Tag Number / Ear Tag
   • Add a unique tag/ear tag field for physical identification
   • Allow searching cattle by tag number
   • Display tag prominently on cattle details

2. Weight Tracking
   • Record multiple weight entries over time
   • Track weight gain/loss
   • Display weight history chart
   • Calculate average daily weight gain

3. Vaccination Record
   • Maintain vaccination schedule for each cattle
   • Record vaccine name, date, and next due date
   • Send reminders for upcoming vaccinations
   • Track vaccination history
