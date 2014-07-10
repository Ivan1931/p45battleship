require 'spec_helper'

describe '#battleshiphelper' do

  include BattleShipsHelper

  describe '#points' do

    let(:o) { Point.new 0, 0 }

    it 'correctly destructs' do
      expect(o.destruct).to eq([0,0])
    end

    describe 'increment function' do
      let(:c) { Point.new 1, 1 }

      it 'correctly increments north' do
        expect(c.increment(:north).destruct).to eq([1,0])
      end

      it 'correctly increments south' do
        expect(c.increment(:south).destruct).to eq([1,2])
      end

      it 'correctly increments west' do
        expect(c.increment(:west).destruct).to eq([0,1])
      end

      it 'correctly increments east' do
        expect(c.increment(:east).destruct).to eq([2,1])
      end
    end

    describe 'correct bounds' do

      it '(0, 0) is legal' do
        expect(o.is_legal?).to eq(true)
      end

      it '(-1, 0) is illegal' do
        expect{Point.new(-1, 0)}.to raise_error(ArgumentError)
      end

      it '(0, -1) is illegal' do
        expect{Point.new 0, -1}.to raise_error(ArgumentError  )
      end

      it '(0, GRID_SIZE) is illegal' do
        expect{Point.new 0, GRID_SIZE}.to raise_error(ArgumentError )
      end

      it '(GRID_SIZE, 0) is illegal' do
        expect{Point.new GRID_SIZE, 0}.to raise_error(ArgumentError )
      end

    end

  end

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


  end

  describe Grid do
    let(:empty_grid) { Grid.new(:empty) }
    let(:o) { Point.new 0, 0 }

    describe 'Modification of the board' do

      context 'Valid square types' do

        subject { empty_grid }

        it 'differs from grid with changed square' do
          modified_grid = Grid.new(:empty).set_square(o, :hit)
          expect(empty_grid.grid).to_not eq(modified_grid.grid)
        end

        it 'Set square returns the same grid' do
          expect(empty_grid.set_square(o, :hit).object_id).to eql(empty_grid.object_id)
        end

        it 'set stores value in the correct place' do
          expect(empty_grid.set_square(o, :hit).grid[0][0]).to eq(:hit)
        end
      end

      context 'invalid square type' do
        it 'raises argument error' do
          expect{empty_grid.set_square(o, :dskaljaslk)}.to raise_error(ArgumentError)
        end
      end
    end

    describe 'checking if a ship can exist at a certain point' do
      let(:origin_set_grid) { Grid.new(:unknown).set_square(o, :empty) }
      let(:submarine) { Submarine.new o, :south }
      let(:battleship) { BattleShip.new o.increment(:south), :east}

      it 'No ship can be set at origin' do
        expect(origin_set_grid.can_place_ship?(submarine)).to eq(false)
      end

      it 'Ships can be places else where' do
        expect(origin_set_grid.can_place_ship?(battleship)).to eq(true)
      end

      it 'Ship cannot be placed legally if there are no allowed squares' do
        expect(origin_set_grid.can_place_ship?(battleship, [])).to eq(false)
      end

      it 'Ship can be placed when its squares are allowed' do
        expect(origin_set_grid.can_place_ship?(submarine, [:empty, :unknown])).to eq(true)
      end

      it 'method breaks with invalid square type' do
        expect{ origin_set_grid.can_place_ship?(submarine, [:bleh]) }.to raise_error(ArgumentError)
      end

    end
  end
end
