# API Index
require "zuul/endpoint/api_index"

index = Zuul::Endpoint::APIIndex.new({
  { "self" => "start" } => nil,
  "curies" => nil,
  "gts:find_user" => nil
})

Zuul::App.mount("start", index) do |route|
  route.options("/", :options)
  route.get("/", :get)
end

# User lookups
require "zuul/endpoint/user_lookup"

finder = UserFinder.new
Zuul::App.mount("gts:find_user", Zuul::Endpoint::UserLookup.new(finder)) do |route|
  route.options("/user", :options)
  route.options("/user/:login", :options)
  route.get("/user/:login", :get)
end

# Users
require "zuul/endpoint/users"

Zuul::App.mount("gts:user", Zuul::Endpoint::Users.new(finder)) do |route|
  route.options("/users/:id", :options)
  route.get("/users/:id", :get)
end

# SSH Keys
require "zuul/endpoint/ssh_keys"

Zuul::App.mount("gts:ssh_keys", Zuul::Endpoint::SshKeys.new(SshKeyCreator)) do |route|
  route.options("/users/:user_id/ssh_keys", :options)
  route.post("/users/:user_id/ssh_keys", :method => :post, :schema => "ssh-key-payload")
end
