require 'pry'
require_relative './factory.rb'

describe Factory, 'class:' do

  it 'creates new empty factory'  do
    expect { Factory.new }.to_not raise_error
  end

  it 'creates new factory with symbol, string and block as parametres'  do
    expect { Factory.new :a, 'b' do;end }.to_not raise_error
  end

  let(:factory) do 
    Factory.new :a, 'b', c: 'abc', d: 123 do
      def hi
        'Hello'
      end

      def sum
        a + b
      end
    end
  end

  it 'lets to set attributes' do
    factory.a = 'abc'
    factory.b = 123
    expect( factory.a ).to eq 'abc'
    expect( factory.b ).to eq 123
  end

  it 'lets to set default values of attributes' do
    expect( factory.a ).to eq nil
    expect( factory.b ).to eq nil
    expect( factory.c ).to eq 'abc'
    expect( factory.d ).to eq 123
  end

  it 'stores methods inside' do
    factory.a = 11
    factory.b = 22
    expect(factory.hi).to eq 'Hello'
    expect(factory.sum).to eq 33
  end

  it 'lets to access attributes by []' do
    factory[0] = 333
    factory[1] = 444
    factory[2] = 555
    factory[3] = 666
    expect(factory[ 0]).to  eq 333
    expect(factory[:a]).to  eq 333
    expect(factory['a']).to eq 333
    expect(factory[ 1]).to  eq 444
    expect(factory[:b]).to  eq 444
    expect(factory['b']).to eq 444
    expect(factory[ 2]).to  eq 555
    expect(factory[:c]).to  eq 555
    expect(factory['c']).to eq 555
    expect(factory[ 3]).to  eq 666
    expect(factory[:d]).to  eq 666
    expect(factory['d']).to eq 666
  end
end