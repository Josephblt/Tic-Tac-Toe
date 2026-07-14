# frozen_string_literal: true

require 'rspec'
require './src/symbol'

describe Symbol do
  it 'defines the empty symbol' do
    expect(Symbol::EMPTY).to eq(0)
  end

  it 'defines the cross symbol' do
    expect(Symbol::CROSS).to eq(1)
  end

  it 'defines the nought symbol' do
    expect(Symbol::NOUGHT).to eq(2)
  end
end
