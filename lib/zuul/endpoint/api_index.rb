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
module Zuul
  module Endpoint
    class APIIndex
      def initialize(links)
        @links = LinkCollection.new(links)
      end

      def options(app, request, params)
        app.headers({ "Allow" => "GET, OPTIONS" })
        { "message" => "Welcome to the Gitorious API" }
      end

      def get(app, request, params)
        @links
      end

      def link_for(object)
        "/"
      end
    end

    class LinkCollection
      attr_reader :links
      def initialize(links); @links = links; end
      def to_hash; {}; end
      def url; "/"; end
    end
  end
end
