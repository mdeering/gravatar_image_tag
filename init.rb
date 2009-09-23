require File.dirname(__FILE__) + '/lib/gravatar_image_tag'

ActionView::Base.send(:include, GravatarImageTag)
