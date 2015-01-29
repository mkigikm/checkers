require_relative 'errors.rb'

module Checkers
  class Human
    def initialize(game)
      @game = game
    end

    def get_move
      puts @game.board.render_scrolling
      puts "Turn #{@game.turn_counter}, #{@game.turn.to_s} to move"
      begin
        puts "Input your move: "
        moves = parse_move_input(gets.chomp)
        @game.take_turn(moves[0], *moves.drop(1))
      rescue CheckersError => e
        puts e
        retry
      end
    end

    def parse_move_input(move_input)
      moves = move_input.split(",").map do |square|
        square.to_i
      end

      unless moves.all? { |square| square.between?(1, 32) }
        raise InvalidInputError.new("Squares are numbered 1 to 32")
      end

      if moves.count < 2
        raise InvalidInputError.new("Enter a starting position followed by the movement squares")
      end

      moves
    end
  end
end
