# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

[
  {name: 'День прошёл не зря', slug: 'good_day', description: 'Выпить минимум один раз за день'},
  {name: 'Читать и бухать лучше одновременно', slug: 'drink_and_read', description: 'Прочитать книгу и выпить в один день'},
  {name: 'Ни шагу назад!', slug: 'non_stop', description: 'Выпить за день больше 3 раз'},
].each do |achievement|
  Achievement.where(slug: achievement[:slug]).first_or_create(name: achievement[:name], description: achievement[:description])
end