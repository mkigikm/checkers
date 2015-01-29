module Checkers
  class ComputerPlayer
    def initialize(color)
      @color = color
    end

    def random(board)
      moves = board.valid_moves(@color)
      moves.sample
    end

    def one_ahead(board)
      moves = board.valid_moves(@color)
      moves.each do |move|
    end
  end
end
