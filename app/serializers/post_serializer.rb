class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :link, :core, :status, :owners, :visibility

  def owners
    users = self.object.users
    (users.map { |user| 
    {
      first_name: user.first_name,
      last_name: user.last_name,
      email: user["email"],
      id: user["id"]
    }
    })
  end
end
