class Api::V1::TodosController < Api::V1::BaseController
  before_action :set_todo, only: [:show, :update, :destroy]

  def index
    todos = @current_api_user.todos.order(created_at: :desc)
    render json: todos.as_json(include: :todo_items), status: :ok
  end

  def show
    render json: @todo.as_json(include: :todo_items), status: :ok
  end

  def create
    todo = @current_api_user.todos.new(todo_params)

    if todo.save
      render json: todo.as_json(include: :todo_items), status: :created
    else
      render json: { errors: todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @todo.update(todo_params)
      render json: @todo.as_json(include: :todo_items), status: :ok
    else
      render json: { errors: @todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @todo.destroy
    render json: { message: "Ok" }, status: :ok
  end

  private

  def set_todo
    @todo = @current_api_user.todos.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Todo not found" }, status: :not_found
  end

  def todo_params
    params.permit(:title, :description)
  end
end
