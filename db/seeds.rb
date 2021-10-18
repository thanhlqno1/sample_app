User.create!(name: "Thanh Le",
             email: "thanh.lq011299@gmail.com",
             password: "foobar",
             password_confirmation: "foobar",
             admin: true,
             activated: true,
             activated_at: Time.zone.now)

20.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now)
end

users = User.order(:created_at).take(4)
20.times do |n|
created_at = n.minutes.ago
content = Faker::Lorem.sentence(word_count: 5)
users.each {|user| user.microposts.create(content: content,
                                           created_at: created_at)}
end

users = User.all
users.each {|user| user.follow users.excluding(user)}
