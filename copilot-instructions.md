# 🌳 HealthON AI Development Instructions

Last Update : 2026-07-01

---

# Project Overview

HealthON is a Flutter-based Health Challenge Platform.

The first challenge is the "100K Walking Challenge".

The platform is designed to support multiple health challenges in the future.

Examples:

- Walking
- Smoking Cessation
- Investment Saving Challenge
- Volunteer Activity
- Health Checkup
- Sleep Challenge

Always write code considering future expansion.

Never hardcode challenge-specific logic.

---

# Core Philosophy

HealthON is NOT a step counter.

HealthON builds healthy habits.

Competition is secondary.

Community and sustainability are the primary goals.

Every UI and feature should encourage users.

Avoid negative wording.

---

# Target Users

Primary Users

- 50~70 years old
- Members of Bucheon Medical Welfare Social Cooperative

Secondary Users

- General Citizens

Accessibility is extremely important.

Large fonts.

Simple layouts.

Minimal interactions.

---

# Technology Stack

Flutter (Latest Stable)

Riverpod

GoRouter

Supabase

Health Connect (Android)

Apple HealthKit (iOS)

GitHub Actions

---

# Architecture

Follow Feature First Architecture.

Example

lib/

features/

core/

shared/

widgets/

services/

models/

repositories/

No business logic inside UI.

Business logic belongs to services.

Database access belongs to repositories.

---

# State Management

Always use Riverpod.

Do not use Provider.

Avoid StatefulWidget unless absolutely necessary.

Prefer ConsumerWidget.

---

# Routing

Use GoRouter.

Keep routing centralized.

Avoid Navigator.push directly.

---

# UI Design Rules

Use Material 3.

Follow DESIGN_SYSTEM.md.

Rounded cards.

Rounded buttons.

Soft shadows.

Large touch areas.

Minimum font size:

16

Button height:

52

Never use tiny buttons.

---

# Theme

Primary Color

Forest Green

Support Light Theme first.

Dark Theme later.

---

# Naming

Classes

PascalCase

Variables

camelCase

Files

snake_case.dart

Constants

lowerCamelCase

---

# Folder Structure

Each feature should contain

models/

repositories/

services/

providers/

screens/

widgets/

Example

features/walking/

features/challenge/

features/community/

features/profile/

---

# Database

Never call Supabase directly from UI.

Use Repository Layer.

Repositories return Models.

---

# Error Handling

Always use try/catch.

Show friendly messages.

Never expose raw exceptions.

Log unexpected errors.

---

# Loading

Every async screen must have

Loading

Empty

Error

Success

states.

---

# Accessibility

Support dynamic font scaling.

Readable colors.

Large buttons.

High contrast.

---

# Animations

Fast

Simple

Meaningful

Avoid excessive animation.

---

# Performance

Avoid rebuilding unnecessary widgets.

Prefer const constructors.

Use pagination.

Lazy loading.

---

# Security

Never store secrets.

Use environment variables.

Never trust client validation.

Follow Supabase RLS.

---

# Localization

Prepare for Korean first.

Support multilingual architecture.

No hardcoded strings.

---

# Comments

Write meaningful comments.

Explain WHY.

Avoid obvious comments.

---

# Testing

Write unit tests for services.

Widget tests for important screens.

Repository tests when possible.

---

# Git Commit Style

feat:

fix:

refactor:

docs:

style:

test:

chore:

Example

feat: add walking dashboard

fix: health sync issue

---

# Pull Request

Every PR should include

Purpose

Screenshots

Testing Result

Checklist

---

# AI Coding Rules

Before writing new code

Search existing code.

Reuse components.

Avoid duplicate widgets.

Follow existing architecture.

Always think about future multi-challenge support.

Never create challenge-specific implementations if they can be generalized.

---

# HealthON Design Principles

Encourage users.

Celebrate progress.

Reduce friction.

Make participation enjoyable.

Never shame users.

Every screen should answer

"How can this help users build healthier habits?"

---

# Final Principle

HealthON is not only an app.

It is a platform that helps communities become healthier together.

Every line of code should support that vision.
