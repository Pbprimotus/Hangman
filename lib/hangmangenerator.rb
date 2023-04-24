require 'yaml'

class Hangman
  def self.start
    puts "Welcome to Hangman, do you wanna start fresh (1) or do you want to load your save (2) ?"
    answer = gets.chomp.to_i
    if answer == 1
      self.setup
    elsif answer == 2
      self.loading
    else
      "We got something wrong try again"
      self.start
    end
  end

  def self.pick_random_word
    word = File.readlines("google-10000-english-no-swears.txt").sample
    if word.length < 5 || word.length > 12
      self.pick_random_word
    else
      word.chomp.downcase
    end
  end

  def self.setup
    @incorrect_guesses = []
    @wordpicked = self.pick_random_word
    @hangmanword = @wordpicked.split("")
    @hangmanguesses = Array.new(@wordpicked.length, "_")
    @wrongguesses = 0
    @turns = 1
    puts "You've got a word with #{@wordpicked.length} letters"
    self.game
  end

  def self.game
    if @wrongguesses == 6
      self.game_over
    else
      puts "It's turn #{@turns} You've made #{@wrongguesses} wrong gues(ses)"
      puts "Your progress is:"
      p @hangmanguesses
      puts "Your wrongly guessed letters are"
      p @incorrect_guesses
      puts "Do you want to guess a letter or solve the word? Or do you want to save?"
      z = gets.chomp.downcase
      if z == "guess"
        self.guess
      elsif z == "solve"
        self.solve
      elsif z == "save"
        self.saving
      else
        puts "Sorry I didn't get that"
        self.game
      end
    end
  end

  def self.guess
    @turns += 1
    puts "Give me a letter"
    letter = gets.chomp.downcase
    alphabet = ("a".."z").to_a
    if @incorrect_guesses.include?(letter) == true
      puts "You've already wrongly guessed this letter, try again"
      self.guess
    elsif @hangmanguesses.include?(letter) == true
      puts "You've already guessed this letter and were correct, try again"
      self.guess
    elsif @hangmanword.include?(letter) == true
      puts "#{letter} is in the word!"
      @hangmanword.each_with_index do |value, index|
        if @hangmanword[index] == letter
          @hangmanguesses[index] = letter
        end
      end
      if @hangmanguesses == @hangmanword
        self.congrats
      else
        self.game
      end
    elsif alphabet.include?(letter)
      puts "Sorry it wasn't in there"
      @incorrect_guesses.push(letter)
      @incorrect_guesses.sort
      @wrongguesses += 1
      self.game
    else
      "You didn't give me a letter or too many, try again"
      self.guess
    end
  end

  def self.solve
    puts "So you think you know the word huh? Lets see what is the word then?"
    a = gets.chomp.downcase
    if @wordpicked == a
      self.congrats
    else
      @wrongguesses += 1
      @turns += 1
      puts "Sorry that wasn't the right answer"
      self.game
    end
  end

  def self.congrats
    puts "Congrats you won!"
    puts "Your word was #{@wordpicked} and you took #{@turns} turns to guess the word"
  end

  def self.game_over
    puts "Too bad, you got hanged!"
    puts "Your word was #{@wordpicked} You lasted #{@turns}"
  end

  def self.saving
    saving = [@wordpicked, @hangmanword, @hangmanguesses, @incorrect_guesses, @wrongguesses, @turns]
    puts "What name do you want to give your savefile? Type stop if you wanna continue"
    save_file = gets.chomp.downcase
    if File.exists?("saves/#{save_file}.yml")
      puts "That save file already exists, please choose another"
      self.saving
    elsif save_file == "stop"
      puts "No problem lets continue"
      self.game
    else
      puts "Thanks for playing and see you later!"
      File.open("saves/#{save_file}.yml", "w") { |file| file.write(saving.to_yaml) }
    end
  end

  def self.loading
    puts "What savefile are you trying to load, give me a name! if you're here by accident and just want to start a game, type start"
    save_file = gets.chomp.downcase
    if File.exists?("saves/#{save_file}.yml")
      loading = YAML.load(File.read("saves/#{save_file}.yml"))
      @wordpicked = loading[0]
      @hangmanword = loading[1]
      @hangmanguesses = loading[2]
      @incorrect_guesses = loading[3]
      @wrongguesses = loading[4]
      @turns = loading[5]
      File.delete("saves/#{save_file}.yml")
      self.game
    elsif save_file == start
      self.setup
    else
      puts "Didn't quite catch that, please try again!"
      self.loading
    end
  end
end

Hangman.start