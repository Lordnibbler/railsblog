ActiveAdmin.register Blog::Post do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  permit_params :title, :description, :body, :published, :created_at, :updated_at, :user_id, :featured_image_url, :featured_image, images: []
  form partial: 'form'

  index do
    id_column
    column :title
    column :user
    column :published
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :description
      row :published
      row :title
      row :body do |post|
        post.body.truncate(100)
      end
      row :created_at
      row :updated_at
      row :user
      row :slug
      row :featured_image_url
      row :featured_image do |post|
        if post.featured_image.attached?
          # full size original
          # link_to(image_tag(url_for(post.featured_image), width: 300), url_for(post.featured_image))

          # resized to 300 width max
          link_to(image_tag(url_for(post.featured_image.representation(resize_to_limit: [300, nil]).processed)), url_for(post))
        end
      end
      row :images do |post|
        div do
          post.images.each do |img|
            span do
              # full size original
              # link_to(image_tag(url_for(img), width: 200), url_for(img))

              # resized to 300 width max
              link_to(image_tag(url_for(img.representation(resize_to_limit: [300, nil]).processed)), url_for(img))
            end
            span do
              a "Delete", href: delete_image_admin_blog_post_path(img.id), "data-method": :delete, "data-confirm": "Are you sure?"
            end
          end
        end
      end
    end
  end

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end

  member_action :delete_image, method: :delete do
    @pic = ActiveStorage::Attachment.find(params[:id])
    @pic.purge_later
    redirect_back(fallback_location: edit_admin_blog_post_path)
  end
end
