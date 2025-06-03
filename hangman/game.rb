#!/usr/bin/env ruby
require 'set'

WORD_LIST = []
DEBUG_MODE = ARGV.delete('--debug')

#
def fill_words(size)
  WORD_LIST.clear
  file_path = File.join(__dir__, 'lib', "#{size.strip}.txt")
  
  begin
    File.open(file_path).each { |line| WORD_LIST << line.strip.downcase }
  rescue Errno::ENOENT
    puts "Файл со словами для длины #{size} не найден в папке lib!"
    exit(1)
  end
end

def get_random_word
  WORD_LIST.sample
end


def display_progress(word, correct_letters)
  word.chars.map { |c| correct_letters.include?(c) ? c : '_' }.join(' ')
end

def valid_letter?(char)
  return false if char.nil? || char.empty?
  char.match?(/[а-яё]/i)
end

def valid_word?(word)
  return false if word.nil? || word.empty?
  word.match?(/\A[а-яё]+\z/i)
end

def play_hangman
  word_size = 2

  loop do
    print("\nВыберите длину слова (от 2 до 9): ")
    word_size = gets.strip
    break if word_size.to_i.between?(2, 9)
    puts "Неверная длина слова, попробуйте снова."
  end

  fill_words(word_size)
  word = get_random_word
  max_attempts = word.length + 2
  attempts = 0
  guessed_letters = Set.new
  correct_letters = Set.new

  puts "\n[РЕЖИМ ОТЛАДКИ] Загаданное слово: #{word}" if DEBUG_MODE
  
  puts "\nИгра началась! Загадано слово из #{word.length} букв."
  puts "У вас есть #{max_attempts} попыток.\n"

  loop do
    puts "Слово: #{display_progress(word, correct_letters)}"
    puts "Угаданные буквы: #{guessed_letters.to_a.join(', ')}"
    print "Введите букву или слово: "
    guess = gets.strip.downcase

    if guess.empty?
      puts "Ничего не введено. Попробуйте снова."
      next
    end

    if guess.length == word.length
      unless valid_word?(guess)
        puts "Слово должно содержать только русские буквы. Попробуйте снова."
        next
      end
      
      if guess == word
        puts "Поздравляем! Вы угадали слово: #{word}"
        break
      elsif !WORD_LIST.include?(guess)
        puts "Слово не найдено в словаре. Попробуйте другое."
      else
        attempts += 1
        puts "Неверное слово. Осталось попыток: #{max_attempts - attempts}"
      end
    elsif guess.length == 1
      letter = guess[0]
      
      unless valid_letter?(letter)
        puts "Введите русскую букву."
        next
      end
      
      if guessed_letters.include?(letter)
        puts "Буква '#{letter}' уже была. Попробуйте другую."
      else
        guessed_letters.add(letter)
        if word.include?(letter)
          correct_letters.add(letter)
          puts "Есть такая буква!"
        else
          attempts += 1
          puts "Нет такой буквы. Осталось попыток: #{max_attempts - attempts}"
        end
      end
    else
      puts "Введите либо одну букву, либо слово из #{word.length} букв."
    end

    if word.chars.to_set.subset?(correct_letters)
      puts "\nПоздравляем! Вы открыли все буквы слова: #{word}"
      break
    end

    if attempts >= max_attempts
      puts "\nВы проиграли! Загаданное слово было: #{word}"
      break
    end
  end
end

play_hangman