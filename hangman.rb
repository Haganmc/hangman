# Hangman Game in Ruby
require 'json'

class Hangman
  attr_accessor :word, :guesses, :max_attempts

  def initialize(word)
    @word = word.downcase
    @guesses = []
    @max_attempts = 6
  end

  def get_random_word
    words = File.readlines(@@file_path).map(&:chomp)
    @word = words.sample.downcase
  end

  def display_word
    @word.chars.map { |char| @guesses.include?(char) ? char : '_' }.join(' ')
  end

  def guess(letter)
    return false if letter.length != 1 || !letter.match?(/[a-z]/i)

    @guesses << letter.downcase unless @guesses.include?(letter.downcase)
    @word.include?(letter.downcase)
  end

  def attempts_remaining
    @max_attempts - (@guesses - @word.chars).size
  end

  def game_over?
    attempts_remaining <= 0 || won?
  end

  def won?
    (@word.chars - @guesses).empty?
  end
  def display_status
    puts "Word: #{display_word}"
    puts "Guesses: #{@guesses.join(', ')}"
    puts "Attempts remaining: #{attempts_remaining}"
    puts "Game Over!" if game_over?
    puts "You won!" if won?
  end

  def start_game
    puts "Welcome to Hangman!"
    get_random_word
    until game_over?
      display_status
      puts "Enter a letter to guess:"
      letter = gets.chomp.downcase
      if guess(letter)
        puts "Good guess!"
      else
        puts "Wrong guess!"
      end
    end
    display_status
    if won?
      puts "Congratulations! You've guessed the word '#{@word}'!"
    else
      puts "Sorry, you've run out of attempts. The word was '#{@word}'."
    end
    play_again
  end
  
  def save_game
    save_data = {
      word: @word,
      guesses: @guesses,
      max_attempts: @max_attempts
    }
    File.write('hangman_save.json', JSON.dump(save_data))
    puts "Game saved!"
  end

  def load_game
    if File.exist?('hangman_save.json')
      save_data = JSON.parse(File.read('hangman_save.json'))
      @word = save_data['word']
      @guesses = save_data['guesses']
      @max_attempts = save_data['max_attempts']
      puts "Game loaded!"
    else
      puts "No saved game found."
      get_random_word
    end
  end

  def play_again
    puts "Do you want to play again? (y/n)"
    answer = gets.chomp.downcase
    if answer == 'y'
      reset_game
      start_game
    else
      puts "Thanks for playing!"
    end
  end

  def reset_game
    @word = ""
    @guesses = []
    @max_attempts = 6
    get_random_word
  end

  private
  @@file_path = File.join(__dir__, 'google-10000-english-no-swears.txt')
end

Hangman.new("").start_game
