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

  describe 'grid -> string' do
    let(:empty_grid_string) { (1..GRID_SIZE).map { "E\t" * 9 + "E\n" }.join("")[0..-2] }
    let(:top_row_covered) { "X\t" * 9 + "X\n" + (2..GRID_SIZE).map { "E\t" * 9 + "E\n" }.join("")[0..-2] }

    let(:top_row_grid) do
      g = Grid.new :empty
      10.times do |x|
        g = g.set_square(Point.new(x, 0), :hit)
      end
      g
    end

    it 'builds an empty string grid' do
      expect(empty_grid.to_s).to eq(empty_grid_string)
    end

    it 'correctly matches all stuff on the top row' do
      expect(top_row_grid.to_s).to eq(top_row_covered)
    end

  end

  describe 'ship placement' do

    let(:submarine) { Submarine.new o, :south }

    describe 'can_place_ship?' do
      let(:origin_set_grid) { Grid.new(:unknown).set_square(o, :empty) }
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

    describe 'place_ship' do
      subject { Grid.new(:empty).place_ship(submarine) }
      it { should eq(Grid.new(:empty).set_square(o, :submarine).set_square(o.increment(:south), :submarine)) }
    end

    describe 'place_sunk_ship' do
      it 'places a patrol boat on the origin correctly' do
        p = Patrol.new o, :south
        g = Grid.new(:empty).place_ship p
        e = Grid.new(:empty).set_square o, :hit
        expect(e.place_sunk_ship(o, :patrol).grid).to eq(g.grid)
      end

      describe 'placing carrier at different points' do
        let(:test_grid) do
          temp_point = o
          emp = Grid.new :empty
          5.times do
            emp.set_square temp_point, :hit
            temp_point = temp_point.increment :south
          end
          emp
        end
        let(:carrier) { Carrier.new o, :south }
        let(:carrier_grid)  { Grid.new(:empty).place_ship carrier }

        it 'correctly places carrier when the final hit is the origin' do
          expect(test_grid.place_sunk_ship o, :carrier).to eq(carrier_grid)
        end

        it 'correctly places carrier when the final hit is in the middle of the carrier' do
          expect(test_grid.place_sunk_ship o.increment(:south).increment(:south), :carrier).to eq(carrier_grid)
        end

      end

      it 'places likely_ship as a square_type if there is an ambiguity with respect to how many ships could be placed' do

      end
    end

  end

  describe 'reconstructing grid from game history' do

  end
end
