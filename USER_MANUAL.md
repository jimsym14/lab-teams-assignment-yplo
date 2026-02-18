# Εγχειρίδιο Χρήσης (User Manual)

**Δημήτρης Συμεωνίδης** | **Π22165**

> Τεχνική αναφορά: **documentation_p22165.pdf** | Γενικές πληροφορίες: **[README.md](README.md)**

---

## 1. Εγκατάσταση

```bash
bundle install              # Εγκατάσταση gems
ruby bin/rails db:setup     # Δημιουργία βάσης + demo δεδομένα (seeds)
ruby bin/rails s            # Εκκίνηση server
```

Η εφαρμογή ανοίγει στο **http://localhost:3000**

Demo login: `student1@unipi.gr` / `password123` (ή `student2@unipi.gr` για δοκιμή chat).

### Υποστηρίζεται και Google OAuth login.

Για να λειτουργήσει, δημιουργήστε ένα `.env` αρχείο στο root του project με:

```
GOOGLE_CLIENT_ID=your_client_id
GOOGLE_CLIENT_SECRET=your_client_secret
```

Τα κλειδιά δημιουργούνται από το [Google Cloud Console](https://console.cloud.google.com/) (APIs & Services → Credentials → OAuth 2.0 Client ID). Χωρίς αυτά, η εφαρμογή λειτουργεί κανονικά με email/password.

---

## 2. Portal (Θέμα 1)

Μετά το login πλοηγηθείτε μεσω του sidebar σε :

- Αναρτήσεις (δημιουργία/αναζήτηση ανά τίτλο ή κατηγορία)
- Επαφές (προσθήκη μέσω email)
- Μηνύματα (προσωπικά popup chat & ομαδικά)
- Ειδοποιήσεις (αυτόματες για νέα μηνύματα/επαφές)

---

## 3. Swagger UI (Θέμα 2)

Διαδραστική τεκμηρίωση & δοκιμή API: **http://localhost:3000/api-docs**

Επειδή το API είναι προστατευμένο, ακολουθήστε αυτά τα βήματα για να το δοκιμάσετε:

1.  **Login & Λήψη Token:**
    - Στο Swagger, ανοίξτε το endpoint `POST /auth/login`.
    - Πατήστε **"Try it out"**.
    - Στο JSON body βάλτε: `{"email": "student1@unipi.gr", "password": "password123"}`.
    - Πατήστε **Execute**.
    - Από την απάντηση (Response body), αντιγράψτε το `token` (χωρίς τα εισαγωγικά).

2.  **Αυθεντικοποίηση (Authorize):**
    - Κυλήστε στην κορυφή της σελίδας και πατήστε το κουμπί **Authorize** (με το λουκέτο).
    - Στο πεδίο "Value", γράψτε: `Bearer <ΤΟ_TOKEN_ΣΑΣ>` (π.χ. `Bearer 2983d7s...`).
    - Πατήστε **Authorize** και μετά **Close**.

3.  **Δοκιμή Endpoints:**
    - Τώρα μπορείτε να καλέσετε οποιοδήποτε endpoint (π.χ. `GET /todos`), να πατήσετε "Execute" και να δείτε τα αποτελέσματα.

---

## 4. HTTPie

```bash
# Login
http POST :3000/auth/login email=student1@unipi.gr password=password123

# CRUD Todos (αντικαταστήστε <TOKEN> με το token από το login)
http GET :3000/todos "Authorization: Bearer <TOKEN>"
http POST :3000/todos title="Νέα εργασία" "Authorization: Bearer <TOKEN>"
http DELETE :3000/todos/1 "Authorization: Bearer <TOKEN>"

# CRUD Items
http POST :3000/todos/1/items title="Βήμα 1" done:=false "Authorization: Bearer <TOKEN>"
http PUT :3000/todos/1/items/1 done:=true "Authorization: Bearer <TOKEN>"
```

---

## 5. Tests

```bash
bundle exec rspec spec/requests/api
```
