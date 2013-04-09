class Zuul::App
  extend Gitorious::Messaging::Publisher
  extend Gitorious::Authorization
end

# API Index
require "zuul/endpoint/api_index"

index = Zuul::Endpoint::APIIndex.new({
    { "self" => "start" } => nil,
    "curies" => nil,
    "gts:find_user" => nil,
    "gts:find_team" => nil,
    "gts:projects" => nil,
    "gts:find_project" => nil
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

# Team lookups
require "zuul/endpoint/team_lookup"

finder = GroupFinder.new
Zuul::App.mount("gts:find_team", Zuul::Endpoint::TeamLookup.new(finder)) do |route|
  route.options("/team", :options)
  route.options("/team/:name", :options)
  route.get("/team/:name", :get)
end

# Teams
require "zuul/endpoint/teams"

Zuul::App.mount("gts:team", Zuul::Endpoint::Teams.new(finder)) do |route|
  route.options("/teams/:id", :options)
  route.get("/teams/:id", :get)
end

# Memberships
require "zuul/endpoint/memberships"

Zuul::App.mount("gts:memberships", Zuul::Endpoint::Memberships.new(CreateMembership)) do |route|
  route.options("/teams/:team_id/memberships", :options)
  route.post("/teams/:team_id/memberships", :method => :post, :schema => "membership_payload")
end

# SSH Keys
require "zuul/endpoint/ssh_keys"

Zuul::App.mount("gts:ssh_keys", Zuul::Endpoint::SshKeys.new(CreateSshKey)) do |route|
  route.options("/users/:user_id/ssh_keys", :options)
  route.post("/users/:user_id/ssh_keys", :method => :post, :schema => "ssh_key_payload")
end

# Projects

require "zuul/endpoint/project_lookup"

finder = ProjectFinder.new
Zuul::App.mount("gts:find_project", Zuul::Endpoint::ProjectLookup.new(finder)) do |route|
  route.options("/project", :options)
  route.options("/project/:slug", :options)
  route.get("/project/:slug", :get)
end

require "zuul/endpoint/projects"

Zuul::App.mount("gts:projects", Zuul::Endpoint::Projects.new(finder, CreateProject)) do |route|
  route.options("/projects", :options)
  route.post("/projects", :method => :post, :schema => "project")
  route.get("/projects/:id", :method => :get, :schema => "project")
end

# Repositories
require "zuul/endpoint/repositories"

Zuul::App.mount("gts:repositories", Zuul::Endpoint::Repositories.new(CreateProjectRepository)) do |route|
  route.options("/projects/:project_id/repositories", :options)
  route.post("/projects/:project_id/repositories", :method => :post, :schema => "repository")
end
