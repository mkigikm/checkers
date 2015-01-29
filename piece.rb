require_relative 'errors.rb'

module Checkers
  class Piece
    attr_reader :color, :rank

    def initialize(board, pos, color, rank=:pawn)
      @board = board
      @pos = pos
      @color = color
      @rank = rank

      board[pos] = self
    end

    def my_dup(dup_board)
      Piece.new(dup_board, @pos.dup, color, rank)
    end

    def perform_slide(new_pos)
      directions.each do |dir|
        if board.connected?(@pos, new_pos, dir) && board.empty?(new_pos)
          board[@pos] = nil
          board[new_pos] = self
          @pos = new_pos
          check_promote
          return true
        end
      end

      false
    end

    def perform_jump(land_pos)
      capture_color = color == :red ? :black : :red

      directions.each do |dir|
        board.connections(@pos, dir).each do |capture_pos|
          if board.connected?(capture_pos, land_pos, dir) &&
              board.empty?(land_pos) && enemy_piece?(capture_pos)
            board[@pos] = nil
            board[capture_pos] = nil
            board[land_pos] = self
            @pos = land_pos
            check_promote
            return true
          end
        end
      end

      false
    end

    def perform_moves!(move_sequence)
      if move_sequence.count == 1 && perform_slide(move_sequence.first)
        return true
      end

      old_rank = rank
      move_sequence.each do |land_pos|
        if rank != old_rank
          raise InvalidMoveError.new("pieces can't jump after promotion")
        end

        unless perform_jump(land_pos)
          raise InvalidMoveError.new("piece at #{@pos} can't land at #{land_pos}")
        end
      end

      return true
    end

    def render
      char = color == :red ? 'r' : 'b'
      if @rank == :king
        char.upcase
      else
        char
      end
    end

    protected
    attr_accessor :board

    private
    def enemy_piece?(capture_pos)
      capture_piece = @board[capture_pos]
      !capture_piece.nil? && capture_piece.color != color
    end

    def directions
      if @rank == :king
        [:up, :down]
      elsif color == :red
        [:up]
      else
        [:down]
      end
    end

    def check_promote
      if rank == :pawn && board.king_row(color) == @pos[0]
        @rank = :king
      end
    end
  end
end
