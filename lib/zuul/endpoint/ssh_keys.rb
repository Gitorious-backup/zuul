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
require "zuul/outcome"

module Zuul
  module Endpoint
    class SshKeys
      def initialize(use_case)
        @use_case = use_case
      end

      def link_for(user)
        "/users/#{user.id}/ssh_keys"
      end

      def options(request, response)
        response.headers({ "Allow" => "POST, OPTIONS" })
        { "message" => "POST to upload an SSH key" }
      end

      def post(request, response)
        outcome = @use_case.new(Zuul::App, request.user).execute(request.params)
        Zuul::Outcome.new(outcome, Zuul::Serializer::SshKey)
      end
    end
  end
end
