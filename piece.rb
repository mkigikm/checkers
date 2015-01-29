require 'byebug'

module Checkers
  class Piece
    attr_reader :color, :rank

    def initialize(board, pos, color)
      @board = board
      @pos = pos
      @color = color
      @rank = :pawn
    end

    def perform_slide(new_pos)
      directions.each do |dir|
        if @board.connected?(@pos, new_pos, dir) && @board.empty?(new_pos)
          @board[@pos] = nil
          @board[new_pos] = self
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
        @board.connections(@pos, dir).each do |capture_pos|
          if @board.connected?(capture_pos, land_pos, dir) &&
              @board.empty?(land_pos) && can_capture?(capture_pos)
            @board[@pos] = nil
            @board[capture_pos] = nil
            @board[land_pos] = self
            @pos = land_pos
            check_promote
            return true
          end
        end
      end

      false
    end

    def check_promote
      if rank == :pawn && @board.king_row(color) == @pos[0]
        @rank = :king
      end
    end

    def

    def render
      char = color == :red ? 'r' : 'b'
      if @rank == :king
        char.upcase
      else
        char
      end
    end

    private
    def can_capture?(capture_pos)
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
  end
end
