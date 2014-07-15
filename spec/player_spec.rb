require 'spec_helper'

describe Player do
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
