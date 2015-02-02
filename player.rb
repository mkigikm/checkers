module Checkers
  class Player
    def initialize(display_over)
      @display_over = display_over
    end

    def display_turn(game)
      puts game.board.render_scrolling
      puts "Turn #{game.turn_counter}, #{game.turn.to_s} to move"
    end

    def result(game)
      if @display_over
        puts game.board.render_scrolling
        puts "#{game.turn.to_s.capitalize} lost"
      end

      @display_over = false
    end
  end
end
