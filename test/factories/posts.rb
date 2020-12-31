FactoryBot.define do  
  factory :post do  
    title { Faker::Lorem.sentence }  
    content { Faker::Lorem.paragraph }  
    link { Faker::Internet.url }  
    status {   
      r = rand(0..2)  
      if r == 0  
        "pending"  
      elsif r == 1  
        "published"  
      elsif r == 2  
        "deleted"  
      end  
     }  
    visibility {  
      r = rand(0..1)  
      if r == 0  
        "public"  
      elsif r == 1  
        "private"  
      end 
     }  
     core {  
      r = rand(0..3)  
      if r == 0  
        "note"  
      elsif r == 1  
        "task"  
      elsif r == 2  
        "link"  
      elsif r == 3  
        "article"  
      end  
     }  
    user  
  end  
  factory :published_post, class: "Post" do  
    title { Faker::Lorem.sentence }  
    content { Faker::Lorem.paragraph }  
    link { Faker::Internet.url }  
    status { "published" }  
    core {  
      r = rand(0..3)  
      if r == 0  
        "note"  
      elsif r == 1  
        "task"  
      elsif r == 2  
        "link"  
      elsif r == 3  
        "article"  
      end  
     }  
    visibility {  
      r = rand(0..1)  
      if r == 0  
        "public"  
      elsif r == 1  
        "private"  
      end  
    }  
    user  
  end 
end  