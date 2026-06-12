# Architecture & Design Decisions

## Architecture Overview

The application follows a lightweight layered architecture suitable for small-to-medium mobile applications.

Presentation Layer

↓

Provider Layer

↓

Service Layer

↓

Local Storage

## Folder Structure

lib/

├── models/

├── services/

├── screens/

├── widgets/

├── theme/

└── utils/

## Layer Responsibilities

### Models

Contains:

* Claim
* ExpenseItem
* ClaimStatus
* ExpenseType

Responsibilities:

* Business entities
* Validation rules
* Serialization

### Services

Contains:

* ClaimsService
* LocalClaimsService

Responsibilities:

* CRUD operations
* Workflow management
* Local persistence

### Provider

Contains:

* ClaimsProvider

Responsibilities:

* State management
* Search/filter logic
* UI notifications

### Screens

Contains:

* Startup Screen
* Claim List Screen
* Claim Form Screen
* Claim Detail Screen

Responsibilities:

* User interactions
* Navigation
* Data presentation

### Widgets

Contains reusable UI components:

* ClaimCard
* ExpenseCard
* StatusChip
* PrimaryButton
* SearchBarWidget

## State Management

Provider package is used.

Advantages:

* Lightweight
* Easy to understand
* Minimal boilerplate
* Suitable for assessment projects

## Persistence Strategy

SharedPreferences stores claim data as JSON.

Advantages:

* No backend dependency
* Simple setup
* Fast implementation

## Workflow Enforcement

Allowed transitions:

Draft → Submitted

Submitted → Approved

Submitted → Rejected

Rejected → Draft

All invalid transitions are prevented at the service layer.

## Validation Strategy

Validation is implemented in the Claim model.

Checks:

* Employee Name
* Purpose
* Expense Items
* Total Amount
* Travel Description
* Receipt Requirement

## UI Design Principles

* Mobile-first
* Large touch targets
* Card-based layout
* Minimal navigation depth
* Material 3 design language

## Scalability

The architecture can be extended to support:

* REST APIs
* Authentication
* Offline Sync
* Analytics
* Notifications
* Multi-Level Approval Workflows
