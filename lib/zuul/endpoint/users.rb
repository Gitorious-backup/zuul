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
require "zuul/serializer/user"
require "use_case"

module Zuul
  module Endpoint
    class Users
      def initialize(user_finder)
        @user_finder = user_finder
      end

      def link_for(user)
        "/users/#{user.id}"
      end

      def options(request, response)
        response.headers({ "Allow" => "GET, OPTIONS" })
        { "message" => "GET /users/{id} to view user" }
      end

      def get(request, response)
        user = @user_finder.by_id(request.params["id"])
        return UseCase::FailedOutcome.new({ :user => "No such user" }) if user.nil?
        UseCase::SuccessfulOutcome.new(Zuul::Serializer::User.new(user))
      end
    end
  end
end
