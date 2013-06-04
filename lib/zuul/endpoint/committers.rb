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
require "zuul/serializer/committers"
require "use_case"

module Zuul
  module Endpoint
    class Committers
      def initialize(use_case)
        @use_case = use_case
      end

      def link_for(object)
        "/repositories/#{object.id}/committers"
      end

      def options(request, response)
        response.headers({ "Allow" => "GET, OPTIONS" })
        { "message" => "GET to look up the individual committers of a repository" }
      end

      def get(request, response)
        repository = request.params["repository_id"].to_i
        outcome = @use_case.new(Zuul::App, repository, request.current_user).execute
        Zuul::Outcome.new(outcome, Zuul::Serializer::Committers)
      end
    end
  end
end
