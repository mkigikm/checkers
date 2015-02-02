require_relative 'player'

module Checkers
  class Computer < Player
    OVER_9_000 = 9_001
    MAX_DEPTH = 5
    GRID_VALUE = [
      4, 4, 4, 4,
      4, 3, 3, 3,
      3, 2, 2, 4,
      4, 2, 1, 3,
      3, 1, 2, 4,
      4, 2, 2, 3,
      3, 3, 3, 4,
      4, 4, 4, 4
    ]

    def initialize(movement_method=:random, depth=MAX_DEPTH, display=false)
      super(display)

      @movement_method = movement_method
      @display = display
      @max_depth = depth
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

    def negamax(board, color)
      next_color = color == :red ? :black : :red
      best_moves = []
      max_score = -OVER_9_000 ** 2
      alpha = -OVER_9_000
      beta = OVER_9_000

      moves = board.valid_moves(color)
      return moves.first if moves.count == 1

      moves.each do |move|
        dup_board = board.dup
        dup_board.perform_moves(move[0], move.drop(1))
        score = -negamax_recursive(dup_board, next_color, @max_depth, -beta, -alpha)

        if score > max_score
          max_score = score
          best_moves = [move]
        elsif score == max_score
          best_moves << move
        end

        alpha = [alpha, score].max
        break if alpha >= beta
      end

      best_moves.sample
    end

    def negamax_recursive(board, color, depth, alpha, beta)
      return -(OVER_9_000 - (MAX_DEPTH - depth)) if board.game_over?(color)
      return eval_position(board, color) if depth == 0

      next_color = color == :red ? :black : :red
      max_score = -OVER_9_000

      moves = board.valid_moves(color)
      depth -= 1 if moves.count > 1
      moves.each do |move|
        dup_board = board.dup
        dup_board.perform_moves(move[0], move.drop(1))
        score = -negamax_recursive(dup_board, next_color, depth,
                                    -beta, -alpha)
        max_score = [max_score, score].max

        alpha = [alpha, score].max
        break if alpha >= beta
      end

      max_score
    end

    def eval_position(board, color)
      1.upto(32).inject(0) do |total, square|
        piece = board[Board.translate_square(square)]

        if piece.nil?
          total

        else
          sign = piece.color == color ? 1 : -1
          mag = if piece.rank == :king
            10
          elsif (piece.color == :red && square.between?(5, 8)) ||
              (piece.color == :black && square.between?(25, 28))
            7
          else
            5
          end
          total + sign * mag * GRID_VALUE[square - 1]
        end
      end
    end
  end
end
