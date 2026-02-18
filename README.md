# Lab Team Portal & Todo REST API

> Εργασία στο μάθημα Υπηρεσιοστρεφές Λογισμικό 2026  
> **Φοιτητής:** Δημήτρης Συμεωνίδης | **ΑΜ:** Π22165

## Περιγραφή

Η παρούσα εφαρμογή υλοποιεί τα δύο ζητούμενα της εργασίας σε ενιαίο codebase:

1. **Web Portal:**
2. **REST API:** Πλήρης διαχείριση Todo lists

Για αναλυτικές οδηγίες χρήσης, δείτε το αρχείο: **[USER_MANUAL.md](USER_MANUAL.md)**

---

## Technical Stack (Toolset)

Η εφαρμογή αναπτύχθηκε με τα εξής εργαλεία και βιβλιοθήκες:

- **Framework:** Ruby on Rails 7.x
- **Language:** Ruby 3.x
- **Database:** SQLite3 (Default configuration)
- **Testing:** RSpec (Integration & Request specs)
- **Documentation:** Rswag (OpenAPI 3.0 / Swagger UI)
- **Authentication:**
  - _Web:_ Devise (Session based + Google OAuth2)
  - _API:_ Custom Bearer Token strategy

### Βασικά Gems

```ruby
gem 'devise'                  # Αυθεντικοποίηση χρηστών
gem 'omniauth-google-oauth2'  # Google Login
gem 'rswag-api'               # API Documentation endpoints
gem 'rswag-ui'                # Swagger UI interface
gem 'rspec-rails'             # Testing framework
```

---

## Setup & Configuration

### 1. Εγκατάσταση Εξαρτήσεων

```bash
bundle install
```

### 2. Ρύθμιση Βάσης Δεδομένων

Έχουν δημιουργηθεί κατάλληλα seeds ώστε η βάση να αρχικοποιείται με χρήστες, posts και todos για άμεση επίδειξη.

```bash
# Δημιουργία, Migration και Seeding με μία εντολή:
bin/rails db:setup
```

### 3. Google OAuth (Προαιρετικό)

Η εφαρμογή λειτουργεί κανονικά με email/password. Για να λειτουργήσει το Google Login, πρέπει να οριστούν στο περιβάλλον (ή σε αρχείο `.env`) τα:

- `GOOGLE_CLIENT_ID`
- `GOOGLE_CLIENT_SECRET`

---

## Αρχιτεκτονική & Endpoints

### Δομή Project

Η εφαρμογή ακολουθεί το MVC πρότυπο με διαχωρισμό namespaces:

- **Portal (`/`):** Χρησιμοποιεί τυπικούς Rails Controllers και Views (erb).
- **API (`/api/v1`):** Χρησιμοποιεί `Api::V1::BaseController` και επιστρέφει αποκλειστικά JSON.

### Υλοποιημένα API Endpoints

Καλύπτονται πλήρως οι απαιτήσεις του 2ου θέματος:

| Verb   | Endpoint           | Περιγραφή                   |
| ------ | ------------------ | --------------------------- |
| POST   | `/signup`          | Εγγραφή χρήστη & λήψη token |
| POST   | `/auth/login`      | Login & λήψη token          |
| GET    | `/auth/logout`     | Ακύρωση token               |
| GET    | `/todos`           | Λίστα όλων των Todos        |
| POST   | `/todos`           | Δημιουργία νέου Todo        |
| GET    | `/todos/:id`       | Λεπτομέρειες Todo           |
| PUT    | `/todos/:id`       | Ενημέρωση Todo              |
| DELETE | `/todos/:id`       | Διαγραφή Todo               |
| POST   | `/todos/:id/items` | Προσθήκη Item σε Todo       |

...(Πλήρης λίστα στο Swagger UI)

---

## Testing & Documentation

### Εκτέλεση Tests

Η εφαρμογή καλύπτεται από Integration Tests για το API, τα οποία εξασφαλίζουν την ορθότητα των απαντήσεων (Status 200, 201, 401, 422).

```bash
bundle exec rspec spec/requests/api
```

### Swagger UI

Με βάση τα RSpec tests, παράγεται αυτόματα η τεκμηρίωση OpenAPI.  
Μπορείτε να δείτε και να δοκιμάσετε τα endpoints στο:  
http://localhost:3000/api-docs

---

## Development History (Scaffolding)

Για την κατασκευή της αρχιτεκτονικής της εφαρμογής και της βάσης δεδομένων, χρησιμοποιήθηκαν οι παρακάτω εντολές, ακολουθώντας τα πρότυπα του Rails:

```bash
# 1. Βασικά Μοντέλα Portal
rails g scaffold Post title:string body:text category:string user:references
rails g scaffold Contact user:references contact_user:references
rails g scaffold Message sender:references recipient:references body:text
rails g scaffold Notification user:references message:references kind:string read_at:datetime

# 2. Μοντέλα Todo API (Θέμα 2)
rails g scaffold Todo title:string description:text user:references
rails g scaffold TodoItem todo:references title:string done:boolean

# 3. User & Auth Setup
rails g devise:install
rails g devise User name:string student_id:string provider:string uid:string api_token:string
```
