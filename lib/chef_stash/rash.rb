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

require 'anemone'

module ChefStash
  class Rash
    include Memoizable

    # Initializes a new store object.
    #
    # @param [String, URI::HTTP] url
    #   The URL to the repository to scan.
    #
    # @param [String] path
    #   The path to append to the URL.
    #
    # @return [ChefStash]
    #
    def initialize(url, path)
      memoize [:fetch]
      @store ||= fetch(url, path)
    end

    # Retrieves a value from the cache.
    #
    # @param [Object] key
    #   The key to look up.
    #
    # @return [Object, nil]
    #   The value at the key, when present, or `nil`.
    #
    def [](key)
      @store[key]
    end
    alias_method :get, :[]

    # Stores a value in the cache, either an an argument or block. If a
    # previous value was set it will be overwritten with the new value.
    #
    # @param [Object] key
    #   The key to store.
    #
    # @param val [Object]
    #   The value to store.
    #
    # @return [Object, nil]
    #   The value at the key.
    #
    def []=(key, value)
      @store[key] = value
    end
    alias_method :set, :[]=

    # Removes a value from the cache.
    #
    # @param [Object] key
    #   The key to remove.
    #
    # @return [Object, nil]
    #   The value at the key, when present, or `nil`.
    #
    def delete(key)
      @store.delete(key)
    end

    # return the size of the store as an integer
    #
    # @return [Fixnum]
    #
    def size
      @store.size
    end

    # return all keys in the store as an array
    #
    # @return [Array<String, Symbol>] all the keys in store
    #
    def keys
      @store.keys
    end

    private #   P R O P R I E T À   P R I V A T A   Vietato L'accesso

    # Loads a Chef stash hash of cache stash of hash data into the hash stash
    # key/value stach hash cache object Chef store, or create a new one.
    #
    # @example
    #   (on Windows)
    #   rash[:av]
    #     => {
    #       :ini => {
    #              :key => :av,
    #             :name => "AV.ini",
    #              :url => "http://winini.mudbox.dev/packages_3.0/AV/AV.ini",
    #       :zip => {
    #              :key => :av,
    #             :name => "AV.ini",
    #              :url => "http://winini.mudbox.dev/packages_3.0/AV/AV.ini",
    #         }
    #     }
    #
    #   (on Unix/Linux/OSX)
    #   rash[:av]
    #     => {
    #       :ini => {
    #             :code => "200 OK",
    #          :content => "text/inifile",
    #          :created => "Tue, 21 Apr 2015 00:24:44 GMT",
    #            :depth => 3,
    #              :key => :av,
    #              :md5 => "336d9da322febc949eb22ae3f47d293b",
    #         :modified => "Mon, 16 Feb 2015 07:13:23 GMT",
    #             :name => "AV.ini",
    #          :referer => "http://winini.mudbox.dev/packages_3.0/AV/",
    #         :response => "1 seconds",
    #           :sha256 => "905425e1a33b0662297181c3031066d7e6757cb3796c730f82",
    #             :size => "0.0 MB",
    #              :url => "http://winini.mudbox.dev/packages_3.0/AV/AV.ini",
    #          :visited => nil
    #       },
    #       :zip => {
    #             :code => "200 OK",
    #          :content => "application/zip",
    #          :created => "Tue, 21 Apr 2015 00:24:45 GMT",
    #            :depth => 3,
    #              :key => :av,
    #              :md5 => "2488ceb74eb6cb5fae463c88b806ebff",
    #         :modified => "Mon, 16 Feb 2015 07:13:29 GMT",
    #             :name => "AV.ini",
    #          :referer => "http://winini.mudbox.dev/packages_3.0/AV/",
    #         :response => "1 seconds",
    #           :sha256 => "f3f14ac64263fc7b091d150a1bc0867d38a8604e88f56f5746",
    #             :size => "32.6 MB",
    #              :url => "http://winini.mudbox.dev/packages_3.0/AV/AV.zip",
    #          :visited => nil
    #         }
    #     }
    #
    # @param [URI::HTTP] url
    #   The URL to crawl to build a Repository Hash (RASH) cache hash store.
    #
    # @param [String] path
    #   A path to filter on.
    #
    # @return [RASH]
    #
    def fetch(url, path)
      results = []
      regex   = /#{path}\/\w+.(\w+.(ini|zip)|sha256.txt)$/i
      threads = ChefStash::OS.windows? ? 4 : 20
      options = { threads: threads, depth_limit: 3, discard_page_bodies: true }

      if ChefStash::OS.windows?
        Anemone.crawl(url, options) do |anemone|
          anemone.on_pages_like(regex) do |page|
            url  = page.url.to_s
            name = File.basename(url)
            key  = File.basename(name, '.*').downcase.to_sym
            type = File.extname(name)[1..-1].downcase.to_sym

            results << { key => { type => {
              key:  key, name: name, url:  url
            } } }
          end
        end

        results.reduce({}, :recursive_merge)
      else
        Anemone.crawl(url, options) do |anemone|
          anemone.on_pages_like(regex) do |page|
            url  = page.url.to_s
            name = File.basename(url)
            key  = File.basename(name, '.*').downcase.to_sym
            type = File.extname(name)[1..-1].downcase.to_sym

            header   = page.headers
            bytes    = header['content-length'].first
            modified = header['last-modified'].first
            created  = Time.now.utc.httpdate
            content  = type == :ini ? 'text/inifile' : header['content-type'].first
            code     = ChefStash::Response.code(page.code)
            md5      = Digest::MD5.hexdigest(page.body.to_s)
            sha256   = OpenSSL::Digest::SHA256.new(page.body).to_s
            size     = ChefStash::FileSize.new(bytes).to_size(:mb).to_s

            results << { key => { type => {
              code:     code,
              content:  content,
              created:  created,
              depth:    page.depth,
              key:      key,
              md5:      md5,
              modified: modified,
              name:     name,
              referer:  page.referer.to_s,
              response: page.response_time.time_humanize,
              sha256:   sha256,
              size:     size,
              url:      url,
              visited:  page.visited
            } } }
          end
        end

        results.reduce({}, :recursive_merge)
      end
    end
  end
end
