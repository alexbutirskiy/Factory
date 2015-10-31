require 'spec_helper'
require './lib/factory'

describe Factory, 'class:' do

  it 'creates new explicit data type' do
    expect { Factory.new 'New_type', :a}.to_not raise_error
    expect { Factory::New_type.new}.to_not raise_error
  end

  it 'creates new anonymous data type'  do
    expect { Factory.new :a}.to_not raise_error
  end

  it 'creates new data type with some attributes and block'  do
    expect { Factory.new :a, 'b' do; end }.to_not raise_error
  end

  it 'raises ArgumentError if no attributes provided' do
    expect { Factory.new }.to raise_exception ArgumentError
  end

  it 'has a "members" method' do
    expect(Factory.new(:a, :b).members).to eq [:a, :b]
  end

end

describe 'New data type:' do
  let(:new_type) do 
    Factory.new :a, 'b'
  end

  let(:factory_block) do 
    Factory.new :a, 'b' do
      def hi
        'Hello'
      end

      def sum
        a + b
      end
    end
  end

  context 'when "new" method calls' do
    it 'creates new_type instance with full set of attributes' do
      f_inst = new_type.new

      expect { f_inst.a     }.to_not raise_error
      expect { f_inst.b     }.to_not raise_error
      expect { f_inst.a = 1 }.to_not raise_error
      expect { f_inst.b = 2 }.to_not raise_error
    end

    it "sets attributes to provided values" do
      f_inst = new_type.new 1, '2'

      expect(f_inst.a).to eq 1
      expect(f_inst.b).to eq '2'
    end

    it "has to_s method" do
      f_inst = new_type.new 1, '2'
      expect(f_inst.to_s).to eq '#<factory  a=1 b="2">'
    end

    it 'raises ArgumentError if number of parametres is more then attributes count' do
      expect { new_type.new 1, 2, 3 }.to raise_exception ArgumentError
    end
  end

  let (:f_inst) { new_type.new 1, 2 }

  context 'if new instance is created successfully' do

    it 'provides access to attribute through ["string_name"]' do
      expect { f_inst['a']      }.to_not raise_error
      expect { f_inst['a'] = 1  }.to_not raise_error
      expect(f_inst['a']).to eq 1
    end

    it 'provides access to attribute through [:symbol_name]' do
      expect { f_inst[:a]      }.to_not raise_error
      expect { f_inst[:a] = 2  }.to_not raise_error
      expect(f_inst['a']).to eq 2
    end

    it 'provides access to attribute through [index]' do
      f_inst[0] = 0
      f_inst[1] = 1
      expect(f_inst[0]).to eq 0
      expect(f_inst[1]).to eq 1
      expect(f_inst[-1]).to eq 1
      expect(f_inst[-2]).to eq 0
    end

    it 'provides == and eql? methods' do
      f1 = new_type.new 1, 2
      factory_reverse = Factory.new :b, :a
      f2 = factory_reverse.new 2, 1
      f3 = factory_block.new 1, 2
      f4 = factory_block.new 1, 2
      expect(f1 == f1).to eq true
      expect(f1 == new_type.new(1, 2)).to eq true
      expect(f1 == new_type.new(1, 1)).to eq false
      expect(f1 == new_type.new(2, 2)).to eq false
      expect(f1 == f3).to eq false
      expect(f3 == f4).to eq true
      expect(f3.eql? f4).to eq true
      expect(f1.eql? f4).to eq false
    end

    it 'provides "each" method' do
      expect(f_inst.each).to be_a_kind_of(Enumerable)
    end

    it 'has "each_pair" method' do
      expect(f_inst.each_pair).to be_a_kind_of(Enumerable)
    end

    it 'has "length" and "size" method' do
      expect(f_inst.length).to eq 2
      expect(f_inst.size).to eq 2
    end

    it 'has "to_h" method' do
      expect(f_inst.to_h).to eq ({ a: 1, b:2 })
    end

    it 'has "values" method' do
      expect(f_inst.values).to eq ([1, 2])
    end    

    it 'has "values_at" method' do
      expect(f_inst.values_at(1, 0)).to eq ([2, 1])
    end    

    it 'provides whole bunch of methods from Ennumerable' do
      f_inst.a = 1
      f_inst.b = 2
      expect(f_inst.to_a).to eq [1, 2]
      expect(f_inst.inject(&:+)).to eq 3
    end

  end

  context 'in case of wrong index' do
    it 'raises IndexError if index is out of range' do
      expect { f_inst[ 2] }.to raise_error IndexError
      expect { f_inst[-3] }.to raise_error IndexError
    end

    it 'raises NameError if attribute is wrong' do
      expect { f_inst[ :c] }.to raise_error NameError
      expect { f_inst[ 'd'] }.to raise_error NameError
    end

    it 'raises TypeError if attribute is not Fixnum nor String nor Symbol' do
      expect { f_inst[{}] }.to raise_error TypeError
    end
  end

  context 'when block provided' do
    let (:f_inst) { factory_block.new 1, 2 }
    it 'New_type lets to call method from block' do
      expect(f_inst.hi).to eq 'Hello'
      expect(f_inst.sum).to eq 3
    end
  end

end