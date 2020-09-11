# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

[
  {name: 'День прошёл не зря', slug: 'good_day', description: 'Выпить минимум один раз за день'},
  {name: 'Читать и бухать лучше одновременно', slug: 'drink_and_read', description: 'Прочитать книгу и выпить в один день'},
  {name: 'Ни шагу назад!', slug: 'non_stop', description: 'Выпить за день больше 3 раз'},
].each do |achievement|
  Achievement.where(slug: achievement[:slug]).first_or_create(name: achievement[:name], description: achievement[:description])
end

%w(
  https://derpicdn.net/img/2019/12/13/2219723/large.png
  https://derpicdn.net/img/view/2019/11/13/2194487.png
  https://derpicdn.net/img/view/2020/7/26/2407989.png
  https://derpicdn.net/img/2020/7/7/2392984/large.jpg
  https://derpicdn.net/img/view/2018/10/17/1859022.png
  https://derpicdn.net/img/2020/9/8/2440672/large.png
  https://derpicdn.net/img/2020/8/21/2427826/large.png
  https://derpicdn.net/img/2020/8/18/2426019/large.jpg
  https://derpicdn.net/img/2020/8/15/2423769/large.jpg
  https://derpicdn.net/img/2020/8/12/2421554/large.png
  https://derpicdn.net/img/view/2020/6/24/2382580.jpg
  https://derpicdn.net/img/view/2020/6/8/2369648.png
  https://derpicdn.net/img/2020/4/15/2323542/large.jpg
  https://derpicdn.net/img/2020/4/1/2311471/large.jpg
  https://derpicdn.net/img/view/2020/3/28/2307862.jpg
  https://derpicdn.net/img/view/2020/1/31/2261563.png
).each do |url|
  Image.where(url: url).first_or_create
end

Message.where(slug: 'rules').first_or_create(content: 'Здесь будет справка')