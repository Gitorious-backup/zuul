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
require "zuul/serializer/repository"
require "use_case"

module Zuul
  module Endpoint
    class RepositoryLookup
      def initialize(repository_finder)
        @repository_finder = repository_finder
      end

      def link_for(object)
        { "href" => "/repository/{slug}", "templated" => true }
      end

      def options(request, response)
        response.headers({ "Allow" => "GET, OPTIONS" })
        { "message" => "To find a repository, GET /repository/{slug} with a slug like project/repo" }
      end

      def get(request, response)
        repository = @repository_finder.by_slug("#{request.params["project"]}/#{request.params["repository"]}")
        return UseCase::FailedOutcome.new({ :repository => "Repository not found" }) if repository.nil?
        UseCase::SuccessfulOutcome.new(Zuul::Serializer::Repository.new(repository))
      end
    end
  end
end
