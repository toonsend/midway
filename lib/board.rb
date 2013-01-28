# Each possible board position is equally likely. This does not however mean that each cell
# is equally likely to contain each ship. The ships will cluster around the center of the
# board because there are more valid board positions where the ships are in the center than
# when the ships are on the side.
#
# You may also want to replace Random with SecureRandom if you are paranoid.
#
# author:  benmurphy
class Board

  ACROSS = [0,1]
  DOWN = [1,0]
  DIRECTIONS = [ACROSS, DOWN]

  DEFAULT_SHIPS = [5, 4, 3, 3, 2]

  def initialize(width = 10, height = 10)
    @board = (0...height).map { [0] * width }
  end

  def add_ship(size, row, column, direction)
    if can_write_ship(size, row, column, direction)
      write_ship(size, row, column, direction)
      true
    else
      false
    end
  end

  def can_write_ship(size, row, column, direction)
    (0...size).each do |d|
      new_row = row + direction[0] * d
      new_col = column + direction[1] * d

      if new_row >= @board.length || new_col >= @board[row].length || @board[new_row][new_col] != 0
        return false
      end
    end

    true
  end

  def write_ship(size, row, column, direction)

    (0...size).each do |d|
      @board[row + direction[0] * d][column + direction[1] * d] = size
    end
  end

  def to_s
    @board.map { |r| r.to_s }.join("\n")
  end

  def self.random_board(ships = DEFAULT_SHIPS)

    while (board = try_random_board(ships)) == nil
    end

    board
  end

  def self.try_random_board(ships)
    board = Board.new
    placed_ships = ships.map do |ship|
      direction = DIRECTIONS.sample
      row = Random.rand(10)
      column = Random.rand(10)
      if !board.add_ship(ship, row, column, direction)
        return nil
      end
      [column, row, ship, direction_to_s(direction)]
    end
    [board, placed_ships]
  end

  def self.direction_to_s(direction)
    if direction == ACROSS
      "across"
    elsif direction == DOWN
      "down"
    else
      raise "Invalid Direction"
    end
  end
end
