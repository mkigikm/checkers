require_relative 'errors.rb'
require_relative 'board'
require_relative 'player'

module Checkers
  class Human < Player
    def take_turn(game, illegal_move)
      if illegal_move.nil?
        display_turn(game)
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
