Facepalm
===========

Provides a set of classes, methods, and helpers to ease development of Facebook applications with Rails.

Installation
------------

In order to install Facepalm you should add it to your Gemfile:

    gem 'facepalm'

Usage
-----

**Requesting Permissions**

Facepalm makes it simple to require Facebook authentication to access certain controller actions. You can require user to provide certain permissions to your application:

    class PostsController < ApplicationController
      facepalm_authentication :email, :publish_actions, :only => :index

      def index
        ...
      end
    end

This code will redirect user to Facebook permission request page if user wasn't authenticated yet.

You can also check user authentication right in your action code and request certain permission if necessary:

    class PostsController < ApplicationController
      facepalm_authentication :email, :publish_actions, :only => :index

      def edit
        if facepalm_require_authentication(:email)
          ...
        end
      end
    end

**Accessing Current User**

Current Facebook user data can be accessed using the ```current_facebook_user``` method:

    class UsersController < ApplicationController
      def profile
        @user = User.find_by_facebook_id(current_facebook_user.uid)
      end
    end

This method is also accessible as a view helper.

**Application Configuration**

In order to use Facepalm you should set a default configuration for your Facebook application. The config file should be placed at RAILS_ROOT/config/facebook.yml

Sample config file:

    development:
      app_id: ...
      secret: ...
      namespace: your-app-namespace
      callback_domain: yourdomain.com

    test:
      app_id: ...
      secret: ...
      namespace: test
      callback_domain: callback.url

All these attributes attributes can be obtained or defined in your application settings at the [Facebook developer page](https://developers.facebook.com/apps).

Default configuration will be automatically loaded at the first request and won't reload. If you want to change application settings you should restart your application server instance.

Default configuration can be accessed from any parts of your code:

    Facepalm::Config.default # => #<Facepalm::Config:0x108c03f38 @config={:secret=>"...", :namespace=>"...", :callback_domain=>"...", :app_id=>...}>

Current configuration is also accessible as a ```facepalm``` method in your controller. You can override this method to provide application configuration on a per-request basis:

    class PostsController < ApplicationController
      def current_fb_app
        FbApp.find_by_app_id(params[:app_id])
      end

      def facepalm
        if current_fb_app
          Facepalm::Config.new(current_fb_app.attributes)
        else
          Facepalm::Config.default
        end
      end
    end

Credits
-------

Big thanks to authors of the Facebooker2 plugin for inspiring me to develop this piece of software. I also copied some code snippets from this project so big thanks to everyone who put their effort to develop Facebooker2.


Copyright & License
-------------------

Copyright (c) 2011-2012 Aleksey V. Dmitriev.It is free software, and may be redistributed under the terms specified in the LICENSE file.