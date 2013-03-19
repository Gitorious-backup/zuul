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
require "digest/md5"

module Zuul
  class JSONResponse
    def initialize(router, response)
      @router = router
      @response = response
    end

    def status
      200
    end

    def content_type
      "application/json"
    end

    def headers
      { "Content-Length" => body.length.to_s,
        "Content-Type" => content_type,
        "Etag" => Digest::MD5.hexdigest(body) }
    end

    def hash
      response.to_hash
    end

    def body
      @body ||= JSON.dump(hash)
    end

    def self.for(router, result)
      return new(router, result) if result.is_a?(Hash)
      is_success = result.respond_to?(:success?) && !result.success?
      return ErrorResponse.new(router, result) if is_success
      HALResponse.new(router, result)
    end

    protected
    def router; @router; end
    def response; @response; end
  end

  class HALResponse < JSONResponse
    def profile
      return @profile if defined?(@profile)
      return @profile = nil if !response.respond_to?(:profile)
      @profile = router.uri("/schema/#{response.profile}")
    end

    def content_type
      "application/hal+json" + (!profile.nil? ? "; profile=#{profile}" : "")
    end

    def links
      links = !profile.nil? ? { "profile" => { "href" => profile } } : {}
      response.links.inject(links) do |links, kv|
        links.merge(router.link(kv[0], kv[1]))
      end
    end

    def hash
      response.to_hash.merge("_links" => links)
    end
  end

  class ErrorResponse < JSONResponse
    def status
      response.errors.respond_to?(:status) ? response.errors.status : 500
    end

    def content_type
      "application/vnd.gitorious.error+json"
    end

    def type
      error = response.errors
      return error.type if error.respond_to?(:type)
      return "validation_error" if error.class.to_s == "Mutations::ErrorHash"
      error.class.to_s
    end

    def body
      JSON.dump("type" => type, "message" => response.errors.message)
    end
  end
end
