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

module ChefStash
  module Response
    HTTP_STATUS_CODES = {
      200 => 'OK',
      201 => 'Created',
      202 => 'Accepted',
      203 => 'Non-Authoritative Information',
      204 => 'No Content',
      205 => 'Reset Content',
      206 => 'Partial Content',
      300 => 'Multiple Choices',
      301 => 'Moved Permanently',
      302 => 'Found',
      303 => 'See Other',
      304 => 'Not Modified',
      305 => 'Use Proxy',
      306 => 'Switch Proxy',
      307 => 'Temporary Redirect',
      308 => 'Permanent Redirect',
      400 => 'BadRequest',
      401 => 'Unauthorized',
      403 => 'Forbidden',
      404 => 'NotFound',
      405 => 'MethodNotAllowed',
      406 => 'AccessDenied',
      409 => 'Conflict',
      410 => 'Gone',
      500 => 'InternalServerError',
      501 => 'NotImplemented',
      502 => 'BadGateway',
      503 => 'ServiceUnavailable',
      504 => 'GatewayTimeout',
    }

    def self.code(code)
      status = HTTP_STATUS_CODES[code]
      code.to_s + ' ' + status
    end
  end

  class FileSize
    def initialize(size)
      @units = {
        b:  1,
        kb: 1024**1,
        mb: 1024**2,
        gb: 1024**3,
        tb: 1024**4,
        pb: 1024**5,
        eb: 1024**6
      }

      @size_int = size.partition(/\D{1,2}/).at(0).to_i
      unit = size.partition(/\D{1,2}/).at(1).to_s.downcase
      case
      when unit.match(/[kmgtpe]{1}/)
        @size_unit = unit.concat('b')
      when unit.match(/[kmgtpe]{1}b/)
        @size_unit = unit
      else
        @size_unit = 'b'
      end
    end

    def to_size(unit, places = 1)
      unit_val = @units[unit.to_s.downcase.to_sym]
      bytes    = @size_int * @units[@size_unit.to_sym]
      size     = bytes.to_f / unit_val.to_f
      value    = sprintf("%.#{places}f", size).to_f
      "#{value} #{unit.upcase}"
    end

    def from_size(places = 1)
      unit_val = @units[@size_unit.to_s.downcase.to_sym]
      sprintf("%.#{places}f", @size_int * unit_val)
    end
  end
end
