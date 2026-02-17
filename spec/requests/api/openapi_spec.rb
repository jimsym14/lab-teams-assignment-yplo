require "swagger_helper"

RSpec.describe "Todo API", type: :request do
  path "/signup" do
    post("Signup") do
      tags "Auth"
      consumes "application/json"
      produces "application/json"

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string },
          password_confirmation: { type: :string },
          name: { type: :string },
          student_id: { type: :string, nullable: true }
        },
        required: %w[email password password_confirmation name]
      }

      response(201, "created") do
        let(:payload) do
          {
            email: "george@unipi.gr",
            password: "Password123!",
            password_confirmation: "Password123!",
            name: "Γιώργος Παπαδόπουλος",
            student_id: "AEM12345"
          }
        end

        run_test!
      end

      response(422, "unprocessable entity") do
        let(:payload) do
          {
            email: "",
            password: "Password123!",
            password_confirmation: "Password123!",
            name: ""
          }
        end

        run_test!
      end
    end
  end

  path "/auth/login" do
    post("Login") do
      tags "Auth"
      consumes "application/json"
      produces "application/json"

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: %w[email password]
      }

      before do
        User.create!(email: "ergasia2026@test.com", password: "Password123!", name: "Ομάδα Εργασίας")
      end

      response(200, "ok") do
        let(:payload) { { email: "ergasia2026@test.com", password: "Password123!" } }

        run_test!
      end
    end
  end

  path "/auth/logout" do
    get("Logout") do
      tags "Auth"
      produces "application/json"
      security [bearerAuth: []]
      parameter name: :Authorization, in: :header, schema: { type: :string }

      response(200, "ok") do
        let!(:user) { User.create!(email: "logout@student.gr", password: "Password123!", name: "Student Logout") }
        let(:Authorization) do
          user.regenerate_api_token
          "Bearer #{user.api_token}"
        end

        run_test!
      end
    end
  end

  path "/todos" do
    get("List all todos and todo items") do
      tags "Todos"
      produces "application/json"
      security [bearerAuth: []]
      parameter name: :Authorization, in: :header, schema: { type: :string }

      response(200, "ok") do
        let!(:user) { User.create!(email: "todos-index@student.gr", password: "Password123!", name: "Student Index") }
        let(:Authorization) do
          user.regenerate_api_token
          "Bearer #{user.api_token}"
        end

        before do
          todo = user.todos.create!(title: "Εργασία Εξαμήνου", description: "sample")
          todo.todo_items.create!(title: "Nested item")
        end

        run_test!
      end
    end

    post("Create a new todo") do
      tags "Todos"
      consumes "application/json"
      produces "application/json"
      security [bearerAuth: []]
      parameter name: :Authorization, in: :header, schema: { type: :string }
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          description: { type: :string, nullable: true }
        },
        required: %w[title]
      }

      let!(:user) { User.create!(email: "todos-create@student.gr", password: "Password123!", name: "Student Create") }
      let(:Authorization) do
        user.regenerate_api_token
        "Bearer #{user.api_token}"
      end

      response(201, "created") do
        let(:payload) { { title: "Project Παρασκευής", description: "From swagger" } }

        run_test!
      end

      response(422, "unprocessable entity") do
        let(:payload) { { title: "" } }

        run_test!
      end
    end
  end

  path "/todos/{id}" do
    parameter name: :id, in: :path, schema: { type: :integer }

    get("Get a todo") do
      tags "Todos"
      produces "application/json"
      security [bearerAuth: []]
      parameter name: :Authorization, in: :header, schema: { type: :string }

      let!(:user) { User.create!(email: "todos-show@student.gr", password: "Password123!", name: "Student Show") }
      let!(:todo) { user.todos.create!(title: "Show todo", description: "desc") }
      let(:id) { todo.id }
      let(:Authorization) do
        user.regenerate_api_token
        "Bearer #{user.api_token}"
      end

      response(200, "ok") do
        run_test!
      end
    end

    put("Update a todo") do
      tags "Todos"
      consumes "application/json"
      produces "application/json"
      security [bearerAuth: []]
      parameter name: :Authorization, in: :header, schema: { type: :string }
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          description: { type: :string, nullable: true }
        }
      }

      let!(:user) { User.create!(email: "todos-update@student.gr", password: "Password123!", name: "Student Update") }
      let!(:todo) { user.todos.create!(title: "Before", description: "old") }
      let(:id) { todo.id }
      let(:Authorization) do
        user.regenerate_api_token
        "Bearer #{user.api_token}"
      end

      response(200, "ok") do
        let(:payload) { { title: "After", description: "new" } }

        run_test!
      end

      response(422, "unprocessable entity") do
        let(:payload) { { title: "" } }

        run_test!
      end
    end

    delete("Delete a todo and its items") do
      tags "Todos"
      produces "application/json"
      security [bearerAuth: []]
      parameter name: :Authorization, in: :header, schema: { type: :string }

      let!(:user) { User.create!(email: "todos-delete@student.gr", password: "Password123!", name: "Student Delete") }
      let!(:todo) do
        created_todo = user.todos.create!(title: "Delete Todo")
        created_todo.todo_items.create!(title: "Delete nested")
        created_todo
      end
      let(:id) { todo.id }
      let(:Authorization) do
        user.regenerate_api_token
        "Bearer #{user.api_token}"
      end

      response(200, "ok") do
        run_test!
      end
    end
  end

  path "/todos/{id}/items" do
    parameter name: :id, in: :path, schema: { type: :integer }

    post("Create a new todo item") do
      tags "Todo Items"
      consumes "application/json"
      produces "application/json"
      security [bearerAuth: []]
      parameter name: :Authorization, in: :header, schema: { type: :string }
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          done: { type: :boolean }
        },
        required: %w[title]
      }

      let!(:user) { User.create!(email: "items-create@student.gr", password: "Password123!", name: "Student Item Create") }
      let!(:todo) { user.todos.create!(title: "Todo with items") }
      let(:id) { todo.id }
      let(:Authorization) do
        user.regenerate_api_token
        "Bearer #{user.api_token}"
      end

      response(201, "created") do
        let(:payload) { { title: "New Item", done: false } }

        run_test!
      end

      response(422, "unprocessable entity") do
        let(:payload) { { title: "" } }

        run_test!
      end
    end
  end

  path "/todos/{id}/items/{iid}" do
    parameter name: :id, in: :path, schema: { type: :integer }
    parameter name: :iid, in: :path, schema: { type: :integer }

    get("Get a todo item") do
      tags "Todo Items"
      produces "application/json"
      security [bearerAuth: []]
      parameter name: :Authorization, in: :header, schema: { type: :string }

      let!(:user) { User.create!(email: "items-show@student.gr", password: "Password123!", name: "Student Item Show") }
      let!(:todo) { user.todos.create!(title: "Todo show item") }
      let!(:item) { todo.todo_items.create!(title: "Item show") }
      let(:id) { todo.id }
      let(:iid) { item.id }
      let(:Authorization) do
        user.regenerate_api_token
        "Bearer #{user.api_token}"
      end

      response(200, "ok") do
        run_test!
      end
    end

    put("Update a todo item") do
      tags "Todo Items"
      consumes "application/json"
      produces "application/json"
      security [bearerAuth: []]
      parameter name: :Authorization, in: :header, schema: { type: :string }
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          done: { type: :boolean }
        }
      }

      let!(:user) { User.create!(email: "items-update@student.gr", password: "Password123!", name: "Student Item Update") }
      let!(:todo) { user.todos.create!(title: "Todo update item") }
      let!(:item) { todo.todo_items.create!(title: "Item before", done: false) }
      let(:id) { todo.id }
      let(:iid) { item.id }
      let(:Authorization) do
        user.regenerate_api_token
        "Bearer #{user.api_token}"
      end

      response(200, "ok") do
        let(:payload) { { title: "Item after", done: true } }

        run_test!
      end

      response(422, "unprocessable entity") do
        let(:payload) { { title: "" } }

        run_test!
      end
    end

    delete("Delete a todo item") do
      tags "Todo Items"
      produces "application/json"
      security [bearerAuth: []]
      parameter name: :Authorization, in: :header, schema: { type: :string }

      let!(:user) { User.create!(email: "items-delete@student.gr", password: "Password123!", name: "Student Item Delete") }
      let!(:todo) { user.todos.create!(title: "Todo delete item") }
      let!(:item) { todo.todo_items.create!(title: "Item delete") }
      let(:id) { todo.id }
      let(:iid) { item.id }
      let(:Authorization) do
        user.regenerate_api_token
        "Bearer #{user.api_token}"
      end

      response(200, "ok") do
        run_test!
      end
    end
  end
end
