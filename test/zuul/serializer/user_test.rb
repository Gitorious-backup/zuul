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
require "zuul/serializer/user"
require "zuul/not_found_error"
require "ostruct"

describe Zuul::Serializer::User do
  before do
    @user = OpenStruct.new(:id => 1,
                           :login => "mm",
                           :fullname => "Mega Man",
                           :email => "mm@capcom.com")
  end

  it "is successful if user is defined" do
    serializer = Zuul::Serializer::User.new(@user)
    assert serializer.success?
  end

  it "is not successful if user is nil" do
    serializer = Zuul::Serializer::User.new(nil)
    refute serializer.success?
  end

  it "proxies id" do
    serializer = Zuul::Serializer::User.new(@user)
    assert_equal 1, serializer.id
  end

  it "generates url" do
    serializer = Zuul::Serializer::User.new(@user)
    assert_equal "/users/1", serializer.url
  end

  it "serializes user as hash" do
    def @user.public_email?; false; end
    serializer = Zuul::Serializer::User.new(@user)

    expected = { :id => 1, :login => "mm", :name => "Mega Man" }
    assert_equal expected, serializer.to_hash
  end

  it "serializes user with public email" do
    def @user.public_email?; true; end
    serializer = Zuul::Serializer::User.new(@user)

    assert_equal({ :id => 1,
                   :login => "mm",
                   :name => "Mega Man",
                   :email => "mm@capcom.com"
                 }, serializer.to_hash)
  end

  it "produces error if user is nil" do
    serializer = Zuul::Serializer::User.new(nil)

    assert Zuul::NotFoundError === serializer.errors
  end
end
