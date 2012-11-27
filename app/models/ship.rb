class Ship

  attr_accessor :xpos, :ypos, :direction, :length

  def initialize(ship)
    self.xpos      = ship[0]
    self.ypos      = ship[1]
    self.length    = ship[2]
    self.direction = ship[3]
  end

  def coordinates
    position = [[self.xpos,  self.ypos]]
    (self.length - 1).times do |count|
      pos = count + 1
      if self.across?
        raise Map::ShipOutOfBoundsException if self.xpos + pos > 9
        position << [self.xpos + pos, self.ypos]
      else
        raise Map::ShipOutOfBoundsException if self.ypos + pos > 9
        position << [self.xpos, self.ypos + pos]
      end
    end
    position
  end

  def across?
    self.direction == 'across'
  end

end
