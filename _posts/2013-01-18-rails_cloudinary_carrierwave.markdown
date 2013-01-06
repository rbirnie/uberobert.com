---
title: Using Cloudinary and CarrierWave for Rails Image Uploading
layout: default
author:
  name: Robert Birnie
  url: http://uberobert.com
---

I just finished adding [Cloudinary](http://cloudinary.com/) as my host for images uploaded on a test site of mine. It ties in cleanly with [CarrierWave](https://github.com/jnicklas/carrierwave) and removes the need for [RMagick](http://rmagick.rubyforge.org/) to be installed on the VPS. This was a great solution as the [RMagick gem](https://github.com/rmagick/rmagick) is no longer being maintained on github and the Cloudinary [free](http://cloudinary.com/plans) plan is quite reasonable for my usage.

## Installation 

To install Cloudinary was pretty simple. First add it and Carrier wave to your gemfile. 

{% highlight ruby %}
gem 'carrierwave'
gem 'cloudinary'
{% endhighlight %}

Then add the security settings for Cloudinary. These are found on your Cloudinary dashboard. 

{% highlight ruby %}
# config/cloudinary.yml
development:
  cloud_name: "sample"
  api_key: "874837483274837"
  api_secret: "a676b67565c6767a6767d6767f676fe1"

production:
  cloud_name: "sample"
  api_key: "874837483274837"
  api_secret: "a676b67565c6767a6767d6767f676fe1"
{% endhighlight %}

Now you are ready to add your CarrierWave uploader.

{% highlight bash %}
rails g uploader avatar
{% endhighlight %}

And add carrier wave to the new uploader. Also comment out the storage and store_dir lines as you aren't using local storage, but Cloudinary.

{% highlight ruby %}
# app/uploaders/avatar_uploader.rb

class AvatarUploader < CarrierWave::Uploader::Base

  include Cloudinary::CarrierWave

  # Choose what kind of storage to use for this uploader:
  # storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  # def store_dir
  #   "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  # end

end
{% endhighlight %}

Super!

## CarrierWave Setup

Now we can treat it like a normal CarrierWave setup. First add a migration to add the uploader to the model.

{% highlight bash %}
rails g migration add_avatar_to_user avatar:string
rake db:migrate
{% endhighlight %}

Now to add it into our model, form and view. 

{% highlight html %}
# app/models/user.rb
attr_accessible :avatar

mount_uploader :avatar, AvatarUploader


# app/views/users/_form.html.erb
<legend>Avatar</legend>
<%= f.file_field :avatar %>


# app/views/users/show.html.erb
<% unless @user.avatar_url.nil? %><%= image_tag @user.avatar_url %><br /><% end %>

{% endhighlight %}

Great! Now we are really rolling. You'll note that your images in the HTML pull from res.cloudinary.com rather than your app's URL, which is nice to save on bandwidth. 

## Transformations and Resizing

I also have gone and resized the images. I have two sizes, one for their profile and a mini one for when they show up in the users index. You can do all your transformations back in the image uploader. The :eager portion tells Cloudinary to do the resize at initial image save, rather than the first time the image is loaded. 

{% highlight ruby %}
# app/uploaders/avatar_uploader.rb

  version :display do
    process :eager => true
    process :resize_to_fill => [200, 200, :north]
  end

  version :thumbnail do
    process :eager => true
    process :resize_to_fit => [50, 50]
  end
{% endhighlight %}

You can then easily call the resized image from within the views.

{% highlight html %}
<%= image_tag @user.avatar_url(:display) %>
{% endhighlight %}

Cloudinary has a host of other transformation features, both all that CarrierWave supports and some that it does not. For more info check out their [documentation](http://cloudinary.com/documentation/rails_integration#carrierwave_custom_and_dynamic_transformations)

Have fun with all those images!