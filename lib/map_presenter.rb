class MapPresenter

  attr_accessor :map

  def initialize(map)
    @map = map
  end

  def to_console
    puts "GAME GRID"
    puts "____________________"
    game_grid = @map.game_grid
    10.times do |y|
      10.times do |x|
        print game_grid[x][y] + '|'
      end
      puts ""
      print "____________________"
      puts ""
    end
    nil
  end

end

