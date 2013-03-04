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
require "test_helper"
require "zuul/endpoint/user_lookup"
require "ostruct"

class TestUserFinder
  def by_login(login)
    OpenStruct.new(:login => login)
  end
end

describe Zuul::Endpoint::UserLookup do
  before { @app = Zuul::Test::Application.new }

  it "generates link" do
    endpoint = Zuul::Endpoint::UserLookup.new(TestUserFinder.new)

    link = { "href" => "/user/{login}", "templated" => true }
    assert_equal(link, endpoint.link_for(nil))
  end

  it "responds to OPTIONS request" do
    endpoint = Zuul::Endpoint::UserLookup.new(TestUserFinder.new)
    response = endpoint.options(@app, nil, {})

    assert Hash === response
    assert_equal "GET, OPTIONS", @app.headers["Allow"]
  end

  it "responds to GET request" do
    endpoint = Zuul::Endpoint::UserLookup.new(TestUserFinder.new)
    response = endpoint.get(@app, nil, :login => "mm")

    assert_equal "mm", response.to_hash[:login]
  end
end
