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
require "json"

module Zuul
  class InvalidRequest < Exception
  end

  class Request
    def self.for(request, params)
      ct = ((request.content_type || "").split(";")[0] || "").strip
      if ct == "application/json"
        return JSONRequest.new(request, params)
      end
      FormEncodedRequest.new(request, params)
    end
  end

  class FormEncodedRequest
    def initialize(request, params)
      @request = request
      @params = params
    end

    def params
      @request.params.merge(@params)
    end
  end

  class JSONRequest
    def initialize(request, params)
      @request = request
      @params = params
      body = request.body.read
      @params = JSON.parse(body).merge(params) unless body == ""
    rescue JSON::ParserError => err
      raise InvalidRequest.new("Invalid request: Failed to parse request body JSON: #{err.message}")
    end

    def params
      @request.params.merge(@params)
    end
  end
end
