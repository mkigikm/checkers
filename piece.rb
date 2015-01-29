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
              @board.empty?(land_pos) && @board.color_at?(capture_pos, capture_color)
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
      if rank == :pawn && @board.king_row(@pos, color)
        @rank = :king
      end
    end

    def render
      char = color == :red ? 'r' : 'b'
      if @rank == :king
        char.upcase
      else
        char
      end
    end

    private
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
