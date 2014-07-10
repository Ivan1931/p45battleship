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
      let(:o_hash) { {x: 0, y: 0 } }
      let(:yl) { { x: 0, y: 1 } }
      let(:xl) { { x: 1, y: 0 } }

      describe 'with legal positions, only testing south and east as those are all that are needed' do

        it 'correctly makes ship south' do
          s = Ship.new o, :south, 2
          expect(s.points).to eq([o_hash, yl])
        end

        it 'correctly makes a ship east' do
          s = Ship.new o, :east, 2
          expect(s.points).to eq([o_hash, xl])
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

    describe 'Modification of the board' do
      subject { empty_grid }

      it 'differs from grid with changed square' do
        modified_grid = Grid.new(:empty).set_square(0, 0, :ship)
        expect(empty_grid).to_not eq(modified_grid)
      end

      it 'is the same grid when the square is returned' do
        expect(empty_grid.set_square(0, 0, :ship)).to eql(empty_grid)
      end

      it 'set stores value in the correct place' do
        expect(empty_grid.set_square(0, 0, :ship).grid[0][0]).to eq(:ship)
      end

    end
  end

end
