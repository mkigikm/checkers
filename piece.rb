# encoding utf-8

require_relative 'errors.rb'
require 'byebug'
require 'colorize'

module Checkers
  class Piece
    attr_reader :color, :rank, :square

    def initialize(board, square, color, rank=:pawn)
      @board = board
      @square = square
      @color = color
      @rank = rank

      board[square] = self
    end

    def my_dup(dup_board)
      Piece.new(dup_board, square.dup, color, rank)
    end

    def perform_slide(new_square)
      if can_move_in?(board.connection(square, new_square)) &&
          board.empty?(new_square)
        board[square] = nil
          board[new_square] = self
        @square = new_square
        check_promote
        return true
      end

      false
    end

    def valid_slides
      directions.collect_concat do |dir|
        @board.connections(square, dir).select do |square|
          @board.empty?(square)
        end
      end
    end

    def valid_jumps(cur=square, jumped_squares=[])
      futures = []

      directions.each do |dir|
        board.jump_connections(cur, dir).each do |(jump_square, land_square)|
          # don't want to jump over the same piece twice
          next if jumped_squares.include?(jump_square)
          next unless can_jump_to?(jump_square, land_square, cur)

          valid_jumps(land_square, jumped_squares + [jump_square]).
              each do |future|
            futures << [cur].concat(future)
          end
        end
      end

      if futures.empty?
        cur == square && jumped_squares.empty? ? [] : [[cur]]
      else
        futures
      end
    end

    def perform_jump(land_square)
      jump_square = @board.jump_connection(square, land_square)

      if jump_square && can_jump_to?(jump_square, land_square)
        board[square] = nil
        board[jump_square] = nil
        board[land_square] = self
        @square = land_square
        check_promote
        return true
      end

      false
    end

    def perform_moves!(move_sequence)
      if move_sequence.count == 1 && perform_slide(move_sequence.first)
        return true
      end

      old_rank = rank
      move_sequence.each do |land_square|
        if rank != old_rank
          raise InvalidMoveError.new("pieces can't jump after promotion")
        end

        unless perform_jump(land_square)
          raise InvalidMoveError.new("piece at #{@square} can't land at #{land_square}")
        end
      end

      return true
    end

    def render
      char = color == :red ? 'r' : 'b'
      if rank == :king
        char.upcase
      else
        char
      end
    end

    def render_scrolling
      char = rank == :king ? "⦿" : "○"
      char.colorize(color)
    end

    protected
    attr_accessor :board

    private
    def enemy_piece?(capture_square)
      capture_piece = @board[capture_square]
      !capture_piece.nil? && capture_piece.color != color
    end

    def can_move_in?(direction)
      !direction.nil? && (rank == :king ||
                          (color == :red && direction == :up) ||
                          (color == :black && direction == :down))
    end

    def can_jump_to?(jump_square, land_square, start_square=square)
      can_move_in?(board.connection(start_square, jump_square)) &&
        (board.empty?(land_square) || land_square == square) &&
        enemy_piece?(jump_square)
    end

    def check_promote
      if rank == :pawn && board.in_king_row?(self)
        @rank = :king
      end
    end

    def directions
      if rank == :king
        [:up, :down]
      elsif color == :red
        [:up]
      else
        [:down]
      end
    end
  end
end
