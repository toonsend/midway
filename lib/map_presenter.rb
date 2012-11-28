class MapPresenter

  attr_accessor :map

  def initialize(map)
    @map = map
  end

  def to_console
    puts "GAME GRID"
    puts "  0123456789"
    puts "------------"
    game_grid = @map.game_grid
    10.times do |y|
      print "#{y}|"
      10.times do |x|
        print game_grid[x][y]
      end
      puts ""
    end
    puts "------------"
  end

end

