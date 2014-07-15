require 'spec_helper'

describe '#ships' do 
  let(:o) { Point.new 0, 0 }

  describe 'creation of ships' do
    let(:yl) { Point.new( 0, 1) }
    let(:xl) { Point.new( 1, 0) }

    describe 'with legal positions, only testing south and east as those are all that are needed' do

      it 'correctly makes ship south' do
        s = Ship.new o, :south, 2
        expect(s.points).to eq([o, yl])
      end

      it 'correctly makes a ship east' do
        s = Ship.new o, :east, 2
        expect(s.points).to eq([o, xl])
      end

    end

    describe 'ships with illegal positions' do
      it 'throws an illegal argument error for an illegal ship point' do
        expect{ Ship.new(Point.new(0, GRID_SIZE - 1), :south, 2) }.to raise_error(ArgumentError)
      end

      it 'throws an exception for a ship that is too long' do
        expect{ Ship.new(o, :south, 6) }.to raise_error(ArgumentError)
      end

      it 'throws an exception for a ship that is too short' do
        expect{ Ship.new(o, :south, 0) }.to raise_error(ArgumentError)
      end
    end

  end

  describe '#ship types' do
    context '|valid ship types' do
      it 'carrier is a valid ship' do
        expect(Ship.valid_ship_type?(:carrier)).to eq(true)
      end

      it 'battleship is a valid ship' do
        expect(Ship.valid_ship_type?(:battleship)).to eq(true)
      end

      it 'destroyer is a valid ship' do
        expect(Ship.valid_ship_type?(:destroyer)).to eq(true)
      end

      it 'patrol is a valid ship' do
        expect(Ship.valid_ship_type?(:patrol)).to eq(true)
      end

      it 'submarine is a valid ship' do
        expect(Ship.valid_ship_type?(:submarine)).to eq(true)
      end

    end

    context '#Invalid ship types' do
      it 'Bleh is an invalid ship type' do
        expect(Ship.valid_ship_type?(:bleh)).to eq(false)
      end
    end
  end

  describe '#ship targeting' do
    let(:ship) { Ship.new o, :south, 2 }
    it 'is false when nothing is fired at ship' do
      expect(ship.is_hit?(o)).to eq(false)
    end

    it 'is hit after ship has been targetted' do
      s = ship.attack! o
      expect(s.is_hit?(o)).to eq(true)
    end

    it 'is sunk when all of its possitions are destroyed' do
      o1 = Point.new 0, 1
      s = ship.attack!(o).attack!(o1)
      expect(s.is_sunk?).to eq(true)
    end
  end


  describe '.intersects with ship method' do
    let(:origin_ship) { Submarine.new o, :south }
    let(:another_origin_ship) { Submarine.new o, :east }
    let(:next_to_origin_ship) { Submarine.new o.increment(:east), :south }

    it 'Ships always intersect with themselves' do
      expect(origin_ship.intersects_with?(origin_ship)).to eq(true)
    end

    it 'is false if ships when ships dont intersect' do
      expect(origin_ship.intersects_with?(next_to_origin_ship)).to eq(false)
    end

    it 'true if at least one point is common' do
      expect(origin_ship.intersects_with?(another_origin_ship)).to eq(true)
    end

  end

end
