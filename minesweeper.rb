class Board
  attr_reader :display_board
  def initialize(size = 9)
#    @display_board = [["*"] * size] * size
    @size = size
    @display_board = (0...size).map { [Tile.new(self)] * size }
    @actual_board = (0...size).map { [Tile.new(self)] * size }
    @mines = ((size == 9) ? 10 : 40)
    generate_bombs
    complete_actual_board
#    display_actual_board
    display(@actual_board)

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
    neighbors
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

  def display(board)
    board.each_index do |row|
      board.each_index do |col|
        if board[row][col].flagged?
          print "#{board[row][col].flag} "
        else
          print "#{board[row][col].value} "
        end
      end
      puts ""
    end
  end

  def process_input(coords, action)
    tile_actual = @actual_board[coords.first][coords.last]
    tile_display = @display_board[coords.first][coords.last]

    case action
    when "f"
     @display_board[coords.first][coords.last] = Tile.new(self, tile_display.value, "f")
#     display(@display_board)

    when "r" # reveal
      unless tile_display.flagged?
        if tile_actual.is_bomb?
          @display_board[coords.first][coords.last] = Tile.new(self, "b")
          return true
        elsif tile_actual.value > 0
          @display_board[coords.first][coords.last] = tile_actual
#          display(@display_board)
        else
          reveal(coords)
          @display_board[coords.first][coords.last] = Tile.new(self, "_")
        end
      end
    end
    return false
  end

  def reveal(coords)
    stack = [[coords.first, coords.last]]
    visited = []
    @display_board[coords.first][coords.last] = Tile.new(self, "_")

    until stack.empty?
      parent = stack.shift
      visited << [parent.first, parent.last]
      neighbor_coords = find_neighbors([parent.first, parent.last])

      neighbor_coords.each do |neighbor_coord|
        neighbor_tile = @actual_board[neighbor_coord.first][neighbor_coord.last]
        if !visited.include?(neighbor_coord) && !neighbor_tile.flagged? && neighbor_tile.value == 0
          stack << neighbor_coord
          @display_board[neighbor_coord.first][neighbor_coord.last] = Tile.new(self, "_")
          neighbor_coords = find_neighbors([neighbor_coord.first, neighbor_coord.last])
        elsif !visited.include?(neighbor_coord) && !neighbor_tile.flagged?
          @display_board[neighbor_coord.first][neighbor_coord.last] = Tile.new(self, neighbor_tile.value)
        end
      end
    end
  end
end

class Tile
  attr_accessor :value, :flag
  def initialize(board, value = "*", flag = "")
    @board = board
    @value = value
    @flag = flag
  end

  def is_bomb?
    @value == "b"
  end

  def flagged?
    @flag == "f"
  end

end


class Minesweeper

  def initialize
    @board = Board.new
    @game_over = false
    play
  end

  def play
    until @game_over
      @board.display(@board.display_board)
      @game_over = get_input
    end
  end

  def get_input
    puts "Enter the tile location."
    coords = gets.chomp.split(",").map(&:to_i)
    puts "Enter (r) for Reveal or (f) for Flag."
    action = gets.chomp
    @board.process_input(coords, action)
  end

end


ms = Minesweeper.new
