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
require "zuul/error"
require "use_case"

module Zuul
  module Endpoint
    class UserLookup
      def initialize(user_finder)
        @user_finder = user_finder
      end

      def link_for(object)
        { "href" => "/user/{login}", "templated" => true }
      end

      def options(request, response)
        response.headers({ "Allow" => "GET, OPTIONS" })
        { "message" => "To find a user, GET /user/{login}" }
      end

      def get(request, response)
        user = @user_finder.by_login(request.params["login"])

        if user.nil?
          error = Zuul::NotFoundError.new({ :user => "User not found" })
          return UseCase::FailedOutcome.new(error)
        end

        UseCase::SuccessfulOutcome.new(Zuul::Serializer::User.new(user))
      end
    end
  end
end
