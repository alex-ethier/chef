#
# Author:: Stephen Delano (<stephen@opscode.com>)
# Author:: Seth Falcon (<seth@opscode.com>)
# Copyright:: Copyright 2010 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'dep_selector'

class Chef
  class RunList
    class VersionedRecipeList < Array

      def initialize
        super
        @versions = Hash.new
      end

      def add_recipe(name, version=nil)
        if version && @versions.has_key?(name)
          unless DepSelector::Version.new(@versions[name]) == DepSelector::Version.new(version)
            raise Chef::Exceptions::CookbookVersionConflict, "Run list requires #{name} at versions #{@versions[name]} and #{version}"
          end
        end
        @versions[name] = version if version
        self << name unless self.include?(name)
      end

      def with_versions
        self.map {|i| {:name => i, :version => @versions[i]}}
      end

      def with_version_constraints
        self.map do |i|
          constraint = DepSelector::VersionConstraint.new(@versions[i])
          { :name => i, :version_constraint => constraint }
        end
      end
    end
  end
end
