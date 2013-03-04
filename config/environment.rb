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
require "ostruct"

class User < Struct.new(:id, :login, :fullname, :email)
  def public_email?
    true
  end
end

class UserFinder
  def by_login(login)
    login == "christian" ? User.new(1, login, "Christian", "christian@gitorious.com") : nil
  end
end

class SuccessfulOutcome
  attr_reader :result
  def initialize(result)
    @result = result
  end
  def success?; true; end
end

class FailedOutcome
  attr_reader :errors
  def initialize(errors)
    @errors = errors
  end
  def success?; false; end
end

class SshKeyCreator
  def self.run(params)
    user = OpenStruct.new(:id => 1)
    key = OpenStruct.new(:id => 12, :user => user, :key => params[:key])
    SuccessfulOutcome.new(key)
  end
end
