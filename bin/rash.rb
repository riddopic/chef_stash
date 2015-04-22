#!/usr/bin/env ruby
#
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

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'chef_stash'
require 'ap'

# Initializes a new repository hash or load an existing one.
#
# @param [String, Symbol] key
#   name of the key
#
# @return [Hoodie::ChefStash]
def rash(url = 'http://winini.mudbox.dev', path = 'packages_3.0')
  require 'chef_stash' unless defined?(ChefStash)
  @rash ||= ChefStash::Rash.new(url, path)
end

def checksum_file(file, digest)
  if File.exist?(file)
    File.open(file, 'rb') { |f| checksum_io(f, digest) }
  else
    false
  end
end

def checksum_io(io, digest)
  while chunk = io.read(1024 * 8)
    digest.update(chunk)
  end
  digest.hexdigest
end

results = []
url     = 'http://winini.mudbox.dev/'
path    = 'packages_3.0'
regex   = /#{path}\/\w+.(\w+.(ini|zip)|sha256.txt)$/i
threads = ChefStash::OS.windows? ? 4 : 20
options = { threads: threads, depth_limit: 3, discard_page_bodies: true }

results = []
Anemone.crawl(url, options) do |anemone|
  anemone.on_pages_like(regex) do |page|
    url  = page.url.to_s
    name = File.basename(url)
    key  = File.basename(name, '.*').downcase.to_sym
    type = File.extname(name)[1..-1].downcase.to_sym

    results << { key => { type => { page: page } } }
    ap results
  end
end

# Anemone.crawl(url, options) do |anemone|
#   anemone.on_pages_like(regex) do |page|
#     url  = page.url.to_s
#     name = File.basename(url)
#     key  = File.basename(name, '.*').downcase.to_sym
#     type = File.extname(name)[1..-1].downcase.to_sym
#
#     header   = page.headers
#     bytes    = header['content-length'].first || 0
#     modified = header['last-modified'].first
#     created  = Time.now.utc.httpdate
#     content  = type == :ini ? 'text/inifile' : header['content-type'].first
#     code     = ChefStash::Response.code(page.code)
#     md5      = Digest::MD5.hexdigest(page.body.to_s)
#     sha256   = OpenSSL::Digest::SHA256.new(page.body).to_s
#     size     = ChefStash::FileSize.new(bytes).to_size(:mb).to_s
#
#     results  = { key => { type => {
#       code:     code,
#       content:  content,
#       created:  created,
#       depth:    page.depth,
#       key:      key,
#       md5:      md5,
#       modified: modified,
#       name:     name,
#       referer:  page.referer.to_s,
#       response: page.response_time.time_humanize,
#       sha256:   sha256,
#       size:     size,
#       url:      url,
#       visited:  page.visited
#     } } }
#
#     ap results
#   end
# end
