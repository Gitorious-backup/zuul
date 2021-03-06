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
require "zuul/serializer/repositories"
require "zuul/serializer/repository"

module Zuul
  module Endpoint
    class Repositories
      def initialize(get_use_case, post_use_case)
        @get_use_case = get_use_case
        @post_use_case = post_use_case
      end

      def link_for(object)
        "/projects/#{object.id}/repositories"
      end

      def options(request, response)
        response.headers({ "Allow" => "GET, POST, OPTIONS" })
        { "message" => "POST to create new repository. GET to list all repositories" }
      end

      def get(request, response)
        project = request.params["project_id"].to_i
        outcome = @get_use_case.new(Zuul::App, project, request.current_user).execute
        Zuul::Outcome.new(outcome, Zuul::Serializer::Repositories)
      end

      def post(request, response)
        project = request.params["project_id"].to_i
        outcome = @post_use_case.new(Zuul::App, project, request.user).execute(request.params)
        Zuul::Outcome.new(outcome, Zuul::Serializer::Repository)
      end
    end
  end
end
