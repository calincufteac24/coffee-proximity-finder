# ☕ Coffee Proximity Finder

> *"Any fool can write code that a computer can understand. Good programmers write code that humans can understand."*
> — *Martin Fowler (but Uncle Bob nodded approvingly)*


A REST API that finds the *3 closest coffee shops* to any coordinates on Earth. Because life's too short for bad coffee *and* bad code.


🚀 **Live Demo:** [https://coffee-proximity-finder.onrender.com/](https://coffee-proximity-finder.onrender.com/)
*Warning: Hosted on a free tier. If it takes 30 seconds to load, the server is just having its own morning coffee. Be patient, it's relatable.*

Built with *Rails 8*, *PostgreSQL*, and with a *Clean Code* I hope, but if I look again I would probably say its horror.


---

## 🧠 The Problem

You are somewhere and you have the biggest RELEASE in your life. You need coffee. You have GPS coordinates but no idea where the nearest espresso is and as a programmer you know that you need to write a script to find the nearest espresso.


This API ingests coffee shops from a CSV, stores them in PostgreSQL, and answers one question:

> *"Given where I am, where's the closest coffee?"*


*Sure, the example CSV has 6 coffee shops. Six. We could've hardcoded them in a hash and gone home early. But if you're going to build something, build it like 100,000 rows are coming because one day they might, and you don't want to be the one explaining why the server caught fire on a Tuesday. I felt this on my skin many times so no thank you.*


---

## 🏗 Architecture


```text
app/
├── controllers/
│   └── api/v1/
│       ├── base_controller.rb          # JSON:API content type + error rendering
│       └── coffee_shops_controller.rb   # Thin. Delegates. Doesn't think.
│
├── models/
│   └── coffee_shop.rb                  # AR model + SHA256 external_id generation
│
├── serializers/
│   └── coffee_shop_serializer.rb       # JSON:API spec formatting
│
├── services/
│   ├── coffee_shops/
│   │   ├── finder.rb                   # SQL-powered proximity search
│   │   └── synchronizer.rb             # CSV → DB batch upsert pipeline
│   │
│   └── csv/
│       ├── fetcher.rb                  # HTTP client with dependency injection
│       └── parser.rb                   # Line-by-line CSV parsing + validation
│
├── validators/
│   ├── coordinate_validator.rb         # Lat/lng range + format rules
│   └── csv_row_validator.rb            # Row structure + name sanitization
│
└── jobs/
    └── coffee_shop_sync_job.rb         # Background sync via Solid Queue
```


Every class does *one thing*. If a class had a LinkedIn bio, it would be one sentence:

| Class | LinkedIn Bio |
| :--- | :--- |
| `CoffeeShops::Finder` | *I find the closest coffee shops. That's it.* |
| `CoffeeShops::Synchronizer` | *I sync CSV data to the database in batches.* |
| `Csv::Fetcher` | *I fetch URLs. I don't parse. I don't judge.* |
| `Csv::Parser` | *I turn messy CSV lines into clean hashes.* |
| `CoordinateValidator` | *Is 47.6 a valid latitude? Yes. Is 999? No.* |
| `CsvRowValidator` | *Three columns? ✅ Script injection? 🚫* |
| `CoffeeShopSerializer` | *I make JSON look pretty. JSON:API spec.* |


---

### Data Integrity — Trust Nobody

Validation happens at *three layers*, because data is like coffee, you filter it multiple times:


```text
Layer 1: Csv::Parser + CsvRowValidator     → Rejects malformed rows
Layer 2: CoordinateValidator                → Rejects impossible coordinates
Layer 3: PostgreSQL constraints + indexes   → The final gatekeeper
```


*We even caught a real bug during testing: CSV.parse_line(",47.6,-122.4") returns [nil, "47.6", "-122.4"], and calling .strip on nil crashed. The test suite found it. Uncle Bob smiled somewhere.*


---

## 📡 API Reference

### `GET /api/v1/coffee_shops`

Find the 3 closest coffee shops to a point.

| Parameter | Type | Description |
| :--- | :--- | :--- |
| `x` | `string` | Latitude (-90 to 90) |
| `y` | `string` | Longitude (-180 to 180) |


#### Success Response (200)

```json
{
  "data": [
    {
      "id": "42",
      "type": "coffee_shop",
      "attributes": {
        "name": "Starbucks Pike Place",
        "latitude": "47.6097",
        "longitude": "-122.3425",
        "distance": 0.4218
      }
    }
  ],
  "meta": {
    "origin": { "latitude": 47.6, "longitude": -122.4 },
    "total_count": 3,
    "last_synced_at": "2026-02-14T17:00:00Z"
  }
}
```


#### Error Response (422)

```json
{
  "errors": [
    {
      "status": "422",
      "title": "Invalid coordinates",
      "detail": "Latitude must be between -90 and 90. Longitude must be between -180 and 180."
    }
  ]
}
```


*Fully compliant with the JSON:API Specification. Yes, we read the spec. All of it. No, we don't want to talk about it. I promise.*


---

## 🧪 Testing

```bash
bin/rails test
```


```text
129 tests, 195 assertions, 0 failures, 0 errors, 0 skips
```


### Test Coverage

| Layer | File | Tests | What It Breaks |
| :--- | :--- | :--- | :--- |
| Validators | `coordinate_validator_test.rb` | 22 | Boundaries, letters, nil, empty |
| Validators | `csv_row_validator_test.rb` | 11 | Column count, XSS, unicode |
| Services | `csv/parser_test.rb` | 14 | Malformed rows, quoted commas |
| Services | `csv/fetcher_test.rb` | 3 | HTTP 200/500/404 |
| Services | `coffee_shops/finder_test.rb` | 12 | Sort order, zero distance, limit |
| Services | `coffee_shops/synchronizer_test.rb` | 9 | Upsert, fetch errors, batches |
| Integration | `coffee_shops_controller_test.rb` | 20 | JSON:API, SQL injection attempts |
| Model | `coffee_shop_test.rb` | 18 | Validations, external_id |


*We tested SQL injection. The API survived. The intern who tried it didn't. (Just kidding. There's no intern. It's just us and the test suite at 2 AM.)*


---

## 🌐 Web Interface (optional)

The app includes a *modern dark-themed UI* built with Tailwind CSS 4 and Stimulus:

- 🔍 Coordinate search with instant results
- 📍 Browser geolocation ("Use My Location")
- 🥇🥈🥉 Medal-ranked results with distance
- ✨ Micro-animations and glassmorphism cards
- 📱 Fully responsive


---

## 🏛 Tech Stack

| Component | Technology | Why |
| :--- | :--- | :--- |
| Framework | Rails 8.1 | Convention over configuration. |
| Database | PostgreSQL | Does the distance math in C. |
| Background Jobs | Solid Queue | Uses the existing PostgreSQL. |
| Serialization | jsonapi-serializer | JSON:API spec without the headache. |
| CSS | Tailwind 4 | Utility-first. |
| JS | Stimulus + Turbo | Just enough JavaScript. |


---

## 🚢 Deployment (Render)

The app is configured for one-click deployment on Render:


```bash
# Build command
bundle install && bin/rails assets:precompile && bin/rails db:migrate && bin/rails runner 'CoffeeShops::Synchronizer.new.call'

# Start command
bin/rails server -b 0.0.0.0 -p $PORT
```


Required environment variables:

| Variable | Purpose |
| :--- | :--- |
| `DATABASE_URL` | PostgreSQL connection string |
| `RAILS_ENV` | `production` |
| `RAILS_MASTER_KEY` | Decrypts credentials |
| `CSV_SOURCE_URL` | URL of the coffee shops CSV |
| `SOLID_QUEUE_IN_PUMA` | `true` — runs jobs inside Puma |


---

Built with ❤️ by **Calin Cufteac**
