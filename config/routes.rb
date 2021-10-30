Rails.application.routes.draw do
  get '/', to: 'index#show'
  get '/metrics', to: 'index#metrics'
  get '/reset', to: 'index#reset'
  get '/:slug', to: 'index#show'
  get '/check.txt', to: proc {[200, {}, ['it_works']]} # for dokku
end
