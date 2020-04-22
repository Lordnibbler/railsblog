Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  match '/404', to: 'errors#file_not_found', via: :all
  match '/422', to: 'errors#unprocessable_entity', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all

  root 'pages#show', id: 'hire-me', format: false

  #
  # @note for legacy redirects from old blog which didn't have /blog prefix in route
  # GET /2015/01/31/post-title
  # # => 301 redirect to /blog/2015/01/31/post-title
  #
  get '/:year/:month/:day/:id', to: redirect('/blog/%{year}/%{month}/%{day}/%{id}')
  namespace :blog do
    #
    # GET /blog
    # GET /blog/:name-of-the-article
    #
    resources :posts, path: '', only: [:index, :show]

    #
    # GET /blog/2015/01/31/post-title
    # @note
    #   this route introduces an issue where you can access a Blog::Post with any year/month/day
    #   params as long as you have the correct :id
    #
    get '/:year/:month/:day/:id' => 'posts#show', as: 'permalink'
  end

  #
  # custom controller for HighVoltage static pages
  #
  get "/pages/*id" => 'pages#show', as: :page, format: false

  #
  # POST for contact form
  #
  resources :contact_forms, only: [:create]

  #
  # /sitemap.xml.gz
  #
  get 'sitemap.xml.gz' => redirect('https://benradler.s3.amazonaws.com/sitemaps/sitemap.xml.gz')

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
