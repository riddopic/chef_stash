#!/usr/bin/env ruby

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'anemone'
require 'chef_stash'
require 'ap'
require 'chef_stash/core_ext/hash'

url     = 'http://winini.mudbox.dev/'
path    = 'packages_3.0'
options = { threads: 20, depth_limit: 3, discard_page_bodies: true }
results = []
regex   = /#{path}\/\w+.(\w+.(ini|zip)|sha256.txt)$/i
seen    = []

def seen_urls
  @seen_urls ||= []
end

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
    size     = ChefStash::FileSize.new(bytes).to_size(:mb).to_s

    seen_urls << { url: url, modified: modified, created: created }

    result = { key => { type => {
      code:          ChefStash::Response.code(page.code),
      depth:         page.depth,
      size:          size,
      key:           key,
      md5:           Digest::MD5.hexdigest(page.body.to_s),
      modified:      modified,
      name:          name,
      referer:       page.referer.to_s,
      response_time: page.response_time.time_humanize,
      sha256:        OpenSSL::Digest::SHA256.new(page.body).to_s,
      content_type:  content,
      url:           url,
      created:       created,
      visited:       page.visited
    } } }

    ap result
  end
end

ap seen_urls
