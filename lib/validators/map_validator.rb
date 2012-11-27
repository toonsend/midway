class MapValidator < ActiveModel::Validator

  VALID_FLEET = [5,4,3,3,2].sort

  def validate(record)
    validate_fleet_size(record)
    validate_ship_sizes(record)
    validate_ship_positions(record)
  end

  def validate_fleet_size(record)
    if record.grid && record.grid.length < 5
      record.errors.add(:grid, "NOT_ENOUGH_SHIPS")
    elsif record.grid && record.grid.length > 5
      record.errors.add(:grid, "TOO_MANY_SHIPS")
    end
  end

  def validate_ship_sizes(record)
    if record.ships.map(&:length).sort != VALID_FLEET
      record.errors.add(:grid, "WRONG_SHIP_SIZE")
    end
  end

  def validate_ship_positions(record)
    record.game_grid
  rescue Ship::ShipOutOfBoundsException
    record.errors.add(:grid, "SHIP_OUT_OF_BOUNDS")
  rescue MapValidator::ShipOverlapException
    record.errors.add(:grid, "SHIPS_OVERLAP")
  end

  class ShipOverlapException < Exception
  end

end
