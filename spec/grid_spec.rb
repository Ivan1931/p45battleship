require 'spec_helper'

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
