# Lab Team Portal & Todo REST API

> Υπηρεσιοστρεφές Λογισμικό 2026 | **Δημήτρης Συμεωνίδης** | **Π22165**

> Οδηγίες χρήσης: **[USER_MANUAL.md](USER_MANUAL.md)** | Τεχνική αναφορά: **documentation_p22165.pdf**

---

## Περιγραφή

Ενιαίο Ruby on Rails codebase που υλοποιεί και τα δύο θέματα: Web Portal (αναρτήσεις, αναζήτηση, επαφές, μηνύματα popup & ομαδικά, ειδοποιήσεις) και RESTful API για Todo lists (12 endpoints, Bearer Token auth, Swagger UI).

## Αρχιτεκτονική

Πρότυπο MVC. Δύο λογικά μέρη, κοινή βάση & Models:

- **Portal (`/portal/...`):** Rails Controllers + ERB Views. Auth μέσω Devise (sessions + Google OAuth2).
- **API (`/signup`, `/auth/...`, `/todos/...`):** JSON controllers (`Api::V1`). Auth μέσω Bearer Token (`has_secure_token`).

```
app/controllers/
├── posts_controller.rb           # Αναρτήσεις
├── contacts_controller.rb        # Επαφές
├── messages_controller.rb        # Μηνύματα
├── notifications_controller.rb   # Ειδοποιήσεις
└── api/v1/
    ├── auth_controller.rb        # Signup/Login/Logout
    ├── todos_controller.rb       # Todos CRUD
    └── todo_items_controller.rb  # Items CRUD

app/models/
├── user.rb, post.rb, contact.rb, message.rb
├── group_chat.rb, notification.rb
└── todo.rb, todo_item.rb
```

Βάση SQLite3. Βασικές σχέσεις: User → has_many posts, contacts, messages, todos. Todo → has_many todo_items (dependent: destroy). Contact → self-join. Message → sender/recipient ή group_chat.

---

## Stack

Ruby 3.2.10, Rails 7.1.5, SQLite3, Puma, Devise + omniauth-google-oauth2, RSpec (34 tests), Rswag (OpenAPI 3.0).

---

## API Endpoints

| Verb   | Endpoint                | Λειτουργία            |
| ------ | ----------------------- | --------------------- |
| POST   | `/signup`               | Εγγραφή & token       |
| POST   | `/auth/login`           | Login & token         |
| GET    | `/auth/logout`          | Logout                |
| GET    | `/todos`                | Λίστα todos & items   |
| POST   | `/todos`                | Δημιουργία todo       |
| GET    | `/todos/:id`            | Προβολή todo          |
| PUT    | `/todos/:id`            | Ενημέρωση todo        |
| DELETE | `/todos/:id`            | Διαγραφή todo & items |
| GET    | `/todos/:id/items/:iid` | Προβολή item          |
| POST   | `/todos/:id/items`      | Δημιουργία item       |
| PUT    | `/todos/:id/items/:iid` | Ενημέρωση item        |
| DELETE | `/todos/:id/items/:iid` | Διαγραφή item         |

## Scaffolding

```bash
# Portal Models
rails g scaffold Post title:string body:text category:string user:references
rails g scaffold Contact user:references contact_user:references
rails g scaffold Message sender:references recipient:references body:text
rails g scaffold Notification user:references message:references kind:string read_at:datetime

# Todo API Models
rails g scaffold Todo title:string description:text user:references
rails g scaffold TodoItem todo:references title:string done:boolean

# User & Auth
rails g devise:install
rails g devise User name:string student_id:string provider:string uid:string api_token:string
```
