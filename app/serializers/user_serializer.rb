class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :status, :role, :created_at, :updated_at, :auth_token
end