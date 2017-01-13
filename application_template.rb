remove_file 'Gemfile'
run 'touch Gemfile'

# Rails 5
gem 'rails', '~> 5.0.1'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'

gem 'meta_tags'
gem 'secure_headers'

gem 'font-awesome-rails'
gem 'bootstrap', '~> 4.0.0.alpha5'

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
  gem 'timecop'
  gem 'shoulda'
end

gem_group :development do
  gem 'web-console', '>= 3.3.0'
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
      @import "bootstrap";
      EOF
    end

    remove_file 'app/assets/javascripts/application.js'
    create_file 'app/assets/javascripts/application.js' do
      <<-EOF
      //= require jquery
      //= require jquery_ujs
      //= require bootstrap-sprockets
      //= require turbolinks
      //= require_tree .
      //= require_self
      EOF
    end

    create_file 'app/config/initializers/secure_headers.rb' do
      <<-EOF
      SecureHeaders::Configuration.default do |config|
        config.csp = SecureHeaders::OPT_OUT
        config.x_frame_options = SecureHeaders::OPT_OUT
        config.x_content_type_options = SecureHeaders::OPT_OUT
        config.x_xss_protection = SecureHeaders::OPT_OUT
        config.x_download_options = SecureHeaders::OPT_OUT
        config.x_permitted_cross_domain_policies = SecureHeaders::OPT_OUT
        config.referrer_policy = SecureHeaders::OPT_OUT
        config.hsts = SecureHeaders::OPT_OUT
      end
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
          <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
          <%= csrf_meta_tags %>
          <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track': 'reload' %>
          <title>Bootstrap 101 Template</title>
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
