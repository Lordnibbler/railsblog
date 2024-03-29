ActiveAdmin.register User do
  permit_params :email, :name, :password, :password_confirmation, :avatar_url, :biography

  index do
    selectable_column
    id_column
    column :email
    column :name
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs 'Admin Details' do
      f.input :email
      f.input :name
      f.input :password
      f.input :password_confirmation
      f.input :avatar_url
      f.input :biography
    end
    f.actions
  end
end
