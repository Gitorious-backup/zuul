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
require "zuul/serializer/project"

module Zuul
  module Endpoint
    class Projects
      def initialize(backend)
        @backend = backend
      end

      def link_for(object)
        "/projects"
      end

      def options(request, response)
        response.headers({ "Allow" => "POST, OPTIONS" })
        { "message" => "POST to create new project" }
      end

      # TODO: Get logged in user
      def post(request, response)
        outcome = @backend.run(request.params, { :user_id => 1 })
        Zuul::Serializer::Project.new(outcome)
      end
    end
  end
end
