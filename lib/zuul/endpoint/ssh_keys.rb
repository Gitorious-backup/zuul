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
require "zuul/serializer/ssh_key"

module Zuul
  module Endpoint
    class SshKeys
      def initialize(backend)
        @backend = backend
      end

      def link_for(user)
        "/users/#{user.id}/ssh_keys"
      end

      def options(app, request, params)
        app.headers({ "Allow" => "POST, OPTIONS" })
        { "message" => "POST to upload an SSH key" }
      end

      def post(app, request, params)
        Zuul::Serializer::SshKey.new(@backend.run(params))
      end
    end
  end
end
