module GravatarImageTag

  GRAVATAR_BASE_URL = 'http://www.gravatar.com/avatar.php'

  def self.included(base)
    base.cattr_accessor :default_gravatar_image, :default_gravatar_size
    base.send :include, InstanceMethods
  end

  module InstanceMethods

    def gravatar_image_tag(email, options = {})
      options[:src] = gravatar_url( email, options.delete( :gravatar ) )
      options[:alt] ||= File.basename(options[:src], '.*').split('.').first.to_s.capitalize
      tag 'img', options, false, false # Patch submitted to rails to allow image_tag here https://rails.lighthouseapp.com/projects/8994/tickets/2878-image_tag-doesnt-allow-escape-false-option-anymore
    end

    def gravatar_url(email, overrides)
      overrides ||= {}
      url_params = {
        :default     => ActionView::Base.default_gravatar_image,
        :gravatar_id => Digest::MD5.hexdigest(email),
        :size        => ActionView::Base.default_gravatar_size
      }.merge(overrides).delete_if { |key, value| value.nil? }
      "#{GRAVATAR_BASE_URL}?#{url_params.map { |key, value| "#{key}=#{URI.escape(value.is_a?(String) ? value : value.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"}.join('&')}"
    end

  end

end
