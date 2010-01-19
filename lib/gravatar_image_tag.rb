module GravatarImageTag

  def self.included(base)
    base.cattr_accessor :default_gravatar_filetype, :default_gravatar_image,
      :default_gravatar_rating, :default_gravatar_size,  :secure_gravatar
    base.send :include, InstanceMethods
  end

  module InstanceMethods

    def gravatar_image_tag(email, options = {})
      options[:src] = gravatar_url( email, options.delete( :gravatar ) )
      options[:alt] ||= 'Gravatar'
      tag 'img', options, false, false # Patch submitted to rails to allow image_tag here https://rails.lighthouseapp.com/projects/8994/tickets/2878-image_tag-doesnt-allow-escape-false-option-anymore
    end

    def gravatar_url(email, overrides)
      overrides ||= {}
      gravatar_params = {
        :default     => ActionView::Base.default_gravatar_image,
        :filetype    => ActionView::Base.default_gravatar_filetype,
        :rating      => ActionView::Base.default_gravatar_rating,
        :secure      => ActionView::Base.secure_gravatar,
        :size        => ActionView::Base.default_gravatar_size
      }.merge(overrides).delete_if { |key, value| value.nil? }
      "#{gravatar_url_base(gravatar_params.delete(:secure))}/#{gravatar_id(email, gravatar_params.delete(:filetype))}#{url_params(gravatar_params)}"
    end

    private

      def gravatar_url_base(secure = false)
        'http' + (!!secure ? 's://secure.' : '://') + 'gravatar.com/avatar'
      end

      def gravatar_id(email, filetype = nil)
        "#{ Digest::MD5.hexdigest(email) }#{ ".#{filetype}" unless filetype.nil? }"
      end

      def url_params(gravatar_params)
        return nil if gravatar_params.keys.size == 0
        "?#{gravatar_params.map { |key, value| "#{key}=#{URI.escape(value.is_a?(String) ? value : value.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"}.join('&')}"
      end

  end

end

ActionView::Base.send(:include, GravatarImageTag)
