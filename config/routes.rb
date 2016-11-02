Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  match '/404', to: 'errors#file_not_found', via: :all
  match '/422', to: 'errors#unprocessable_entity', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all

  root 'blog/posts#index'

  # @note for legacy redirects from old blog which didn't have /blog prefix in route
  # GET /2015/01/31/post-title
  # # => 301 redirect to /blog/2015/01/31/post-title
  get '/:year/:month/:day/:id', to: redirect('/blog/%{year}/%{month}/%{day}/%{id}')
  namespace :blog do
    # GET /blog
    # GET /blog/:name-of-the-article
    resources :posts, path: '', only: [:index, :show]

    # GET /blog/2015/01/31/post-title
    # @note
    #   this route introduces an issue where you can access a Blog::Post with any year/month/day
    #   params as long as you have the correct :id
    get '/:year/:month/:day/:id' => 'posts#show', as: 'permalink'
  end

  resources :contact_forms, only: [:create]

  namespace :api do
    namespace :v1 do
      # GET /api/v1/stream
      resources :stream, only: [:index] do
        collection do
          get :instagram
          get :flickr
        end
      end
    end
  end

  # /sitemap.xml.gz
  get 'sitemap.xml.gz' => redirect('https://benradler.s3.amazonaws.com/sitemaps/sitemap.xml.gz')
end
