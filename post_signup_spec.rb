require_relative "routes/signup"
require_relative "libs/mongo"
require_relative "helpers"

describe "POST /signup" do
  context "novo usuario" do
    before(:all) do
      payload = { name: "Pitty", email: "pitty@bol.com.br", password: "pwd123" }
      MongoDB.new.remove_user(payload[:email])

      @result = Signup.new.create(payload)
    end

    it "valida status code" do
      expect(@result.code).to eql 200
    end

    it "valida id do usuario" do
      expect(@result.parsed_response["_id"].length).to eql 24
    end
  end

  context "usuario ja existe" do
    before(:all) do
      #dado que eu tenho um novo usuario
      payload = { name: "Joao da Silva", email: "joao@ig.com.br", password: "pwd123" }
      MongoDB.new.remove_user(payload[:email])

      # e o email desse usuário já foi cadastrado no sistema
      Signup.new.create(payload)

      # quando faço uma requisição para a rota /signup
      @result = Signup.new.create(payload)
    end

    it "deve retornar 409" do
      # entao deve retornar 409
      expect(@result.code).to eql 409
    end

    it "deve retornar mensagem" do
      expect(@result.parsed_response["error"]).to eql "Email already exists :("
    end
  end

  # examples = [
  #   {
  #     title: "nome em branco",
  #     payload: { nome: "", email: "betao@yahoo.com", password: "pwd123" },
  #     code: 412,
  #     error: "required name",
  #   },
  #   {
  #     title: "senha em branco",
  #     payload: { nome: "Roberto", email: "betao@yahoo.com", password: "" },
  #     code: 412,
  #     error: "required password",
  #   },
  #   {
  #     title: "email em branco",
  #     payload: { nome: "Roberto", email: "", password: "pwd123" },
  #     code: 412,
  #     error: "required email",
  #   },
  #   {
  #     title: "email inválido",
  #     payload: { nome: "Roberto", email: "betao#yahoo.com", password: "pwd123" },
  #     code: 412,
  #     error: "wrong email",
  #   },
  #   {
  #     title: "Sem campo nome",
  #     payload: { email: "betao@yahoo.com", password: "pwd123" },
  #     code: 412,
  #     error: "required name",
  #   },
  #   {
  #     title: "Sem campo email",
  #     payload: { nome: "Roberto", password: "pwd123" },
  #     code: 412,
  #     error: "required email",
  #   },
  #   {
  #     title: "Sem campo senha",
  #     payload: { nome: "Roberto", email: "betao@yahoo.com" },
  #     code: 412,
  #     error: "required password",
  #   },
  # ]

  examples = Helpers::get_fixtures("cadastro")

  examples.each do |e|
    context "#{e[:title]}" do
      before(:all) do
        @result = Signup.new.create(e[:payload])
      end

      it "valida status code" do
        expect(@result.code).to eql e[:code]
      end
    end
  end
end
