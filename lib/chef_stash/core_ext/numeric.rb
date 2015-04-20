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

class Numeric
  # Reports the approximate distance in time between integers as milliseconds,
  # rounding up to the nearest second.
  #
  # @param [Boolean] include_milliseconds
  #   If the number of milliseconds should also be printed.
  #
  # @return [String]
  #   The elapsed time
  #
  def time_humanize(include_milliseconds = false)
    deta = self > 1000 ? self : 1000
    deta,  milliseconds = deta.divmod(1000)
    deta,  seconds = deta.divmod(60)
    deta,  minutes = deta.divmod(60)
    deta,  hours   = deta.divmod(24)
    deta,  days    = deta.divmod(30)
    years, months  = deta.divmod(12)

    ret  = ''
    ret << "#{years} years "     unless years   == 0
    ret << "#{months} months "   unless months  == 0
    ret << "#{days} days "       unless days    == 0
    ret << "#{hours} hours "     unless hours   == 0
    ret << "#{minutes} minutes " unless minutes == 0
    ret << "#{seconds} seconds " unless seconds == 0
    ret << "#{milliseconds} milliseconds" if include_milliseconds

    ret.rstrip
  end
end
