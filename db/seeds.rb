require 'csv'
require 'faker'
require 'date'
require 'set'

# Wrap in a transaction for safety
ActiveRecord::Base.transaction do
    # Destroy dependent records first
    Review.destroy_all     # Reviews depend on Books and Users
    BookGenre.destroy_all  # BookGenres depend on Books and Genres
    
    # Then destroy the main records
    Book.destroy_all
    Author.destroy_all
    Genre.destroy_all
    User.destroy_all
  end
  
  puts "All records in Authors, Users, Books, Genres, BookGenres, and Reviews have been destroyed."


# ============
# 1. Seed Authors from CSV (unique_authors.csv)
# ============
csv_authors_path = Rails.root.join('db', 'seeds', '../../datasets/unique_authors.csv')
CSV.foreach(csv_authors_path, headers: true) do |row|
  Author.create!(
    name: row['name'],
    created_at: Time.now,
    updated_at: Time.now
  )
end
puts "Authors table populated with #{Author.count} authors."

# ============
# 2. Seed 300 Users using Faker
# ============
ActiveRecord::Base.transaction do
  300.times do
    User.create!(
      name: Faker::Name.name,
      email: Faker::Internet.unique.email,
      created_at: Time.now,
      updated_at: Time.now
    )
  end
end
puts "Users table populated with #{User.count} users."

# ============
# 3. Seed 300 Genres using Faker (ensuring unique names by appending an index)
# ============
100.times do |i|
  Genre.create!(
    name: "#{Faker::Book.genre} #{i + 1}",
    created_at: Time.now,
    updated_at: Time.now
  )
end
puts "Genres table populated with #{Genre.count} genres."

# ============
# 4. Seed Books from CSV (books1.csv) – only 300 unique books
# ============
csv_books_path = Rails.root.join('db', 'seeds', '../../datasets/books1.csv')
books_by_id = {}

CSV.foreach(csv_books_path, headers: true) do |row|
  book_id = row['bookID']
  # Save only the first row for each unique bookID.
  books_by_id[book_id] ||= row
  break if books_by_id.size >= 300
end

books_by_id.each do |book_id, row|
  # Use the 'authors' column to find or create an author (if not already seeded)
  author_name = row['authors']
  author = Author.find_or_create_by!(name: author_name)
  
  # Parse publication_date (assuming "m/d/yyyy" format, e.g., "9/16/2006")
  pub_date = Date.strptime(row['publication_date'], "%m/%d/%Y") rescue nil

  Book.create!(
    title: row['title'],
    average_rating: row['average_rating'].to_f,
    isbn: row['isbn'],
    isbn13: row['isbn13'],
    language_code: row['language_code'],
    num_pages: row['num_pages'].to_i,
    publication_date: pub_date,
    publisher: row['publisher'],
    author: author,
    created_at: Time.now,
    updated_at: Time.now
  )
end
puts "Books table populated with #{Book.count} books."

# ============
# 5. Seed BookGenres for each Book – assign 1 to 3 genres randomly to every book
# ============
books = Book.all
genres = Genre.all

books.each do |book|
  assigned_genres = genres.sample(rand(1..3))
  assigned_genres.each do |genre|
    BookGenre.create!(
      book: book,
      genre: genre,
      created_at: Time.now,
      updated_at: Time.now
    )
  end
end
puts "BookGenres table populated for all books."

# ============
# 6. Seed 300 Reviews using Faker (associating existing Users and Books)
# ============
# Reload users and books to ensure they are available
users = User.all
books = Book.all

if users.empty? || books.empty?
  puts "Please seed users and books before seeding reviews."
  exit
end

300.times do
  Review.create!(
    content: Faker::Lorem.paragraph,
    rating: rand(1..5),
    user: users.sample,
    book: books.sample,
    created_at: Time.now,
    updated_at: Time.now
  )
end
puts "Reviews table populated with #{Review.count} reviews."



# Path to your CSV file
csv_file_path = Rails.root.join('db', '../datasets/location.csv')

# Read CSV and update users
CSV.foreach(csv_file_path, headers: true).with_index do |row, index|
  user = User.find_by(id: index + 1)
  
  if user
    user.update(latitude: row['Latitude'].to_f, longitude: row['Longitude'].to_f)
    puts "Updated user #{user.id} with Latitude: #{row['Latitude']}, Longitude: #{row['Longitude']}"
  else
    puts "User with ID #{index + 1} not found."
  end
end

puts "✅ Seeding completed!"