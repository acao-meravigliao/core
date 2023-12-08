Rails.application.routes.draw do
  namespace :ygg do
    namespace :streaming do
      hel_resources :channels, controller: 'channel/rest' do
        member do
          post :request_deletion

          post :replicas_force
        end
      end
    end
  end

end
