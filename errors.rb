module Checkers
  class CheckersError < StandardError
  end

  class InvalidMoveError < CheckersError
  end

  class InvalidInputError < CheckersError
  end
end
