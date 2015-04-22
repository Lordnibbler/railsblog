ActiveAdmin.register Blog::Post do
  # @see permitted parameters documentation
  #   https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  permit_params(
    :title,
    :body,
    :published,
    :created_at,
    :updated_at,
    :user_id,
    :featured_image_url,
    # :tag_list,
    tag_list: [:id, :name]
  )

  form partial: 'form'

  index do
    id_column
    column :title
    column :user
    column :published
    column :created_at
    actions
  end
end
