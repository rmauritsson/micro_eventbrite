Set Up
Create rails app using rails new micro_eventbrite
Move into directory and install the gems using bundle install
Set up code linters
Add the bootstrap gem in your gemfile using gem 'bootstrap-sass', '3.3.7'

Although rails generate automatically creates a separate CSS file for each controller, it’s surprisingly hard to include them all properly and in the right order, so for simplicity we’ll put all of the CSS needed for this tutorial in a single file. The first step toward getting custom CSS to work is to create such a custom CSS file:
Inside the file for the custom CSS, we can use the @import function to include Bootstrap (together with the associated Sprockets utility)

app/assets/stylesheets/custom.scss
@import "bootstrap-sprockets";
@import "bootstrap";

Create a headers partial and add the following code
<header class="navbar navbar-fixed-top navbar-inverse">
  <div class="container">
    <%= link_to "sample app", '#', id: "logo" %>
    <nav>
      <ul class="nav navbar-nav navbar-right">
        <li><%= link_to "Home",   '#' %></li>
        <li><%= link_to "Help",   '#' %></li>
        <li><%= link_to "Log in", '#' %></li>
      </ul>
    </nav>
  </div>
</header>


Users
Following the conventional REST architecture favored by Rails, we’ll create the  controller for users using $ rails generate controller Users new show create

Create a user model using rails generate model User name:string email:string and then rails db:migrate

Validating the user model and the uniqueness of email addresses

app/models/user.rb
class User < ApplicationRecord
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
end

Generating the User model automatically created a new migration, we are adding structure to an existing model, so we need to create a migration directly using the migration generator:

rails generate migration add_index_to_users_email

Unlike the migration for users, the email uniqueness migration is not pre-defined, so we need to fill in its contents to enforce email uniqueness

db/migrate/[timestamp] add_index_to_users
class AddIndexToUsersEmail < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :email, unique: true
  end
end

This uses a Rails method called add_index to add an index on the email column of the users table. The index by itself doesn’t enforce uniqueness, but the option unique: true does.
The final step is to migrate the database:
$ rails db:migrate
we’ll use a before_save callback to downcase the email attribute before saving the user
class User < ApplicationRecord
  before_save { self.email = email.downcase }
…...
end
Now we shall add a secure password, we first generate an appropriate migration for the password_digest column using

rails generate migration add_password_digest_to_users password_digest:string

Then

rails db:migrate

To make the password digest, has_secure_password uses a state-of-the-art hash function called bcrypt. We need to add the bcrypt gem to our Gemfile

Add gem 'bcrypt', '3.1.12' ,then run bundle install as usual.

 Add has_secure_password to the User model
app/models/user.rb
class User < ApplicationRecord
  before_save { self.email = email.downcase }
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
end
Add a  minimum length constraint to the password validations in the user model
validates :password, length: { minimum: 6 }
In order to get the user show view to work, we need to define an @user variable in the corresponding show action in the Users controller.
app/controllers/users_controller.rb
class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
  end

  def new
  end
end

We’ll now flesh it out a little with a profile image for each user and the first cut of the user sidebar.

Add this to the app/views/users/show.html.erb

<% provide(:title, @user.name) %>
<h1>
  <%= gravatar_for @user %>
  <%= @user.name %>
</h1>

By default, methods defined in any helper file are automatically available in any view, but for convenience we’ll put the gravatar_for method in the file for helpers associated with the Users controller.

app/helpers/users_helper.rb
module UsersHelper

  # Returns the Gravatar for the given user.
  def gravatar_for(user)
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
End

We’ll display the profile picture and name in the sidebar of the website and we’ll implement it using the aside tag, We include row and col-md-4 classes, which are both part of Bootstrap.
app/views/users/show.html.erb
<% provide(:title, @user.name) %>
<div class="row">
  <aside class="col-md-4">
    <section class="user_info">
      <h1>
        <%= gravatar_for @user %>
        <%= @user.name %>
      </h1>
    </section>
  </aside>
</div>

We are now creating a new user using the sign up form,
app/controllers/users_controller.rb
class UsersController < ApplicationController
  def new
    @user = User.new
  end
end

Create a form in app/views/users/new.html.erb

% provide(:title, 'Sign up') %>
<h1>Sign up</h1>

<div class="row">
  <div class="col-md-6 col-md-offset-3">
    <%= form_for(@user, url: signup_path)do |f| %>
      <%= f.label :name %>
      <%= f.text_field :name %>

      <%= f.label :email %>
      <%= f.email_field :email %>

      <%= f.label :password %>
      <%= f.password_field :password %>

      <%= f.label :password_confirmation, "Confirmation" %>
      <%= f.password_field :password_confirmation %>

      <%= f.submit "Create my account", class: "btn btn-primary" %>
    <% end %>
  </div>
</div>

Next, we want to require the params hash to have a :user attribute, and we want to permit the name, email, password, and password confirmation attributes (but no others).
app/controllers/users_controller.rb
class UsersController < ApplicationController
  .
  def create
    @user = User.new(user_params)
    if @user.save
      # Handle a successful save.
    else
      render 'new'
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
end

At this point, the signup form doesn’t display any feedback on invalid submissions (apart from the development-only debug area), which is potentially confusing.
Create a new app/views/shared directory using
mkdir app/views/shared

Then create the error_messages.html.erb partial file
app/views/shared/error_messages.html.erb
<% if @user.errors.any? %>
  <div id="error_explanation">
    <div class="alert alert-danger">
      The form contains <%= pluralize(@user.errors.count, "error") %>.
    </div>
    <ul>
    <% @user.errors.full_messages.each do |msg| %>
      <li><%= msg %></li>
    <% end %>
    </ul>
  </div>
<% end %>
Now Redirect to a different page instead when the creation is successful. app/controllers/users_controller.rb
class UsersController < ApplicationController
  .
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # Log the user in and redirect to the user's show page.
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    End
End

Add to app/views/layouts/application.html.erb
<% flash.each do |message_type, message| %>
  <div class="alert alert-<%= message_type %>"><%= message %></div>
<% end %>

Now that new users can sign up, it’s time to give them the ability to log in and log out. To get started, we’ll generate a Sessions controller with a new action

$ rails generate controller Sessions new

Having defined the relevant controller and route, now we’ll fill in the view for new sessions, i.e., the login form.
app/views/sessions/new.html.erb
<% provide(:title, "Log in") %>
<h1>Log in</h1>

<div class="row">
  <div class="col-md-4 col-md-offset-4">
    <%= form_for(:session, url: login_url) do |f| %>

      <%= f.label :email %>
      <%= f.email_field :email, class: 'form-control' %>

      <%= f.label :password %>
      <%= f.password_field :password, class: 'form-control' %>

      <%= f.submit "Log in", class: "btn btn-primary" %>
    <% end %>

    <p>New user? <%= link_to "Sign up now!", signup_url %></p>
  </div>
</div>


Next, we are going to include sessions in our authentication
app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
end
Place a temporary cookie on the user’s browser containing an encrypted version of the user’s id, which allows us to retrieve the id on subsequent pages using session[:user_id]. We are also going to find the logged in user (if any) and return their id

app/helpers/sessions_helper.rb
module SessionsHelper

  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
  end
end
The next step involves changing the layout links based on login status.
<% if logged_in? %>
  <li><%= link_to "Create Event", '#' %></li>
  <li><%= link_to "Log out", logout_url %></li>
<% else %>
  # Links for non-logged-in-users
<% end %>

By now our site is able to register and login a user
Events
Step 1 Build and migrate your Event model
rails generate controller Event new

rails generate model Event location:string desc:text date:date

rails db:migrate

We then add the association between the event creator (a User) and the event. Call this user the "creator".
app/models/event.rb
class Event < ApplicationRecord
  belongs_to :creator, class_name: ‘User’
end
Add the foreign key to the Events model
rails generate migration AddCreatorToEvents creator_id:integer
Also add the index to the migration
add_index :events, :creator_id

Then run in terminal
rails db:migrate

User's Show page to list all users events
 <% if @user.events.any? %>
    <h3>Submitted (<%= @user.events.count %>) events</h3>
    <ul class="media-list">
      <%= render @events %>
    </ul>
    <%= will_paginate @events %>
  <% else %>
    <h3>No Events Found</h3>
  <% end %>

The above renders the event from app/views/events/event.html.erb
<li class="media">
  <div class="media-left">
    <a href="#"><%= gravatar_for user, size: 50 %></a>
  </div>
  <div class="media-body">
    <h4 class="media-heading">Media heading</h4>
  </div>
</li>

Create the Events Controller and routes
rails generate controller Events
rails generate migration add_desc_to_events description:text

rails db:migrate

Do all the normal CRUD actions and views.
rails generate migration add_title_to_events title:string

rails db:migrate
