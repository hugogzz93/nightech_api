require 'api_constraints'
Rails.application.routes.draw do

  mount SabisuRails::Engine => "/sabisu_rails"
  devise_for :users, skip: :registrations
  namespace :api, defaults: { format: :json },
                                constraints: { subdomain: 'api' }, path: '/'  do
    scope module: :v1,
            constraints: ApiConstraints.new(version: 1, default: true) do

      resources :users, only: [:show, :create, :update, :destroy, :index]
      resources :sessions, :only => [:create, :destroy]
      resources :representatives, only: [:show, :index, :create, :update, :destroy]
      resources :reservations, only: [:index, :update, :destroy, :create]
      resources :services, only: [:index, :create, :update, :destroy]
      resources :tables, only: [:index]
    end
  end
end
