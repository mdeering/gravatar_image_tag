module GravatarImageTag

  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  class Configuration
     attr_accessor :default_image, :filetype, :include_size_attributes, :rating, :size, :secure

     def initialize
        @include_size_attributes = true
     end

  end

  def self.included(base)
    GravatarImageTag.configure { |c| nil }
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    def default_gravatar_filetype=(value)
      warn "DEPRECATION WARNING: configuration of filetype= through this method is deprecated! Use the block configuration instead. http://github.com/mdeering/gravatar_image_tag"
      GravatarImageTag.configure do |c|
        c.filetype = value
      end
    end
    def default_gravatar_image=(value)
      warn "DEPRECATION WARNING: configuration of default_gravatar_image= through this method is deprecated! Use the block configuration instead. http://github.com/mdeering/gravatar_image_tag"
      GravatarImageTag.configure do |c|
        c.default_image = value
      end
    end
    def default_gravatar_rating=(value)
      warn "DEPRECATION WARNING: configuration of default_gravatar_rating= through this method is deprecated! Use the block configuration instead. http://github.com/mdeering/gravatar_image_tag"
      GravatarImageTag.configure do |c|
        c.rating = value
      end
    end
    def default_gravatar_size=(value)
      warn "DEPRECATION WARNING: configuration of default_gravatar_size= through this method is deprecated! Use the block configuration instead. http://github.com/mdeering/gravatar_image_tag"
      GravatarImageTag.configure do |c|
        c.size = value
      end
    end
    def secure_gravatar=(value)
      warn "DEPRECATION WARNING: configuration of secure_gravatar= through this method is deprecated! Use the block configuration instead. http://github.com/mdeering/gravatar_image_tag"
      GravatarImageTag.configure do |c|
        c.secure = value
      end
    end
  end

  module InstanceMethods

    def gravatar_image_tag(email, options = {})
      gravatar_overrides = options.delete(:gravatar)
      email = email.strip.downcase if email.is_a? String
      options[:src] = GravatarImageTag::gravatar_url(email, gravatar_overrides)
      options[:alt] ||= 'Gravatar'
      options[:height] = options[:width] = "#{GravatarImageTag::gravatar_options(gravatar_overrides)[:size] || 80}" if GravatarImageTag.configuration.include_size_attributes
      tag 'img', options, false, false # Patch submitted to rails to allow image_tag here https://rails.lighthouseapp.com/projects/8994/tickets/2878-image_tag-doesnt-allow-escape-false-option-anymore
    end

  end

  def self.gravatar_url(email, overrides = {})
    gravatar_params = gravatar_options(overrides || {})
    "#{gravatar_url_base(gravatar_params.delete(:secure))}/#{gravatar_id(email, gravatar_params.delete(:filetype))}#{url_params(gravatar_params)}"
  end

  private

    def self.gravatar_options(overrides = {})
      {
        :default     => GravatarImageTag.configuration.default_image,
        :filetype    => GravatarImageTag.configuration.filetype,
        :rating      => GravatarImageTag.configuration.rating,
        :secure      => GravatarImageTag.configuration.secure,
        :size        => GravatarImageTag.configuration.size
      }.merge(overrides || {}).delete_if { |key, value| value.nil? }
    end

    def self.gravatar_url_base(secure = false)
      'http' + (!!secure ? 's://secure.' : '://') + 'gravatar.com/avatar'
    end

    def self.gravatar_id(email, filetype = nil)
      "#{ Digest::MD5.hexdigest(email) }#{ ".#{filetype}" unless filetype.nil? }" unless email.nil?
    end

    def self.url_params(gravatar_params)
      return nil if gravatar_params.keys.size == 0
      "?#{gravatar_params.map { |key, value| "#{key}=#{URI.escape(value.is_a?(String) ? value : value.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"}.join('&amp;')}"
    end

end

ActionView::Base.send(:include, GravatarImageTag) if defined?(ActionView::Base)
