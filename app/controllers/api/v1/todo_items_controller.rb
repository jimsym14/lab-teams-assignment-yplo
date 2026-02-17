class Api::V1::TodoItemsController < Api::V1::BaseController
  before_action :set_todo
  before_action :set_item, only: [:show, :update, :destroy]

  def show
    render json: @item, status: :ok
  end

  def create
    item = @todo.todo_items.new(todo_item_params)

    if item.save
      render json: item, status: :created
    else
      render json: { errors: item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @item.update(todo_item_params)
      render json: @item, status: :ok
    else
      render json: { errors: @item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    render json: { message: "Ok" }, status: :ok
  end

  private

  def set_todo
    @todo = @current_api_user.todos.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Todo not found" }, status: :not_found
  end

  def set_item
    @item = @todo.todo_items.find(params[:iid])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Todo item not found" }, status: :not_found
  end

  def todo_item_params
    params.permit(:title, :done)
  end
end
