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
require "zuul/serializer/membership"
require "zuul/serializer/memberships"
require "use_case"

module Zuul
  module Endpoint
    class Memberships
      def initialize(create_membership, group_finder)
        @create_membership = create_membership
        @group_finder = group_finder
      end

      def link_for(group)
        "/teams/#{group.id}/memberships"
      end

      def options(request, response)
        response.headers({ "Allow" => "GET, POST, OPTIONS" })
        { "message" => "POST to create new membership, GET to list memberships" }
      end

      def get(request, response)
        group = @group_finder.find(request.params["team_id"].to_i)
        memberships = UseCase::SuccessfulOutcome.new(group.memberships)
        Zuul::Outcome.new(memberships, Zuul::Serializer::Memberships)
      end

      def post(request, response)
        group = request.params["team_id"].to_i
        outcome = @create_membership.new(Zuul::App, group, request.user).execute({
            :user_id => request.params["user_id"],
            :role_name => request.params["role"]
          })
        Zuul::Outcome.new(outcome, Zuul::Serializer::Membership)
      end
    end
  end
end
