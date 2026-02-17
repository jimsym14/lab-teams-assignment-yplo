require "rails_helper"

RSpec.describe "API Auth", type: :request do
  describe "POST /signup" do
    it "creates user and returns token" do
      post "/signup", params: {
        email: "george@unipi.gr",
        password: "Password123!",
        password_confirmation: "Password123!",
        name: "Γιώργος"
      }

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["token"]).to be_present
      expect(body.dig("user", "email")).to eq("george@unipi.gr")
    end

    it "returns 422 when params are invalid" do
      post "/signup", params: {
        email: "",
        password: "Password123!",
        password_confirmation: "Password123!",
        name: ""
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to be_present
    end
  end

  describe "POST /auth/login" do
    let!(:user) { User.create!(email: "ergasia_final@test.com", password: "Password123!", name: "Final Ergasia") }

    it "logs in and returns token (happy path)" do
      post "/auth/login", params: { email: user.email, password: "Password123!" }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["token"]).to be_present
    end
  end

  describe "GET /auth/logout" do
    let!(:user) { User.create!(email: "logout@student.gr", password: "Password123!", name: "Logout User") }
    let!(:token) do
      user.regenerate_api_token
      user.api_token
    end

    it "logs out and rotates token" do
      old_token = token

      get "/auth/logout", headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("Logged out")
      expect(user.reload.api_token).not_to eq(old_token)
    end
  end
end
