require_relative 'piece.rb'

module Checkers
  class Board
    ROWS = 8
    COLS = 8
    STARTING_PIECES = 12
    STARTING_ROWS = 3

    def self.standard_board
      board = Board.new

      STARTING_ROWS.times do |row|
        (COLS / 2).times do |col|
          col *= 2
          black_pos = [row, col + ((row + 1) % 2)]
          red_pos = [ROWS - 1 - row, col + (row % 2)]
          board[black_pos] = Piece.new(board, black_pos, :black)
          board[red_pos]   = Piece.new(board, red_pos,   :red)
        end
      end

      board
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
      connected = []

      return connected unless new_row.between?(0, ROWS - 1)
      connected << [new_row, col - 1] if col > 0
      connected << [new_row, col + 1] if col < COLS

      connected
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

    def color_at?(pos, color)
      piece = self[pos]
      piece.nil? && piece.color == color
    end

    def king_row(pos, color)
      if color == :red
        pos[0] == 0
      else
        pos[0] == ROWS - 1
      end
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

    private
    def dir_offset(dir)
      dir == :up ? -1 : 1
    end
  end
end
