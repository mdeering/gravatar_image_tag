require File.dirname(__FILE__) + '/lib/gravitar_image_tag'

ActionView::Base.send(:include, GravitarImageTag)
