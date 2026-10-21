class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  # ... kitas kodas palikite kaip yra
end