# encoding: utf-8
#--
#   Copyright (C) 2013 Gitorious AS
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++
require "json"
require "sinatra/base"
require "zuul/hash_router"
require "zuul/json_response"

module Zuul
  class App < Sinatra::Base
    ERROR = "application/vnd.gitorious.error+json"
    VERSION = "1"

    def initialize(public_folder)
      @public_folder = public_folder
      Sinatra::Base.set(:public_folder, public_folder)
      super()
    end

    # Sane, unified API for getting the value of request headers
    def header(name)
      name = name.gsub(/-/, "_").upcase
      return request.env[name] if request.env.key?(name)
      request.env["HTTP_#{name}"]
    end

    before do
      return if request.path_info =~ /^\/(rels\/.+|schema)/

      if header("gts-api-version") != VERSION
        bad_request(<<EOF)
# The GTS-API-VERSION request header is required in order to use the API.
Please send GTS-API-VERSION: #{VERSION}
EOF
      end
    end

    ### Actions

    get "/schema/:schema" do
      file = File.join("schema", params[:schema].gsub(/\./, "-"))
      headers["Content-Type"] = "application/json"
      File.read(File.join(@public_folder, "#{file}.json"))
    end

    get "/rels/:relation" do
      file = File.join("rels", params[:relation].gsub(/\./, "-"))
      headers["Content-Type"] = "text/html"
      File.read(File.join(@public_folder, "#{file}.html"))
    end

    # Mount an API endpoint. An API endpoint is a link relation and an arbitrary
    # object. The associated block will be called with a router object that is
    # used to map HTTP requests to method calls on the object.
    def self.mount(relation, endpoint, &block)
      router = Zuul::HashRouter.new
      block.call(router)
      router.routes.each do |verb, routes|
        routes.each do |route, handler|
          mount_endpoint(verb, route, endpoint, handler)
        end
      end
      @endpoints ||= {}
      @endpoints[relation] = endpoint
    end

    def self.endpoint(relation)
      (@endpoints || {})[relation]
    end

    def link(rel, object)
      return curies if rel == "curies"
      return { "self" => { "href" => uri(object.url) } } if rel == "self"
      endpoint = self.class.endpoint(rel)
      return {} if !endpoint
      link = endpoint.link_for(object)
      link = { "href" => link } if !link.is_a?(Hash)
      link["href"] = uri(link["href"])
      { rel => link }
    end

    private
    def self.mount_endpoint(verb, route, endpoint, handler)
      self.send(verb.to_s.downcase.to_sym, route) do |*args|
        result = endpoint.send(handler[:method], self, request, params)
        response = Zuul::JSONResponse.for(self, result)
        status(response.status)
        headers(response.headers)
        response.body
      end
    end

    def bad_request(message)
      error = JSON.dump("type" => "bad_request_data", "message" => message)
      halt(400, { "Content-Type" => ERROR }, error)
    end

    def curies
      { "curies" => [{ "name" => "gts",
                       "href" => uri("/rels/{rel}"),
                       "templated" => true }] }
    end

    def symbolize_keys(hash)
      hash.keys.inject({}) do |symbolized, key|
        symbolized[key.to_sym] = hash[key]
        symbolized
      end
    end
  end
end