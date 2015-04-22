ActiveAdmin.register ActsAsTaggableOn::Tag, as: 'Tag' do
  permit_params :id, :name
end
