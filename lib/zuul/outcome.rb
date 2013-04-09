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
  class Outcome
    def initialize(outcome, serializer)
      @outcome = outcome
      @serializer = serializer
    end

    def success(&block)
      wrapped = nil
      @outcome.success do |result|
        wrapped = @serializer.new(result)
        block.call(wrapped) if !block.nil?
      end
      wrapped
    end

    def respond_to?(name)
      super || @outcome.respond_to?(name)
    end

    def method_missing(name, *args, &block)
      return super if !@outcome.respond_to?(name)
      @outcome.send(name, *args, &block)
    end
  end
end
