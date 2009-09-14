module GravitarImageTag
  
  GRAVITAR_BASE_URL = 'http://www.gravatar.com/avatar.php'
  
  def gravitar_image_tag(email, options = {})
    image_tag gravitar_url(email, options.delete(:gravitar)), options
  end
  
  def gravitar_url(email, overrides)
    "#{GRAVITAR_BASE_URL}?gravatar_id=#{email.md5}"
  end
  
end