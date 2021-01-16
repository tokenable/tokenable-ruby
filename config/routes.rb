Tokenable::Engine.routes.draw do
  post '/', to: 'tokens#create'
end
