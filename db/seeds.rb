# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

%w(
  https://derpicdn.net/img/2019/9/3/2134998/large.jpeg
  https://derpicdn.net/img/2020/9/21/2449828/large.png
  https://derpicdn.net/img/2020/9/12/2443742/large.jpg
  https://derpicdn.net/img/2020/9/6/2439560/large.jpg
  https://derpicdn.net/img/2019/8/27/2129187/large.png
  https://derpicdn.net/img/2018/12/24/1917683/large.jpeg
  https://derpicdn.net/img/2017/3/9/1382987/large.png
).each do |url|
  Image.where(url: url).first_or_create
end

Message.where(slug: 'rules').first_or_create(content: Base64.decode64("0JPQvtC70L7RgdC+0LLRi9C1INGB0L7QvtCx0YnQtdC90LjRjyDQvdC1INC+\n0LTQvtCx0YDRj9GO0YLRgdGPDQoNCtCU0LvRjyDQtNC40YfQuCwg0L/QvtGA\n0L3Rg9GF0Lgg0Lgg0LHQtdGB0YHQvNGL0YHQu9C10L3QvdC+0LPQviDRhNC7\n0YPQtNCwINGB0YLQuNC60LXRgNCw0LzQuCDQtdGB0YLRjCDQtNGA0YPQs9C4\n0LUg0YfQsNGC0YsNCg0K0JHQvtGCINC00LXRgtC10LrRgtC40YIg0L7RgdC9\n0L7QstC90YvQtSDQutC90LjQttC90YvQtSDRgdCw0YLRiyDQstGA0L7QtNC1\nIGZpbWZpY3Rpb24sIGZpY2Jvb2ssIGxpdmVsaWIg0Lgg0L/RgNC10LTQu9Cw\n0LPQsNC10YIg0LTQvtCx0LDQstC40YLRjCDQutC90LjQs9GDINCyINC/0YDQ\nvtGH0LjRgtCw0L3QvdC+0LUuDQrQndC1INGB0YTQvtGC0LrQsNC7IC0g0L3Q\ntSDQstGL0L/QuNC7LiDQo9GH0ZHRgiDQsNC70LrQvtCz0L7Qu9GPINCy0LXQ\ntNGR0YLRgdGPINGH0LXRgNC10Lcg0LrQsNGA0YLQuNC90LrQuCDRgSDRgtC1\n0LPQsNC80LguDQoNCtCa0L7QvNCw0L3QtNGLINCx0L7RgtCwOg0KL3JvbGwg\nLSDQvtGC0LLQtdGCINC90LAg0LLQvtC/0YDQvtGBICLQv9C40YLRjCDQuNC7\n0Lgg0L3QtSDQv9C40YLRjD8iDQovcnVsZXMgLSDRjdGC0Lgg0L/RgNCw0LLQ\nuNC70LANCi9oYXNfZHJpbmsg0L3QsNC30LLQsNC90LjQtV/QvdCw0L/QuNGC\n0LrQsCAtINGD0LfQvdCw0YLRjCwg0LXRgdGC0Ywg0LvQuCDQvdCw0L/QuNGC\n0L7QuiDQsiDQsdCw0LfQtQ0KL2FkZF9kcmluayDQvdCw0LfQstCw0L3QuNC1\nX9C90LDQv9C40YLQutCwIC0g0LTQvtCx0LDQstC40YLRjCDQvdCw0L/QuNGC\n0L7QuiDQsiDQsdCw0LfRgw0KL2FkZF9ib29rINGB0YHRi9C70LrQsF/QvdCw\nX9C60L3QuNCz0YMgLSDQtNC+0LHQsNCy0LjRgtGMINC60L3QuNCz0YMg0LIg\n0L/RgNC+0YfQuNGC0LDQvdC90L7QtQ0KL3RvcF9ib29rcyAtINGC0L7QvyDQ\nutC90LjQsw0KL3RvcF9yZWFkZXJzIC0g0YLQvtC/INGH0LjRgtCw0YLQtdC7\n0LXQuQ0KL3RvcF9kcmlua3MgLSDRgtC+0L8g0LHRg9GF0LvQsA0KL3RvcF9k\ncmlua2VycyAtINGC0L7QvyDQsNC70LrQvtCz0L7Qu9C40LrQvtCy\n"))
Message.where(slug: 'welcome').first_or_create(content: Base64.decode64("0JTQvtCx0YDQviDQv9C+0LbQsNC70L7QstCw0YLRjCDQsiDQkdGD0YXQvtGC\n0LXQutGDINCc0Y3QudC90YXRjdGC0YLQtdC90LAsICole2ZpcnN0X25hbWV9\nKiEKCtCjINC90LDRgSDQvNC+0LbQvdC+ICjQuCDQvdGD0LbQvdC+KSDQvtCx\n0YHRg9C20LTQsNGC0Ywg0LrQvdC40LPQuCDQuCDQsNC70LrQvtCz0L7Qu9GM\nLgrQndCw0LbQvNC40YLQtSAvcnVsZXMg0YfRgtC+0LHRiyDQv9C+0LvRg9GH\n0LjRgtGMINGB0L/RgNCw0LLQutGDINC/0L4g0LHQvtGC0YMsINC+0L0g0YPQ\nvNC10LXRgiDQvNC90L7Qs9C+INC/0L7Qu9C10LfQvdGL0YUg0YjRgtGD0Loh\n"))
Message.where(slug: 'person_of_a_day').first_or_create(content: "*Человеком дня* сегодня будет %{username}! Поднимем же за него бокалы!")
Message.where(slug: 'ship').first_or_create(content: "Пара дня: %{first} + %{second} = ❤️")
Message.where(slug: 'reputation_increase').first_or_create(content: "%{first} увеличил репутацию %{second} до %{reputation}")
Message.where(slug: 'reputation_decrease').first_or_create(content: "%{first} понизил репутацию %{second} до %{reputation}")

[
  {name: "rules", description: "прочитать правила"},
  {name: "help", description: "прочитать справку по боту"},
  {name: "ship", description: "шипперинг"},
].each do |bc|
  BotCommand.where(name: bc[:name]).first_or_create(description: bc[:description])
end

Config.where(key: 'warns_limit').first_or_create(value: '3')
Config.where(key: 'shippering_period_hours').first_or_create(value: '24')
Config.where(key: 'last_shippering').first_or_create(value: nil)
Config.where(key: 'reputation_increase_words').first_or_create(value: "Одобряю, Да благославит тебя Селестия")
Config.where(key: 'reputation_decrease_words').first_or_create(value: "Порицаю, Да проклянёт тебя Луна")