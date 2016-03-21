# encoding: utf-8
# Скрипт запрашивает информацию о тратах и записывает её в 'my_expenses.xml'

if (Gem.win_platform?)
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end

require "rexml/document" # подключаю парсер
require "date" # буду использовать операции с данными

# Спрошу у пользователя на что он потратил деньги и сколько
puts "На что потратили деньги?"
expense_text = STDIN.gets.chomp

puts "Сколько потратили денег?"
expense_amount = STDIN.gets.chomp.to_i

# Спрошу пользователя, когда он потратил деньги
puts "Укажите дату траты в формате ДД. ММ. ГГГ. например 12.05.2003 (пустое поле сегодня)"
date_input = STDIN.gets.chomp

# Для того, чтобы записать дату в удобном формате, воспользуюсь методом parse класса Time
expense_date = nil


# Если пользователь ничего не ввёл, значит он потратил деньги сегодня
if date_input == ''
  expense_date = Date.today
else
  begin
    expense_date = Date.parse(date_input)
  rescue ArgumentError # если дата введена неправильно, перехватываем исключение и выбираем "сегодня"
    expense_date = Date.today
  end
end

# Спрашиваю в какую категорию занести траты
puts "В какую категорию занести трату"
expense_category = STDIN.gets.chomp

# Сначала получаю текущее содержимое файла
# И строю из него XML-структуру в переменной doc
current_path = File.dirname(__FILE__)
file_name = current_path + "/my_expenses.xml"

begin
  file = File.new(file_name, "r:UTF-8")
  doc = REXML::Document.new(file)
  file.close
rescue REXML::ParseException => e # если парсер ошибся при чтении файла, придется закрыть прогу :(
  puts "Похоже поломан xml файл"
  abort e.message
end

# Добавляю трату в XML-структуру в переменной doc

# Для этого делаю элемент expenses (корневой)
expenses = doc.elements.find('expenses').first

expense = expenses.add_element 'expense', {
                                            'amount' => expense_amount,
                                            'category' => expense_category,
                                            'date' => expense_date.to_s
                                        }

# Переобразовываю содержимое в текст
expense.text = expense_text

# Записываю новую XML-структуру в файл методов write
# В качестве параметра методу передаётся указатель на файл
# Красиво отформатирую текст в файлике с отступами в два пробела
file = File.new(file_name, "w:UTF-8")
doc.write(file, 2)
file.close

# Поздравляю пользователя с успешной записью
puts "Запись успешно сохранена"