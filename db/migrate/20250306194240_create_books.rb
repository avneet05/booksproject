class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string :title
      t.float :average_rating
      t.string :isbn
      t.string :isbn13
      t.string :language_code
      t.integer :num_pages
      t.date :publication_date
      t.string :publisher
      t.references :author, null: false, foreign_key: true

      t.timestamps
    end
  end
end
