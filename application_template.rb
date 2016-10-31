remove_file 'Gemfile'
run 'touch Gemfile'
add_source 'https://rubygems.org'

# Rails 5
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'

gem 'meta_tags'

gem 'font-awesome-rails'
gem 'bootstrap-sass'

gem 'devise'
gem 'pundit'

gem 'capistrano'
gem 'capistrano-rails'
gem 'capistrano-rvm'
gem 'capistrano-unicorn-nginx'

gem 'whenever', require: false

gem_group :development, :test do
  gem 'byebug', platform: :mri
  gem 'rspec-rails'
  gem 'guard-rspec'
  gem 'pry-byebug'
  gem 'factory_girl_rails'
  gem 'annotate'
  gem 'ffaker'
end

gem_group :development do
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

after_bundle do
    rails_command('db:create')
    rails_command('db:migrate')

    run 'spring stop'
    generate 'rspec:install'
    run 'guard init'

    generate(:controller, 'home index')

    # bootstrap
    remove_file 'app/assets/stylesheets/application.css'
    create_file 'app/assets/stylesheets/application.scss' do
      <<-EOF
      @import "bootstrap-sprockets";
      @import "bootstrap";
      EOF
    end

    remove_file 'app/assets/javascripts/application.js'
    create_file 'app/assets/javascripts/application.js' do
      <<-EOF
      //= require jquery
      //= require bootstrap-sprockets
      EOF
    end

    # Devise
    generate 'devise:install'
    environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: 'development'
    generate 'devise User'
    rails_command('db:migrate')

    # Add Rspec Helpers for devise

    # Pundit
    generate 'pundit:install'

    route "root to: 'home#index'"

    remove_file 'app/views/layouts/application.html.erb'
    create_file 'app/views/layouts/application.html.erb' do
      <<-EOF
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <meta http-equiv="X-UA-Compatible" content="IE=edge">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
          <title>Bootstrap 101 Template</title>

          <%= csrf_meta_tags %>

          <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track': 'reload' %>
        </head>
        <body>
          <%= yield %>

          <%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>
        </body>
      </html>
      EOF
    end

    capify!

    git :init
    git add: '.'
    git commit: %( -m 'Initial commit' )
end
