# REX Expense Reimbursement Mobile App

A Flutter mobile application for managing employee expense reimbursement claims.

## Features

### Employee

* Create Expense Claims
* Edit Draft Claims
* Submit Claims
* View Claim Status
* Attach Receipts from Camera/Gallery

### Manager

* View Submitted Claims
* Approve Claims
* Reject Claims with Comments

### Business Rules

* At least one expense item required
* Maximum claim amount: ₹50,000
* Travel expenses require description
* Receipt required for expenses above ₹5,000
* Workflow validation enforced

## Tech Stack

* Flutter
* Provider
* SharedPreferences
* Image Picker
* UUID
* Material 3

## Project Structure

lib/

├── models/

├── services/

├── ui/
    -screens/
    -widgets/

└── utils/

## Installation

### Clone Repository

git clone <repository-url>

### Install Dependencies

flutter pub get

### Run Application

flutter run

## Supported Platforms

* Android
* iOS

## Storage

Claims are stored locally using SharedPreferences.

## Assumptions

* Authentication is not required.
* Role selection is handled via startup screen.
* Local storage is used instead of backend APIs.
* Receipt upload is simulated using device image picker.

## Workflow

Draft → Submitted

Submitted → Approved

Submitted → Rejected

Rejected → Draft

Invalid transitions are blocked.

## Future Enhancements

* Backend Integration
* User Authentication
* Push Notifications
* Offline Sync
* Multi-Level Approval
* Expense Analytics Dashboard
