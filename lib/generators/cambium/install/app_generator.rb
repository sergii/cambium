require 'rake'
require 'rails/generators'

module Cambium
  module Install
    class AppGenerator < Rails::Generators::Base
      desc "Setup app files for new rails project"

      source_root File.expand_path('../../templates', __FILE__)

      # ------------------------------------------ Default Public Controller

      def add_home_controller
        run_cmd "#{g} controller home index"
      end

      # ------------------------------------------ Routes

      def add_default_routes
        remove_file "config/routes.rb"
        template "config/routes.rb.erb", "config/routes.rb"
      end

      # ------------------------------------------ Public Views

      def add_public_views
        directory "app/views/application", "app/views/application"
      end

      # ------------------------------------------ Layouts

      def add_layouts
        @site_title = Rails.application.class.parent_name.humanize.titleize
        site_title = ask "\n#{set_color('App Title:', :green, :bold)} [default: #{@site_title}]"
        @site_title = site_title unless site_title.blank?
        
        app = "app/views/layouts/application.html.erb"
        remove_file app
        template app, app
      end

      # ------------------------------------------ Install Backbone

      def install_backbone
        directory "app/assets/javascripts/backbone",
          "app/assets/javascripts"
      end

      def default_application_js
        app_js = "app/assets/javascripts/application.js"
        remove_file app_js
        template app_js, app_js
      end

      # ------------------------------------------ Add Modernizr

      def add_modernizr
        modernizr = "vendor/assets/javascripts/modernizr.js"
        copy_file modernizr, modernizr
      end

      # ------------------------------------------ Public Styles

      def add_public_manifest
        ['css','scss','scss.css'].each { |ext| remove_file "app/assets/stylesheets/application.#{ext}" }
        template "app/assets/stylesheets/application.scss", 
          "app/assets/stylesheets/application.scss"
      end

      # ------------------------------------------ Add Modernizr

      def add_normalize
        normalize = "vendor/assets/stylesheets/normalize.scss"
        template normalize, normalize
      end

      # ------------------------------------------ Create Default User

      def add_default_user
        if defined?(User) == 'constant' && User.class == Class 
          create_user
        else
          output = "\nUser model does not exist yet. If you want to add a user, run:\n"
          say set_color(output, :red, :bold)
          say "   bundle exec rake cambium:install:users\n\n" 
          output = "then re-run this generator."
          say set_color(output, :red, :bold)
        end
      end

      # ------------------------------------------ Private Methods

      private

        def run_cmd(cmd, options = {})
          print_table(
            [
              [set_color("run", :green, :bold), cmd]
            ],
            :indent => 9
          )
          if options[:quiet] == true
            `#{cmd}`
          else
            system(cmd)
          end
        end

        def template_file(name)
          File.expand_path("../../templates/#{name}", __FILE__)
        end

        def file_contents(template)
          File.read(template_file(template))
        end

        def be
          "bundle exec"
        end

        def g
          "#{be} rails g"
        end

        def rake
          "#{be} rake"
        end

        def confirm_ask(question)
          answer = ask("\n#{question}")
          match = ask("CONFIRM #{question}")
          if answer == match
            answer
          else
            say set_color("Did not match.", :red)
            confirm_ask(question)
          end
        end

        def create_user
          email = confirm_ask "#{set_color('Default User Email', :green, :bold)}:"
          password = confirm_ask "#{set_color('Default User Password', :green, :bold)}:"
          u = User.new(
            :email => email,
            :password => password, 
            :password_confirmation => password,
          )
          u.is_admin = true if u.respond_to?(:is_admin)
          if u.save
            say "User created successfully!"
          else
            create_user
          end
        end

    end
  end
end
