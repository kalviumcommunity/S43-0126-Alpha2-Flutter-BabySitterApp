# SafeCare – Babysitter & Caregiver Discovery MVP

A Flutter + Firebase MVP that makes childcare discovery **safer and more transparent** by giving parents a trusted place to see caregiver profiles, ratings, background verification, and real-time availability.

## Features

- **Parent flow**: Browse caregivers with ratings, “Background verified” badge, and **real-time “Available now”** status. Tap a profile to see full details; status updates live.
- **Babysitter flow**: Create/edit profile (experience, skills, rate, availability), self-attest **background verified**, and toggle **“I’m available now”** so parents see updates in real time.
- **Trust signals**: Rating display (ready for future reviews), verification badge, and live availability via Firestore listeners.

## Firebase

- **Auth**: Email/password sign-up and login; role (parent / babysitter) stored in Firestore.
- **Firestore**:  
  - `users`: name, email, role.  
  - `babysitters`: name, experience, skills, pricePerHour, availability, ratingAverage, ratingCount, backgroundVerified, isAvailableNow, updatedAt.

Ensure Firestore rules allow authenticated read/write for `users` and `babysitters` as needed for your app.

## Run

```bash
flutter pub get
flutter run
```

Use **Role selection** → sign up as Parent or Babysitter → log in. Parents see the discovery list; babysitters set up their profile and toggle availability.
