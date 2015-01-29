require_relative 'board.rb'
require_relative 'errors.rb'

module Checkers
  class Game
    attr_reader :turn, :board, :turn_counter

    def initialize
      @turn = :red
      @board = Checkers::Board.starting_board
      @turn_counter = 0
    end

    def take_turn(start, *moves)
      piece = board[Board.translate_square(start)]

      if piece.nil?
        raise InvalidMoveError.new("No piece at starting sqaure.")
      end

      if piece.color != turn
        raise InvalidMoveError.new("#{turn.to_s.capitalize} to move.")
      end

      board.user_moves(start, *moves)
      switch_turn
    end

    private
    def switch_turn
      @turn_counter += 1
      @turn = @turn == :red ? :black : :red
    end
  end
end
