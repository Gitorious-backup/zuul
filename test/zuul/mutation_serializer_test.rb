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
require "zuul/mutation_serializer"

class TestSerializer < Zuul::MutationSerializer
  serializes :test
end

class ProfileTestSerializer < Zuul::MutationSerializer
  serializes :test, :profile => :thing
end

class NoProfileTestSerializer < Zuul::MutationSerializer
  serializes :test, :profile => nil
end

describe Zuul::MutationSerializer do
  it "proxies success predicate" do
    serialized = TestSerializer.new(Zuul::Test::Success.new("Result"))
    assert serialized.success?
  end

  it "proxies errors method" do
    serialized = TestSerializer.new(Zuul::Test::Failure.new(["Error"]))
    assert_equal ["Error"], serialized.errors.message
  end

  it "provides default links method" do
    serialized = TestSerializer.new(Zuul::Test::Success.new("Result"))
    assert_equal [], serialized.links
  end

  it "exposes result under serialized name" do
    serialized = TestSerializer.new(Zuul::Test::Success.new("Result"))
    assert_equal "Result", serialized.test
  end

  it "defaults profile to serialized attribute name" do
    serialized = TestSerializer.new(Zuul::Test::Success.new("Result"))
    assert_equal :test, serialized.profile
  end

  it "uses custom profile name" do
    serialized = ProfileTestSerializer.new(Zuul::Test::Success.new("Result"))
    assert_equal :thing, serialized.profile
  end

  it "has no profile" do
    serialized = NoProfileTestSerializer.new(Zuul::Test::Success.new("Result"))
    refute serialized.respond_to?(:profile)
  end
end
