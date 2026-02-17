puts "--- Αρχικοποίηση Δεδομένων (Seeds) ---"

User.destroy_all
Post.destroy_all

puts "1. Δημιουργία Χρηστών"
student1 = User.create!(
  email: 'student1@unipi.gr',
  password: 'password123',
  password_confirmation: 'password123',
  name: 'Γιώργος Φοιτητής'
)

student2 = User.create!(
  email: 'student2@unipi.gr',
  password: 'password123',
  password_confirmation: 'password123',
  name: 'Μαρία Παπαδοπούλου'
)

puts "2. Δημιουργία Posts"
student1.posts.create!(
  title: 'Ομάδα για Υπηρεσιοστρεφές Λογισμικό',
  category: 'Μαθήματα',
  body: 'Ψάχνω άτομο για την τελική εργασία στο ΥΠΛΟ. Όποιος ενδιαφέρεται ας μου στείλει μήνυμα.'
)

student2.posts.create!(
  title: 'Σημειώσεις Βάσεις Δεδομένων',
  category: 'Σημειώσεις',
  body: 'Έχει κανείς σημειώσεις από το 3ο εξάμηνο στις Βάσεις; Ευχαριστώ!'
)

puts "3. Δημιουργία Todo"
todo = student1.todos.create!(
  title: 'Παράδοση Εργασίας ΥΠΛΟ',
  description: 'Υλοποίηση API και Portal σε Ruby on Rails'
)

todo.todo_items.create!(title: 'Ολοκλήρωση Swagger Docs', done: true)
todo.todo_items.create!(title: 'Υλοποίηση Auth με API Token', done: true)
todo.todo_items.create!(title: 'Τελικός έλεγχος με Postman', done: false)

puts "--- Η Βάση Δεδομένων δημιουργήθηκε επιτυχώς! ---"
puts "Χρησιμοποιήστε το email 'student1@unipi.gr' και κωδικό 'password123' για login."