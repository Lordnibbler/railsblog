ActiveAdmin.register Blog::Post do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  permit_params :title, :body, :published, :created_at, :updated_at, :user_id
  form partial: 'form'
end
