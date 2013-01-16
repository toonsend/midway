class Ship
  attr_accessor :xpos, :ypos, :direction, :length

  def initialize(ship)
    self.xpos      = ship[0].to_i
    self.ypos      = ship[1].to_i
    self.length    = ship[2].to_i
    self.direction = ship[3]
  end

  def coordinates(grid_width, grid_height)
    raise ShipOutOfBoundsException if self.xpos < 0 || self.ypos < 0 || self.xpos >= grid_width || self.ypos >= grid_height

    position = [[self.xpos,  self.ypos]]
    (self.length - 1).times do |count|
      pos = count + 1
      if self.across?
        raise ShipOutOfBoundsException if self.xpos + pos >= grid_width
        position << [self.xpos + pos, self.ypos]
      else
        raise ShipOutOfBoundsException if self.ypos + pos >= grid_height
        position << [self.xpos, self.ypos + pos]
      end
    end
    position
  end

  def across?
    self.direction == 'across'
  end

  class ShipOutOfBoundsException < Exception
  end

end
