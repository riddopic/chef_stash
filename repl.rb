#!/usr/bin/env ruby

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'chef_stash'
require 'inifile'
require 'securerandom'
require 'tempfile'
require 'open-uri'

# Return a cleanly join URI/URL segments into a cleanly normalized URL that
# the libraries can use when constructing URIs. URI.join is pure evil.
#
# @param [Array<String>] paths the list of parts to join
#
# @return [String<URI>] nicely joined URI/URL, squeaky clean and normalized
def uri_join(*paths)
  return nil if paths.length == 0
  leadingslash = paths[0][0] == '/' ? '/' : ''
  trailingslash = paths[-1][-1] == '/' ? '/' : ''
  paths.map! { |path| path.sub(/^\/+/, '').sub(/\/+$/, '') }
  leadingslash + paths.join('/') + trailingslash
end

# Return a hash from an INI file with normalized keys (down-case
# and symbolized).
#
# @param [URI] file
#   the ini file
#
# @return [Hash]
def inihash(file)
  require 'inifile' unless defined?(IniFile)
  Tempfile.open(SecureRandom.hex(3)) do |f|
    f.write(URI.parse(file).read)
    f.close
    regkeys_fix IniFile.load(f.path).to_h.compact.recursively_normalize_keys
  end
end

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

# Shortcut to return cache path, if you pass in a file it will return the
# file with the cache path.
#
# @example
#   file_cache_path
#     => "/var/chef/cache/"
#
#   file_cache_path 'patch.tar.gz'
#     => "/var/chef/cache/patch.tar.gz"
#
#   file_cache_path "#{node[:name]}-backup.tar.gz"
#     => "/var/chef/cache/c20d24209cc8-backup.tar.gz"
#
# @param [String] args
#   name of file to return path with file
#
# @return [String]
def file_cache_path(*args)
  if args.nil?
    Chef::Config[:file_cache_path]
  else
    ::File.join(Chef::Config[:file_cache_path], args)
  end
end

# Initializes a new key store or loads an existing one. Data will persist
# between Chef invocations.
#
# @param key [Symbol, String] representing the key
#
# @return [Hash, Array, String] value for key
def stash
  require 'chef_stash' unless defined?(ChefStash)
  @stash ||= ChefStash.new
end

# Returns a new inihash hash replacing :regkeys hash section, and returning
# an array of hashes, with key/value pairs.
#
# @example replace the regkeys hash and return a new regkeys array of hashes
#   inihash = {
#     regkeys: {
#       key1:   'a_path[my_key]',
#       key2:   'the_path[to_key]',
#       value1: 'cool_value',
#       value2: 'cooler_value'
#     }
#   }
#   regkeys_fix(inihash)       Like a good neighbor regkey_fix has your back
#     => {  regkeys = [
#             {
#               data: 'cool_value',
#               name: 'my_key',
#               path: 'HKLM/SOFTWARE/KaiserPermanente/a_path',
#               type: :string
#             },
#             {
#               data: 'cooler_value',
#               name: 'to_key',
#               path: 'HKLM/SOFTWARE/KaiserPermanente/the_path',
#               type: :string
#             }
#           ]
#        }
#
# @param [Hash]
#   replaces the value of :regkeys
#
# @return [Array<Hash{Symbol => String}>]
#   new inihash hash, replacing the regkeys hash with an array of hashes
#   with key/value pairs, all other key/value pairs are unchanged
def regkeys_fix(hash)
  return hash unless hash.has_key?(:regkeys)
  regkeys = []
  hash[:regkeys].each do |key|
    char, i = key[0].to_s.scan(/\d+|\D+/)
    next unless char == 'key'
    path, name = key[1].scan(/([^\[]+)/)
    data = hash[:regkeys]["value#{i}".to_sym]
    nowtime = Time.now.strftime('%Y:%m:%d:%I:%M:%S')
    regkeys << {
      path: 'HKLM\SOFTWARE\KaiserPermanente\\' + path[0],
      type: :string,
      name: name[0].gsub(']', ''),
      data: (data == 'tstamp') ? nowtime : data
    }
  end
  hash[:regkeys] = regkeys
  hash
end

require 'pry'
binding.pry


