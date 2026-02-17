class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:show]
  before_action :set_owned_post, only: [:edit, :update, :destroy]

 def index
    # Χρησιμοποιούμε το scope :search που φτιάξαμε στο model για την αναζήτηση
    @posts = Post.all.order(created_at: :desc).search(params[:q])
  end

  def show
  end

  def new
    @post = Post.new
  end

  def edit
  end

  def create
    @post = current_user.posts.new(post_params)
    
    # ποιος κάνει post την ώρα που τρέχει ο server
    puts "----[DEBUG] Δημιουργία Post από χρήστη: #{current_user.email} ----"

    if @post.save
      redirect_to @post, notice: "Η ανάρτηση δημιουργήθηκε επιτυχώς."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: "Η ανάρτηση ενημερώθηκε."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: "Η ανάρτηση διαγράφηκε."
  end

  private
    def set_post
      @post = Post.find(params[:id])
    end

    def set_owned_post
      @post = current_user.posts.find(params[:id])
    end

    # Strong parameters για προστασία από mass-assignment
    def post_params
      params.require(:post).permit(:title, :body, :category)
    end
end
