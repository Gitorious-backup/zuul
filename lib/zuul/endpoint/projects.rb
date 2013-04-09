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
      def initialize(project_finder, use_case)
        @use_case = use_case
        @project_finder = project_finder
      end

      def link_for(object)
        object.nil? ? "/projects" : "/projects/#{object.id}"
      end

      def options(request, response)
        response.headers({ "Allow" => "GET, POST, OPTIONS" })
        { "message" => "POST to create new project" }
      end

      def post(request, response)
        outcome = @use_case.new(Zuul::App, request.user).execute(request.params)
        Zuul::Outcome.new(outcome, Zuul::Serializer::Project)
      end

      def get(request, response)
        project = @project_finder.by_id(request.params["id"])
        return UseCase::FailedOutcome.new({ :project => "No such project" }) if project.nil?
        UseCase::SuccessfulOutcome.new(Zuul::Serializer::Project.new(project))
      end
    end
  end
end
