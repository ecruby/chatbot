require 'net/http'
require 'json'
require 'cgi'

class ImageMe

  include Cinch::Plugin

  match /(image|img)( me)? (.*)/i, :method => :image_me

  match /animate( me)? (.*)/i, :method => :animate_me

  match /(?:mo?u)?sta(?:s|c)he?(?: me)? (.*)/i, :method => :stash_me

  def image_me(m, *args)
    m.reply get_link(args[2])
  end

  def animate_me(m, *args)
    m.reply get_link(args[1], true)
  end

  def stash_me(m, query)
    source = /^https?:\/\//i.match(query) ? query : get_link(query)
    m.reply "http://mustachify.me/#{rand(3) + 1}?src=#{CGI::escape(source)}"
  end

  def get_link(query, animated=false)
    q = {:v => '1.0', :rsz => '8', :q => query, :safe => 'active'}
    q[:as_filetype] = 'gif' if animated
    url = 'http://ajax.googleapis.com/ajax/services/search/images?'
    params = q.collect { |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.join('&')
    http = Net::HTTP.new('ajax.googleapis.com', 80)
    request = Net::HTTP::Get.new("/ajax/services/search/images?#{params}")
    response = JSON.parse http.request(request).body
    if response["responseData"] and response["responseData"]["results"]
      response["responseData"]["results"].sample["unescapedUrl"]
    else
      "No image found."
    end
  end

end
