# frozen_string_literal: true

Tokenable::Engine.routes.draw do
  post '/', to: 'tokens#create'
end
