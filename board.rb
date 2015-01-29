require_relative 'piece.rb'
require_relative 'errors.rb'
require 'byebug'

module Checkers
  class Board
    ROWS = 8
    COLS = 8
    STARTING_PIECES = 12
    STARTING_ROWS = 3

    def self.starting_board
      board = Board.new

      STARTING_ROWS.times do |row|
        (COLS / 2).times do |col|
          col *= 2
          black_pos = [row, col + ((row + 1) % 2)]
          red_pos = [ROWS - 1 - row, col + (row % 2)]
          Piece.new(board, black_pos, :black, :king)
          Piece.new(board, red_pos,   :red)
        end
      end

      board
    end

    def self.read_board(filename)
      board = Board.new

      lines = File.readlines(filename)
      lines.each_with_index do |line, row|
        COLS.times do |col|
          square = [row, col]

          case line[col]
          when 'r' then Piece.new(board, square, :red)
          when 'R' then Piece.new(board, square, :red, :king)
          when 'b' then Piece.new(board, square, :black)
          when 'B' then Piece.new(board, square, :black, :king)
          end
        end
      end

      board
    end

    def self.translate_square(square)
      square -= 1
      offset = square % 8 > 3 ? 0 : 1
      [square / 4, (square % 4) * 2 + offset]
    end

    def initialize
      @grid = Array.new(ROWS) { Array.new(COLS) }
    end

    def connections(square, dir)
      row, col = square
      new_row = row + dir_offset(dir)

      [[new_row, col - 1], [new_row, col + 1]].select do |square|
        valid_square?(square)
      end
    end

    def valid_square?(square)
      row, col = square
      row.between?(0, ROWS - 1) && col.between?(0, COLS - 1)
    end

    def jump_connections(square, dir)
      row, col = square
      jump_row = row + dir_offset(dir)
      land_row = row + 2 * dir_offset(dir)

      [].tap do |connections|
        [-1, 1].each do |col_offset|
          jump_square = [jump_row, col + col_offset]
          land_square = [land_row, col + 2 * col_offset]
          connections << [jump_square, land_square] if valid_square?(land_square)
        end
      end
    end

    def connection(start_square, end_square)
      row_diff = end_square[0] - start_square[0]
      col_diff = end_square[1] - start_square[1]

      if row_diff.abs != 1 || col_diff.abs != 1
        nil
      elsif row_diff == 1
        :down
      else
        :up
      end
    end

    def jump_connection(start_square, land_square)
      start_row, start_col = start_square
      row_diff = land_square[0] - start_row
      col_diff = land_square[1] - start_col

      if row_diff.abs != 2 || col_diff.abs != 2
        nil
      else
        [start_row + row_diff / 2, start_col + col_diff / 2]
      end
    end

    def in_king_row?(piece)
      king_row = piece.color == :red ? 0 : ROWS - 1
      piece.square[0] == king_row
    end

    def [](pos)
      row, col = pos

      @grid[row][col]
    end

    def []=(pos, el)
      row, col = pos

      @grid[row][col] = el
    end

    def empty?(pos)
      row, col = pos

      @grid[row][col].nil?
    end

    def valid_move_seq?(start, moves)
      return false if self[start].nil?
      color = self[start].color
      return valid_moves(color).include?([start, moves])
      duped_board = dup

      begin
        duped_board[start].perform_moves!(moves)
      rescue InvalidMoveError => e
        return false
      end

      true
    end

    def perform_moves(start, moves)
      if valid_move_seq?(start, moves)
        self[start].perform_moves!(moves)
      else
        raise InvalidMoveError
      end

      self
    end

    def user_moves(start, *moves)
      squares = moves.map { |square| self.class.translate_square(square) }
      perform_moves(self.class.translate_square(start), squares)
    end

    def inspect
      board_str = ""

      ROWS.times do |row|
        COLS.times do |col|
          piece = self[[row, col]]
          if piece.nil?
            board_str << "."
          else
            board_str << piece.render
          end
        end

        board_str << "\n"
      end

      board_str
    end

    def render_scrolling
      board_str = ""
      bg_colors = [:white, :black]
      bg_counter = 1
      square_counter = 1

      ROWS.times do |row|
        bg_counter = (bg_counter + 1) % 2

        COLS.times do |col|
          bg_counter = (bg_counter + 1) % 2

          piece = self[[row, col]]
          if piece.nil?
            cur_str = "   "
          else
            cur_str = " #{piece.render_scrolling} "
          end

          board_str << cur_str.colorize(:background => bg_colors[bg_counter])
        end

        board_str << "   "

        COLS.times do |col|
          bg_counter = (bg_counter + 1) % 2
          if row % 2 == col % 2
            cur_str = "   "
          else
            cur_str = square_counter.to_s.rjust(3)
            square_counter += 1
          end

          board_str << cur_str.colorize(:background => bg_colors[bg_counter])
        end

        board_str << "\n"
      end

      board_str
    end

    def all_pieces
      @grid.flatten.compact
    end

    def dup
      Board.new.tap do |duped_board|
        all_pieces.each { |piece| piece.my_dup(duped_board) }
      end
    end

    def valid_moves(turn)
      turn_pieces = all_pieces.select { |piece| piece.color == turn }
      valid_moves = []

      turn_pieces.each do |piece|
        piece.valid_jumps.each do |jump_sequence|
          unless jump_sequence.empty?
            valid_moves << [piece.square, jump_sequence]
          end
        end
      end

      if valid_moves.empty?
        turn_pieces.each do |piece|
          piece.valid_slides.each do |slide_square|
            valid_moves << [piece.square, [slide_square]]
          end
        end
      end

      valid_moves
    end

    def game_over?(turn)
      valid_moves(turn).empty?
    end

    private
    def dir_offset(dir)
      dir == :up ? -1 : 1
    end
  end
end
