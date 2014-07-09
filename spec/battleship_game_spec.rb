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
    describe 'creation of ships' do
      let(:o) { Point.new 0, 0 }
      let(:yl) { Point.new 0, 1 }
      let(:xl) { Point.new 1, 0 }

      describe 'with legal positions' do
        it 'correctly makes ship south' do
          s = Ship.new o, :south, 2
          points = [o, yl]

          expect(s.points).to eq(points)
        end

        it 'correctly makes a ship east' do
          s = Ship.new o, :east, 2
          expect(s.points).to eq([o, xl])
        end

        it 'correctly makes a ship west' do
          s = Ship.new xl, :west, 2
          expect(s.points).to eq([xl, o])
        end

        it 'correctly makes a ship north' do
          s = Ship.new yl, :north, 2
          expect(s.points).to eq([yl, o])
        end
      end

      describe 'ships with illegal positions' do
        it 'throws an illegal argument error for an illegal ship point' do
          expect{ Ship.new(o, :north, 2) }.to raise_error(ArgumentError)
        end

        it 'throws an exception for a ship that is too long' do
          expect{ Ship.new(o, :north, 6) }.to raise_error(ArgumentError)
        end

        it 'throws an exception for a ship that is too short' do
          expect{ Ship.new(o, :north, 0) }.to raise_error(ArgumentError)
        end
      end

    end

  end

end
