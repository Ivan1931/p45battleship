require 'spec_helper'

describe Player do
  let(:player) { Player.new }

  describe 'intersects_with_ships?' do
    it 'returns true if the ship intersects with the other ships' do
      patrol_boat = player.ships.select { |ship| ship.is_a? Patrol }.first
      patrol_point = patrol_boat.points.first

      expect(player.intersects_with_ships? Patrol.new(patrol_point, :south)).to eq(true)
    end

    it 'will return false if no ship intersects with the remaining ships' do
      patrol_boat = player.ships.select { |ship| ship.is_a? Patrol }.first
      patrol_point = patrol_boat.points.first
      player.ships = player.ships.select { |ship| ship == patrol_boat }

      test_point = Point.new 5, 5
      test_point.increment :south if test_point == patrol_point #makes sure that the test point is never at the patrol boat

      expect(player.intersects_with_ships? Patrol.new(test_point, :south) ).to eq(false)
    end

  end

  it 'has no intersecting ships' do
    # yucky O(n^2) algoritm to check for intersecting ships
    # is there any point in actually testing this since it is a totally random phenomenon
    player.ships.each do |this|
      player.ships.each do |that|
        unless this == that
          test = player.intersects_with_ships? that
          unless test
          end
          expect(test).to eq(false)
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

  describe 'attack!' do
    it 'when attacking no ships the attack is always a miss' do
      patrol_boat = player.ships.select { |ship| ship.is_a? Patrol }.first
      patrol_point = patrol_boat.points.first
      player.ships = player.ships.select { |ship| ship == patrol_boat }

      test_point = Point.new 5, 5
      test_point.increment :south if test_point == patrol_point #makes sure that the test point is never at the patrol boat

      expect(player.attack!(test_point)).to eq( { status: :miss } )
    end

    it 'when attacking an occupied point we have a hit' do
      submarine_point = player.ships.select { |ship| ship.is_a? Submarine }.first.points.first #this horrifying line ensures that there is a non-empty point that is not a patrol boat
      expect(player.attack! submarine_point).to eq( {status: :hit} )
    end

    describe 'sunk and game loss' do

      it 'returns sunk when a boat is sunk' do
        patrol_point = player.ships.select { |ship| ship.is_a? Patrol }.first.points.first # patrol is selected since it has a single point and thus will be instantly sunk
        expect(player.attack! patrol_point).to eq( { status: :hit, sunk: :patrol } )
      end

      it 'returns a loss when the final ship is sunk' do
        patrol_boat = player.ships.select { |ship| ship.is_a? Patrol }.first
        patrol_point = patrol_boat.points.first
        player.ships = player.ships.select { |ship| ship == patrol_boat }

        expect(player.attack! patrol_point).to eq( { status: :hit, sunk: :patrol, game_status: :lost } )
      end
    end

    describe 'passing attack information' do 

    end
  end

end
