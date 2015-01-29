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
          Piece.new(board, black_pos, :black)
          Piece.new(board, red_pos,   :red)
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

    def connected?(pos1, pos2, dir)
      row1, col1 = pos1
      row2, col2 = pos2

      (col1 - 1 == col2 || col1 + 1 == col2) && row1 + dir_offset(dir) == row2
    end

    def connections(pos, dir)
      row, col = pos
      new_row = row + dir_offset(dir)

      [[new_row, col - 1], [new_row, col + 1]].select do |(row, col)|
        row.between?(0, ROWS - 1) && col.between?(0, COLS - 1)
      end
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

    def king_row(color)
      color == :red ? 0 : ROWS - 1
    end

    def valid_move_seq?(start, moves)
      duped_board = dup
      #debugger

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

    def user_move(square1, square2)
      pos1 = self.class.translate_square(square1)
      pos2 = self.class.translate_square(square2)
      p pos1
      p pos2
      piece = self[pos1]

      if !piece.perform_slide(pos2)
        piece.perform_jump(pos2)
      end

      puts inspect
      nil
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

    def all_pieces
      @grid.flatten.compact
    end

    def dup
      Board.new.tap do |duped_board|
        all_pieces.each { |piece| piece.my_dup(duped_board) }
      end
    end

    private
    def dir_offset(dir)
      dir == :up ? -1 : 1
    end
  end
end
