Rails.application.routes.draw do
  get '/', to: 'index#show'
  get '/metrics', to: 'index#metrics'
  get '/reset', to: 'index#reset'
  get '/:slug', to: 'index#show'
end
