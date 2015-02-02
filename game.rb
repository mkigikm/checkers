require_relative 'board'
require_relative 'errors'
require_relative 'human_player'
require_relative 'computer'

module Checkers
  class Game
    attr_reader :turn, :board, :turn_counter

    def initialize
      @turn = :red
      @board = Checkers::Board.starting_board
      @turn_counter = 0
    end

    def play_game(red_player, black_player)
      player_idx = 0
      cur_player = red_player

      until over?
        illegal_move = nil

        begin
          move = cur_player. \
            take_turn(self, illegal_move)
          @board.perform_moves(move[0], move.drop(1))
        rescue InvalidMoveError => e
          illegal_move = e
          retry
        end

        cur_player = switch_turn(red_player, black_player)
      end

      red_player.result(self)
      black_player.result(self)
    end

    private
    def switch_turn(red_player, black_player)
      @turn_counter += 1
      @turn = @turn == :red ? :black : :red
      @turn == :red ? red_player : black_player
    end

    def over?
      return @board.game_over?(@turn)
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  game = Checkers::Game.new
  human_player = Checkers::Human.new(true)
  cpu_red = Checkers::Computer.new(:random, true)
  cpu_black = Checkers::Computer.new(:random)

  game.play_game(cpu_red, cpu_black)
end
