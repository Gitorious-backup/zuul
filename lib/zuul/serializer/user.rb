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
require "zuul/not_found_error"

module Zuul
  module Serializer
    class User
      attr_reader :user, :profile, :links

      def initialize(user)
        @user = user
        @profile = :user
        @links = {
          { "self" => "gts:user" } => user,
          "curies" => nil,
          "gts:ssh_keys" => user
        }
      end

      def success?; !user.nil?; end
      def id; user.id; end

      def errors
        return nil if success?
        Zuul::NotFoundError.new({ :user => "Not found" })
      end

      def to_hash
        hash = {
          :id => user.id,
          :login => user.login,
          :name => user.fullname
        }
        hash[:email] = user.email if user.public_email?
        hash
      end
    end
  end
end
