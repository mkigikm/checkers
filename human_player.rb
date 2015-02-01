require_relative 'errors.rb'
require_relative 'board'

module Checkers
  class Human
    def initialize
      @displayed_over = false
    end

    def take_turn(game, illegal_move)
      if illegal_move.nil?
        puts game.board.render_scrolling
        puts "Turn #{game.turn_counter}, #{game.turn.to_s} to move"
      else
        puts illegal_move
      end

      begin
        puts "Input your move: "
        moves = parse_move_input(gets.chomp)
      rescue InvalidInputError => e
        puts e
        retry
      end

      moves.map { |square| Board.translate_square(square) }
    end

    def result
      unless @displayed_over
        puts @game.board.render_scrolling
        puts "#{@game.turn.to_s.capitalize} lost"
      end

      @displayed_over = true
    end

    def parse_move_input(move_input)
      moves = move_input.split(",").map do |square|
        square.to_i
      end

      unless moves.all? { |square| square.between?(1, 32) }
        raise InvalidInputError.new("Squares are numbered 1 to 32")
      end

      if moves.count < 2
        raise InvalidInputError.new("Enter a starting position followed " +
          "by the movement squares")
      end

      moves
    end
  end
end
