
=> {
    :ini => {
           :md5 => "42637e9aebc7a8dc6675f447b4c774ed",
           :key => :avsm,
          :name => "AVSM.ini",
          :type => :ini,
           :url => "http://serf.mudbox.dev/package_3.0/AVSM/AVSM.ini",
         :utime => 1429316444,
        :sha256 => nil
    },
    :zip => {
           :md5 => "17b788aaed6245ada23fdd44b5edcd3e",
           :key => :avsm,
          :name => "AVSM.zip",
          :type => :zip,
           :url => "http://serf.mudbox.dev/package_3.0/AVSM/AVSM.zip",
         :utime => 1429316444,
        :sha256 => nil
    }
}

@url  = 'http://serf.mudbox.dev/'
@path = 'package_3.0'

@url  = 'http://winini.mudbox.dev/'
@path = 'package_3.0'


results = []
Anemone.crawl(@url, discard_page_bodies: true) do |anemone|
  anemone.on_pages_like(/\/#{@path}\/\w+\/\w+\.(ini|zip)$/i) do |page|
    page.to_hash
  end
end
results.reduce({}, :recursive_merge)
@document = {
  "url" => p.url.to_s, "md5string" => Digest::MD5.hexdigest(p.body.to_s)
}


ChefStash::ChefStash.new @url, @path


chef_stash('http://winini.mudbox.dev/pp', 'pk1')



Anemone.crawl(target) do |anemone|
  anemone.on_every_page do |page|
    puts page.url
  end
end


require 'anemone'

module Anemone
  class Page
    def to_hash
      name  = File.basename(@url.to_s)
      key   = File.basename(name, '.*').downcase.to_sym
      type  = File.extname(name)[1..-1].downcase.to_sym
      utime = Time.now.to_i

      key = { key => { type => {
        md5:    Digest::MD5.hexdigest(body.to_s),
        key:    key,
        name:   name,
        type:   type,
        url:    @url.to_s,
        utime:  utime,
        sha256: nil
      } } }
    end
  end
end

Anemone.crawl(@url, discard_page_bodies: true) do |anemone|
  anemone.on_pages_like(/\/#{@path}\/\w+\/\w+\.(ini|zip)$/i) do |page|
    page.to_hash
  end
end


