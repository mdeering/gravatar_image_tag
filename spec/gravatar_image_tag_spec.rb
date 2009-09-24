require File.dirname(__FILE__) + '/test_helper'

require 'gravatar_image_tag'

ActionView::Base.send(:include, GravatarImageTag)

describe GravatarImageTag do

  email                 = 'mdeering@mdeering.com'
  md5                   = '4da9ad2bd4a2d1ce3c428e32c423588a'
  default_image         = 'http://mdeering.com/images/default_gravatar.png'
  default_image_escaped = 'http%3A%2F%2Fmdeering.com%2Fimages%2Fdefault_gravatar.png'
  default_size          = 50
  other_image           = 'http://mdeering.com/images/other_gravatar.png'
  other_image_escaped   = 'http%3A%2F%2Fmdeering.com%2Fimages%2Fother_gravatar.png'

  view = ActionView::Base.new

  {
    { :gravatar_id => md5 } => {},
    { :gravatar_id => md5, :size => 30 } => { :gravatar => {:size => 30 } },
    { :gravatar_id => md5, :default => other_image_escaped } => { :gravatar => {:default => other_image } },
    { :gravatar_id => md5, :default => other_image_escaped, :size => 30 } => { :gravatar => {:default => other_image, :size => 30 } }
  }.each do |params, options|
    it "#gravatar_image_tag should create the provided url with the provided options #{options}"  do
      view = ActionView::Base.new
      image_tag = view.gravatar_image_tag(email, options)
      puts image_tag
      params.all? {|key, value| image_tag.include?("#{key}=#{value}")}.should be_true
    end
  end

  {
    :default_gravatar_image => default_image,
    :default_gravatar_size  => default_size
  }.each do |singleton_variable, value|
    it "should create gravatar class (singleton) variable #{singleton_variable} on its included class" do
      ActionView::Base.send(singleton_variable).should == nil
      ActionView::Base.send("#{singleton_variable}=", value)
      ActionView::Base.send(singleton_variable).should == value
    end
  end

  # Now that the defaults are set...
  {
    { :gravatar_id => md5, :size => default_size, :default => default_image_escaped } => {},
    { :gravatar_id => md5, :size => 30, :default => default_image_escaped } => { :gravatar => { :size => 30 }},
    { :gravatar_id => md5, :size => default_size, :default => other_image_escaped } => { :gravatar => {:default => other_image } },
    { :gravatar_id => md5, :size => 30, :default => other_image_escaped } => { :gravatar => { :default => other_image, :size => 30 }},
  }.each do |params, options|
    it "#gravatar_image_tag should create the provided url when defaults have been set with the provided options #{options}"  do
      view = ActionView::Base.new
      image_tag = view.gravatar_image_tag(email, options)
      params.all? {|key, value| image_tag.include?("#{key}=#{value}")}.should be_true
    end
  end

end
