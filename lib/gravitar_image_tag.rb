module GravitarImageTag
  
  GRAVITAR_BASE_URL = 'http://www.gravatar.com/avatar.php'
  
  def self.included(base)
    base.cattr_accessor :default_gravitar_image, :default_gravitar_size
    base.send :include, InstanceMethods
  end
  
  module InstanceMethods
  
    def gravitar_image_tag(email, options = {})
      image_tag gravitar_url(email, options.delete(:gravitar)), options
    end
  
    def gravitar_url(email, overrides)
      overrides ||= {}
      url_params = {
        :default     => ActionView::Base.default_gravitar_image,
        :gravatar_id => Digest::MD5.hexdigest(email),
        :size        => ActionView::Base.default_gravitar_size
      }.merge(overrides).delete_if { |key, value| value.nil? }
      "#{GRAVITAR_BASE_URL}?#{url_params.map { |key, value| "#{key}=#{URI.escape(value.is_a?(String) ? value : value.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"}.join('&')}"
    end
    
  end
  
end