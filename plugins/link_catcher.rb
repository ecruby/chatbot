

class LinkCatcher
  
  include Cinch::Plugin
  
  def initialize(*args)
     super
     @karma_points = {}
   end
  
  match /(https?:\/\/([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)/, method: :link
  
  def link(m, url)
    m.reply "I got a URL to #{url}"
  end
  
  def write(link)
    Tumblr::API.write(email, password) do
      regular("test body", "test title")
      quote("test quote", "test source")
      link("http://tumblr.dynamic-semantics.com", "test link")
    end
  end
  
end


  