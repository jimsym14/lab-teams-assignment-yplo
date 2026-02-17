require "rails_helper"

RSpec.describe "API Todos", type: :request do
  let!(:user) { User.create!(email: "ergasia_final@test.com", password: "Password123!", name: "Todo User") }
  let!(:token) do
    user.regenerate_api_token
    user.api_token
  end
  let(:auth_headers) { { "Authorization" => "Bearer #{token}" } }

  describe "GET /todos" do
    it "returns todos with nested items" do
      todo = user.todos.create!(title: "Μάθημα ΥΠΛΟ", description: "έτοιμο")
      todo.todo_items.create!(title: "γράψε openapi")

      get "/todos", headers: auth_headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.first["id"]).to eq(todo.id)
      expect(body.first["todo_items"].first["title"]).to eq("γράψε openapi")
    end
  end

  describe "POST /todos" do
    it "creates a new todo" do
      post "/todos",
           params: { title: "Νέο todo", description: "περιγραφή" },
           headers: auth_headers

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["title"]).to eq("Νέο todo")
      expect(user.todos.count).to eq(1)
    end

    it "returns 422 with invalid payload" do
      post "/todos", params: { title: "" }, headers: auth_headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to be_present
    end
  end

  describe "GET /todos/:id" do
    it "returns a specific todo" do
      todo = user.todos.create!(title: "Specific", description: "abc")

      get "/todos/#{todo.id}", headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["id"]).to eq(todo.id)
    end
  end

  describe "PUT /todos/:id" do
    it "updates todo" do
      todo = user.todos.create!(title: "Before", description: "old")

      put "/todos/#{todo.id}",
          params: { title: "After", description: "new" },
          headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["title"]).to eq("After")
      expect(todo.reload.description).to eq("new")
    end

    it "returns 422 on invalid update" do
      todo = user.todos.create!(title: "Before", description: "old")

      put "/todos/#{todo.id}", params: { title: "" }, headers: auth_headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to be_present
    end
  end

  describe "DELETE /todos/:id" do
    it "deletes todo and its items" do
      todo = user.todos.create!(title: "Delete me")
      todo.todo_items.create!(title: "nested")

      delete "/todos/#{todo.id}", headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("Ok")
      expect(Todo.where(id: todo.id)).to be_empty
      expect(TodoItem.where(todo_id: todo.id)).to be_empty
    end
  end

  describe "GET /todos/:id/items/:iid" do
    it "returns a todo item" do
      todo = user.todos.create!(title: "εργασία")
      item = todo.todo_items.create!(title: "item")

      get "/todos/#{todo.id}/items/#{item.id}", headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["id"]).to eq(item.id)
    end
  end

  describe "POST /todos/:id/items" do
    it "creates a new todo item" do
      todo = user.todos.create!(title: "εργασία")

      post "/todos/#{todo.id}/items",
           params: { title: "γράψε τεκμηρίωση", done: false },
           headers: auth_headers

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["title"]).to eq("γράψε τεκμηρίωση")
      expect(todo.todo_items.count).to eq(1)
    end

    it "returns 422 for invalid item payload" do
      todo = user.todos.create!(title: "εργασία")

      post "/todos/#{todo.id}/items", params: { title: "" }, headers: auth_headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to be_present
    end
  end

  describe "PUT /todos/:id/items/:iid" do
    it "updates a todo item" do
      todo = user.todos.create!(title: "εργασία")
      item = todo.todo_items.create!(title: "initial", done: false)

      put "/todos/#{todo.id}/items/#{item.id}",
          params: { title: "updated", done: true },
          headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["title"]).to eq("updated")
      expect(item.reload.done).to eq(true)
    end

    it "returns 422 for invalid update" do
      todo = user.todos.create!(title: "εργασία")
      item = todo.todo_items.create!(title: "initial", done: false)

      put "/todos/#{todo.id}/items/#{item.id}", params: { title: "" }, headers: auth_headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to be_present
    end
  end

  describe "DELETE /todos/:id/items/:iid" do
    it "deletes a todo item" do
      todo = user.todos.create!(title: "εργασία")
      item = todo.todo_items.create!(title: "to delete")

      delete "/todos/#{todo.id}/items/#{item.id}", headers: auth_headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("Ok")
      expect(TodoItem.where(id: item.id)).to be_empty
    end
  end
end
