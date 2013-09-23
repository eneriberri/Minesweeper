class Board
  def initialize(size = 9)
    @display_board = [["*"] * size] * size
    @actual_board = [[nil] * size] * size
    @mines = ((size == 9) ? 10 : 40)

    size.times do |row|
      size.times do |col|
        @board[row][col] = Tile.new(self)
      end
    end
  end

  def generate_board
    board =
  end
end

class Tile
  def initialize(board)
    board
  end
end

class Minesweeper
end