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

  class AuthenticationRequired < Exception
  end

  class Request
    attr_reader :request, :params

    def initialize(request, params)
      @request = request
      @params = params
    end

    def params
      @request.params.merge(@params)
    end

    def credentials
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      return nil if !@auth.provided? || !@auth.basic? || @auth.credentials.nil?
      @auth.credentials
    end

    def user
      return @user if @user
      login, password = credentials
      @user = Request.authenticate(login, password) if !login.nil? && !password.nil?
      raise AuthenticationRequired.new("Authentication is required") if @user.nil?
      @user
    end

    def self.for(request, params)
      ct = ((request.content_type || "").split(";")[0] || "").strip
      if ct == "application/json"
        return JSONRequest.new(request, params)
      end
      FormEncodedRequest.new(request, params)
    end

    def self.authenticator=(authenticator)
      @authenticator = authenticator
    end

    def self.authenticate(login, password)
      @authenticator && @authenticator.authenticate(login, password)
    end
  end

  class FormEncodedRequest < Request
  end

  class JSONRequest < Request
    def initialize(request, params)
      body = request.body.read
      super(request, body == "" ? {} : JSON.parse(body).merge(params))
    rescue JSON::ParserError => err
      raise InvalidRequest.new("Invalid request: Failed to parse request body JSON: #{err.message}")
    end
  end
end
