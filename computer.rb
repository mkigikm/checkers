module Checkers
  class Computer < Player
    def initialize(movement_method=:random, display=false)
      super(display)

      @movement_method = movement_method
      @display = display
    end

    def take_turn(game, illegal_move)
      if @display
        puts game.board.render_scrolling
        puts "Turn #{game.turn_counter}, #{game.turn.to_s} to move"
      end

      send(@movement_method, game.board, game.turn)
    end

    def random(board, color)
      moves = board.valid_moves(color)
      moves.sample
    end

    def one_ahead(board, color)
      moves = board.valid_moves(color)
    end
  end
end
