require 'spec_helper'

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
