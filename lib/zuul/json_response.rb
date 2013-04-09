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
    def initialize(router, result)
      @router = router
      @result = result
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
      result.to_hash
    end

    def body
      @body ||= JSON.dump(hash)
    end

    def self.for(router, outcome)
      outcome.success { |result| return HALResponse.new(router, result) }
      outcome.pre_condition_failed { |f| return PreConditionFailedResponse.new(router, f) }
      outcome.failure { |validation| return ErrorResponse.new(router, validation) }
    end

    protected
    def router; @router; end
    def result; @result; end
  end

  class HALResponse < JSONResponse
    def profile
      return @profile if defined?(@profile)
      return @profile = nil if !result.respond_to?(:profile)
      @profile = router.uri("/schema/#{result.profile}")
    end

    def content_type
      "application/hal+json" + (!profile.nil? ? "; profile=#{profile}" : "")
    end

    def links
      links = !profile.nil? ? { "profile" => { "href" => profile } } : {}
      return links if !result.respond_to?(:links)
      result.links.inject(links) do |links, kv|
        links.merge(router.link(kv[0], kv[1]))
      end
    end

    def hash
      result.to_hash.merge("_links" => links)
    end
  end

  class ErrorResponse < JSONResponse
    def status; 400; end
    def content_type; "application/vnd.gitorious.error+json"; end
    def type; "validation_error"; end
    def body; JSON.dump("type" => type, "message" => message); end

    def message
      return result if result.is_a?(Hash)
      if result.respond_to?(:errors)
        return result.errors.full_messages if result.errors.respond_to?(:full_messages)
        result.errors
      end
    end
  end

  class PreConditionFailedResponse < ErrorResponse
    def type; result.symbol; end
    def message; result.symbol; end
  end
end
