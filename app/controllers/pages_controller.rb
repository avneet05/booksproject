class PagesController < ApplicationController
  def landing
  end

  def books
    @books = Book.includes(:author).page(params[:page]).per(50)
    
    # Only select authors whose id exists in the books table
    @authors = Author
                 .joins(:books)
                 .select(:id, :name)
                 .distinct
                 .limit(50)
  
    # Search by book title
    if params[:search].present?
      @books = @books.where("books.title ILIKE ?", "%#{params[:search]}%")
    end
  
    # Filter by author using author_id
    if params[:author_id].present?
      @books = @books.where(author_id: params[:author_id])
    end
  end
  

  def show
    @book = Book.includes(:author, reviews: :user, book_genres: :genre).find(params[:id])
  end

  # Display paginated users
  def users
    @users = User.page(params[:page]).per(50)
  end

  # Display individual user details
  def user_show
    @user = User.find(params[:id])
  end
end
