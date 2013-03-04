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
  class HashRouter
    def initialize
      @routes = {}
    end

    def options(route, options = {}); add_route(:options, route, options); end
    def get(route, options = {}); add_route(:get, route, options); end
    def head(route, options = {}); add_route(:head, route, options); end
    def post(route, options = {}); add_route(:post, route, options); end
    def delete(route, options = {}); add_route(:delete, route, options); end
    def routes; @routes; end

    private
    def add_route(verb, route, options)
      @routes[verb] ||= {}
      options = {} if options.nil?
      options = options.is_a?(Hash) ? options : { :method => options }
      @routes[verb][route] = { :method => verb }.merge(options || {})
    end
  end
end
