require 'spec_helper'

describe '#battleshiphelper' do

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
        expect{Point.new 0, -1}.to raise_error(ArgumentError)
      end

      it '(0, GRID_SIZE) is illegal' do
        expect{Point.new 0, GRID_SIZE}.to raise_error(ArgumentError)
      end

      it '(GRID_SIZE, 0) is illegal' do
        expect{Point.new GRID_SIZE, 0}.to raise_error(ArgumentError)
      end

    end

  end

  describe "GameState" do
    let(:player) { Player.new }

    it 'has no intersecting ships' do
      # yucky O(n^2) algoritm to check for intersecting ships
      # is there any point in actually testing this since it is a totally random phenomenon
      player.ships.each do |this|
        player.ships.each do |that|
          unless this == that
            expect(this.intersects_with?(that)).to eq(false)
          end
        end
      end
    end
    
    subject { player.ships.length }

    it { should eq(7) }

    describe 'sinking ships man' do
      subject { player.defeated? }
      it { should eq(false) }

      it 'is defeated when there are no ships' do
        player.ships = []
        expect(player.defeated?).to eq(true)
      end

    end

  end
end
