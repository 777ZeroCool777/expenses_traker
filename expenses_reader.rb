# encoding: utf-8
# Скрипт выводит потраченные деньги

# XXX/ Этот код необходим только при использовании русских букв на Windows
if (Gem.win_platform?)
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end
# XXX/

require "rexml/document" # подключаем парсер
require "date" # будем использовать операции с данными

current_path = File.dirname(__FILE__)
file_name = current_path + "/my_expenses.xml"

# перерываю выполнение программы досрочно, если файл не существует
abort "Извиняемся, хозяин, файлик my_expenses.xml не найден" unless File.exist?(file_name)

file = File.new(file_name)

begin
doc = REXML::Document.new(file)  # создаю новый документ REXML, построенный из открытого XML файла
rescue REXML::ParseException => e
puts "Похоже, файл #{file_name} испорчен:"
abort e.message
end

amount_by_day = Hash.new # пустой асациативный массив, куда складываются все траты

# выбираю из элементов документа все тэги <expense> внутри <expenses>
# и в цикле прохожусь по ним
doc.elements.each("expenses/expense") do |item|
  loss_sum = item.attributes["amount"].to_i
  loss_date = Date.parse(item.attributes["date"])

  # инсцилизирую нулем значение хеша, если этой даты еще небыло
  amount_by_day[loss_date] ||= 0

  # добавляю трату за этот день
  amount_by_day[loss_date] += loss_sum
end

file.close

# Создаю хеш, который соберает всю трату за месяц
sum_by_month = Hash.new

current_month = amount_by_day.keys.sort[0].strftime("%B %Y")

amount_by_day.keys.sort.each do |key|
  sum_by_month[key.strftime("%B %Y")] ||= 0
  sum_by_month[key.strftime("%B %Y")] += amount_by_day[key]
end

# выводимм заголовок для первого месяца
puts "------[ #{current_month}, всего потрачено: #{sum_by_month[current_month]} р. ]--------"

# в цикле по всем датам хэша amount_by_day накоплю в хэше sum_by_month
# значения потраченных сумм каждого дня
amount_by_day.keys.sort.each do |key|

  # если текущий день принадлежит уже другому месяцу...
  if key.strftime("%B %Y") != current_month

    # то значит мы перешли на новый месяц и теперь он станет текущим
    current_month = key.strftime("%B %Y")

    # вывожу заголовок для нового текущего месяца
    puts "------[ #{current_month}, всего потрачено: #{sum_by_month[current_month]} р. ]--------"
  end

  # вывожу расходы за конкретный день
  puts "\t#{key.day}: #{amount_by_day[key]} р."
end