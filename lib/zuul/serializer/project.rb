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
    class Project < Zuul::MutationSerializer
      serializes :project
      def id; project.id; end
      def url; "/projects/#{id}"; end

      def links
        { "self" => self,
          "curies" => nil,
          { "parent" => "gts:user" } => project.owner }
      end

      def to_hash
        hash = { :id => project.id,
          :title => project.title,
          :slug => project.slug,
          :description => project.description,
          :created_at => project.created_at,
          :owner => {
            :id => project.owner.id,
            :type => project.owner.class.to_s
          }
        }

        if project.wiki_repository
          hash["wiki_url"] = project.wiki_repository.default_clone_url
        end

        hash.merge(pick(project, [:license, :home_url, :mailinglist_url, :bugtracker_url]))
      end

      private
      def pick(object, attrs)
        Hash.new.tap do |h|
          attrs.each do |a|
            value = object.send(a)
            h[a] = value unless value.nil? || value == ""
          end
        end
      end
    end
  end
end
