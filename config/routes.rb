Rails.application.routes.draw do
  root "stores#index"

  resources :stores, shallow: true do
    resources :articles do
      collection do
        get :import_form
        post :import
      end
    end
    resources :aisles, shallow: true do
      resources :sections, shallow: true do
        resources :levels
      end
    end
  end
end
