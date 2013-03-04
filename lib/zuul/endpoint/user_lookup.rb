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

module Zuul
  module Endpoint
    class UserLookup
      def initialize(user_finder)
        @user_finder = user_finder
      end

      def link_for(object)
        { "href" => "/user/{login}", "templated" => true }
      end

      def options(app, request, params)
        app.headers({ "Allow" => "GET, OPTIONS" })
        { "message" => "To find a user, GET /user/{login}" }
      end

      def get(app, request, params)
        user = @user_finder.by_login(params[:login])
        Zuul::Serializer::User.new(user)
      end
    end
  end
end
