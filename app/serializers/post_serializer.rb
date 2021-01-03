class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :link, :core, :status, :author, :visibility

  def author
    user = self.object.user
    {
      first_name: user.first_name,
      last_name: user.last_name,
      email: user["email"],
      id: user["id"]
    }
  end
end
