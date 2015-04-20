# encoding: UTF-8
#
# Author:    Stefano Harding <riddopic@gmail.com>
# License:   Apache License, Version 2.0
# Copyright: (C) 2014-2015 Stefano Harding
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
#

require 'chef_stash/version'
require 'chef_stash/core_ext/hash'
require 'chef_stash/core_ext/numeric'
require 'chef_stash/time_cache'
require 'chef_stash/disk_store'
require 'chef_stash/memoizable'
require 'chef_stash/rash'
require 'chef_stash/os'
require 'chef_stash/utils'

# Chef Key/value stash cache hash objects store.
#
module ChefStash
  # Check if we're using a version if Ruby that supports caller_locations.
  NEW_CALL = Kernel.respond_to? 'caller_locations'

  # Default hash stash cache store type.
  DEFAULT_STORE = DiskStore

  # insert a helper .new() method for creating a new object
  #
  def self.new(*args)
    self::Cache.new(*args)
  end

  # helper to get the calling function name
  #
  def self.caller_name
    NEW_CALL ? caller_locations(2, 1).first.label : caller[1][/`([^']*)'/, 1]
  end

  # Chef Key/value stash cache hash objects store.
  #
  class Cache
    # @return [Hash] of the mem stash cache hash store
    #
    # @!attribute [r] :store
    #   @return [ChefStash] The Chef Key/value stash cache hash objects store.
    attr_reader :store

    # Initializes a new Chef Key/value stash cache hash objects store.
    #
    def initialize(params = {})
      params = { store: params } unless params.is_a? Hash
      @store = params.fetch(:store) { ChefStash::DEFAULT_STORE.new }
    end

    # Retrieves the value for a given key, if nothing is set,
    # returns KeyError
    #
    # @param key [Symbol, String] representing the key
    #
    # @raise [KeyError] if no such key found
    #
    # @return [Hash, Array, String] value for key
    #
    def [](key = nil)
      key ||= ChefStash.caller_name
      fail KeyError, 'Key not cached' unless include? key.to_sym
      @store[key.to_sym]
    end

    # Retrieves the value for a given key, if nothing is set,
    # run the code, cache the result, and return it
    #
    # @param key [Symbol, String] representing the key
    # @param block [&block] that returns the value to set (optional)
    #
    # @return [Hash, Array, String] value for key
    #
    def cache(key = nil, &code)
      key ||= ChefStash.caller_name
      @store[key.to_sym] ||= code.call
    end

    # return a boolean indicating presence of the given key in the store
    #
    # @param key [Symbol, String] a string or symbol representing the key
    #
    # @return [TrueClass, FalseClass]
    #
    def include?(key = nil)
      key ||= ChefStash.caller_name
      @store.include? key.to_sym
    end

    # Clear the whole stash store or the value of a key
    #
    # @param key [Symbol, String] (optional) representing the key to
    # clear.
    #
    # @return nothing.
    #
    def clear!(key = nil)
      key.nil? ? @store.clear : @store.delete(key)
    end

    # return the size of the store as an integer
    #
    # @return [Fixnum]
    #
    def size
      @store.size
    end
  end
end
