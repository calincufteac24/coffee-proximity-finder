# Coffee Addicts — Backend Implementation Plan

## Context

We are building a GraphQL API backend for "Coffee Addicts", link to more explanations BC: https://3.basecamp.com/4217551/buckets/46221107/messages/9606441258
---

## All 11 Tasks discussed in the meeting

### 1. Update Schema with new fields
- Added `address` (string) and `schedule` (string) to `coffee_shops`
- Updated `CoffeeShop` model with length validations and constants

### 2. Add migration to add the columns
- Migration `20260223152300_add_address_and_opening_hours_to_coffee_shops`
- Seeds with 10 coffee shops, tests for new fields

---

### 3. Add GraphQL to the project
- Add `graphql` gem to Gemfile, `bundle install`
- Run `bin/rails generate graphql:install` to scaffold base types, schema, controller, and route
- Clean up generated boilerplate (remove unused mutation root if empty)
- Define error handling pattern in schema:
  - **Queries**: use `GraphQL::ExecutionError` for not found / invalid input (top-level `errors` array)
  - **Mutations**: return `{ coffee_shop: ..., errors: [...] }` payload — validation errors as structured field, not top-level errors

---

### 4. Create CoffeeShop Types
- Create `app/graphql/types/coffee_shop_type.rb` exposing: `id`, `name`, `latitude`, `longitude`, `address`, `schedule`
- Create `app/graphql/types/coffee_shop_result_type.rb` wrapping: `coffee_shop` (CoffeeShopType) + `distance` (Float)
- Highlighting is presentation logic — the client highlights the first 3 results based on index position

**Key files:**
- `app/graphql/types/coffee_shop_type.rb`
- `app/graphql/types/coffee_shop_result_type.rb`

---

### 5. Return the closest 3 coffee shops (highlighted)
- Create `app/graphql/resolvers/nearby_coffee_shops_resolver.rb`
- Reuse existing `CoffeeShops::Finder` service with the provided limit
- Results are ordered by distance ASC — the client highlights the first 3 based on position
- Wire resolver into `query_type.rb` as `nearbyCoffeeShops` field
- Validate coordinates using existing `CoordinateValidator`

**Reuse:** `app/services/coffee_shops/finder.rb`, `app/validators/coordinate_validator.rb`

**Tests:** `test/graphql/resolvers/nearby_coffee_shops_resolver_test.rb`
- Valid coordinates return results ordered by distance
- Invalid coordinates return GraphQL errors

---

### 6. Search Query using the name
- Add `name` (String, optional) argument to `nearbyCoffeeShops` resolver
- When provided, filter `scope` with `CoffeeShop.where("name ILIKE ?", "%#{name}%")` before passing to Finder
- This keeps Finder untouched (Open/Closed principle) — filtering happens at the scope level

**Tests:** `test/graphql/resolvers/nearby_coffee_shops_resolver_test.rb` (extend)
- Name filter returns matching shops only
- Name filter is case-insensitive
- Empty name returns all shops

---

### 7. Return the CoffeeShops details
- Add `coffeeShop(id: ID!)` query to `query_type.rb`
- Create `app/graphql/resolvers/coffee_shop_resolver.rb`
- Returns single `CoffeeShopType` by ID
- Raises `GraphQL::ExecutionError` on not found

**Tests:** `test/graphql/resolvers/coffee_shop_resolver_test.rb`
- Valid ID returns shop with all fields
- Invalid ID returns error

---

### 8. CreateCoffeeShop mutation with input validation
- Create `app/graphql/mutations/create_coffee_shop.rb`
- Input: `name` (String, required), `latitude` (Float, required), `longitude` (Float, required), `address` (String, optional), `schedule` (String, optional)
- Validates via model validations, returns errors on failure
- Returns created `CoffeeShopType` on success

**Tests:** `test/graphql/mutations/create_coffee_shop_test.rb`
- Valid input creates shop and returns it
- Missing required fields return validation errors
- Invalid coordinates return errors

---

### 9. UpdateCoffeeShop mutation with partial updates
- Create `app/graphql/mutations/update_coffee_shop.rb`
- Input: `id` (ID, required) + all fields optional (partial update)
- Only updates provided fields (skip nil arguments)
- Returns updated `CoffeeShopType` or errors

**Tests:** `test/graphql/mutations/update_coffee_shop_test.rb`
- Partial update changes only specified fields
- Invalid ID returns not found error
- Validation errors returned properly

---

### 10. DeleteCoffeeShop mutation
- Create `app/graphql/mutations/delete_coffee_shop.rb`
- Input: `id` (ID, required)
- Returns deleted `CoffeeShopType` (so client can confirm what was deleted)
- Raises error if not found

**Tests:** `test/graphql/mutations/delete_coffee_shop_test.rb`
- Valid ID deletes and returns shop
- Invalid ID returns error

---

### 11. Make the endpoints private and non-accessible to public ⏳ _Pending discussion_

> **Status:** Implementation approach not yet decided. To be discussed in a future meeting.

**Options on the table:**
- API key authentication (`Authorization: Bearer <token>`)
- JWT-based authentication
- Public queries (search) vs private mutations (CRUD) split

**Open questions:**
- Should search queries be public or require auth?
- Single API key or per-user tokens?
- Which auth strategy fits the client architecture?



---

## File Structure (new files)

```
app/graphql/
├── coffee_proximity_finder_schema.rb
├── types/
│   ├── base_*.rb (generated)
│   ├── query_type.rb
│   ├── mutation_type.rb
│   ├── coffee_shop_type.rb
│   └── coffee_shop_result_type.rb
├── resolvers/
│   ├── nearby_coffee_shops_resolver.rb
│   └── coffee_shop_resolver.rb
└── mutations/
    ├── base_mutation.rb (generated)
    ├── create_coffee_shop.rb
    ├── update_coffee_shop.rb
    └── delete_coffee_shop.rb

test/graphql/
├── resolvers/
│   ├── nearby_coffee_shops_resolver_test.rb
│   └── coffee_shop_resolver_test.rb
└── mutations/
    ├── create_coffee_shop_test.rb
    ├── update_coffee_shop_test.rb
    └── delete_coffee_shop_test.rb
```

## Verification

After each task:
1. `bin/rails test` — all tests pass
2. `bin/rubocop` — no style violations
3. `bin/brakeman` — no security warnings

Final end-to-end: test all queries and mutations via GraphQL playground or curl against `POST /graphql`.
