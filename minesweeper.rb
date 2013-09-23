class Board
  def initialize(size = 9)
#    @display_board = [["*"] * size] * size
    @size = size
    @display_board = (0...size).map { [Tile.new(self)] * size }
    @actual_board = (0...size).map { [Tile.new(self)] * size }
    @mines = ((size == 9) ? 10 : 40)
    generate_bombs
    complete_actual_board
#    display_actual_board
    display_board(@actual_board)

    size.times do |row|
      size.times do |col|
        @display_board[row][col] = Tile.new(self)
      end
    end
  end

  def generate_bombs
    i = 0
    until i == @mines
      row = rand(@size)
      col = rand(@size)
      if @actual_board[row][col].value == "*"
        @actual_board[row][col] = Tile.new(self, "b")
        i += 1
      end
    end
  end

  def generate_bombs_test
    @actual_board[3][3] = Tile.new(self, "b")
  end

  #returns all of a tile's neighbors
  #determine bombs surrounding the tile
  def find_neighbors(tile_loc)
    neighbors = []
    possible_neighbors = [[-1,-1],[-1,0],[-1,1],[0,1],[1,1],[1,0],[1,-1],[0,-1]]


    possible_neighbors.each do |neighbor|
      possible_neighbor = [neighbor.first + tile_loc.first, neighbor.last + tile_loc.last]
      neighbors << possible_neighbor if valid?(possible_neighbor)
    end

    @actual_board[tile_loc.first][tile_loc.last] = Tile.new(self, count_bombs(neighbors))
    possible_neighbors
  end

  # def show_bombs(tile_loc, neighbors)
  #   @actual_board[tile_loc.first][tile_loc.last] = Tile.new(self, count_bombs(neighbors))
  # end

  def valid?(coords)
    coords.none? { |coord| coord < 0 || coord >= @size }
  end

  #return the number of bombs that tile is surrounded by
  def count_bombs(neighbors)
    num = 0
    neighbors.each do |neighbor|
      num += 1 if @actual_board[neighbor.first][neighbor.last].is_bomb?
    end
    num
  end

  def complete_actual_board

    @actual_board.each_index do |row|
      @actual_board.each_index do |col|
        tile = @actual_board[row][col]
        next if tile.is_bomb?

        # neighbors = find_neighbors([row,col])
        # tile.value = show_bombs([row,col], neighbors)
        tile.value = find_neighbors([row,col])
      end
    end
  end

  def display_board(board)
    board.each_index do |row|
      board.each_index do |col|
        print "#{board[row][col].value} "
      end
      puts ""
    end
  end

  def process_input(coords, action)
    tile = @actual_board[coords.first][coords.last]

    case action
    when "f"


    when "r" # reveal
      if tile.is_bomb?
        @display_board[coords.first][coords.last] = Tile.new(self, "b")
      elsif tile.value > 0
        @display_board[coords.first][coords.last] = tile
        display_board(@display_board)
      else
#        reveal(coords)
        @display_board[coords.first][coords.last] = Tile.new(self, 0)
      end
    end
  end

  def reveal(coords)
    tile = @actual_board[coords.first][coords.last]
    return nil if tile.value != 0

    stack = [tile]
    visited = []

    until stack.empty?
      parent = stack.shift
      visited << coords
      neighbor_coords = find_neighbors([coords.first, coords.last])

      neighbor_coords.each do |neighbor_coord|
        neighbor_tile = @actual_board[neighbor_coord.first][neighbor_coord.last]
        if !visited.include?(neighbor_coord) && neighbor_tile.value == 0
          stack << neighbor_coord
          @display_board[neighbor_coord.first][neighbor_coord.last] = 0
        end
      end
    end
  end
end

class Tile
  attr_accessor :value
  def initialize(board, value = "*")
    @board = board
    @value = value
  end

  def is_bomb?
    @value == "b"
  end

end


class Minesweeper
  def initialize
    board = Board.new
    board.process_input([3,3], "r")
    puts
    board.process_input([1,2], "r")
    puts
    board.process_input([4,6], "r")
  end

  def get_input
    # puts "Enter the tile location."
    # coords = gets.chomp.split(", ").map(&:to_i)
    # puts "Enter (r) for Reveal or (f) for Flag."
    # action = gets.chomp
    board.process_input([3,3], "r")
    board.process_input([1,2], "r")
    board.process_input([4,6], "r")

  end

end


ms = Minesweeper.new
