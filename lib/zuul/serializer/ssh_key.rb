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
require "zuul/mutation_serializer"

module Zuul
  module Serializer
    class SshKey < Zuul::MutationSerializer
      serializes :ssh_key
      def id; ssh_key.id; end
      def url; "/users/#{ssh_key.user.id}/ssh_keys"; end

      def links
        { "self" => self, "curies" => nil, "parent" => ssh_key.user }
      end

      def to_hash
        { :id => ssh_key.id,
          :comment => ssh_key.comment,
          :key => ssh_key.key }
      end
    end
  end
end