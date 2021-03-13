Admin.create(
  email: 'admin@admin.com',
  password: ENV['ADMIN_KEY']
  )

20.times do |number|
User.create!(
  email: "user#{number}@user.com",
  name: Gimei.first.hiragana,
  password: ENV['USER_KEY']
  )
end
