require_relative './factory.rb'

describe Factory, 'class:' do

  it 'creates new factory subclass with some attributes'  do
    expect { Factory.new :a}.to_not raise_error
  end

  it 'creates new factory subclass with some attributes and block'  do
    expect { Factory.new :a, 'b' do;end }.to_not raise_error
  end

  it 'raises ArgumentError if no attributes sended' do
    expect { Factory.new }.to raise_exception ArgumentError
  end

  describe 'factory sublass:' do
    let(:factory) do 
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
      it 'creates factory instance with full set of attributes' do
        f_inst = factory.new

        expect { f_inst.a     }.to_not raise_error
        expect { f_inst.b     }.to_not raise_error
        expect { f_inst.a = 1 }.to_not raise_error
        expect { f_inst.b = 2 }.to_not raise_error
      end

      it "sets attributes to provided values" do
        f_inst = factory.new 1, '2'

        expect(f_inst.a).to eq 1
        expect(f_inst.b).to eq '2'
      end

      it 'raises ArgumentError if number of parametres is more then attributes count' do
        expect { factory.new 1, 2, 3 }.to raise_exception ArgumentError
      end
    end

    let (:f_inst) { factory.new }

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
        f1 = factory.new 1, 2
        factory_reverse = Factory.new :b, :a
        f2 = factory_reverse.new 2, 1
        f3 = factory_block.new 1, 2
        f4 = factory_block.new 1, 2
        expect(f1 == f1).to eq true
        expect(f1 == factory.new(1, 2)).to eq true
        expect(f1 == factory.new(1, 1)).to eq false
        expect(f1 == factory.new(2, 2)).to eq false
        expect(f1 == f3).to eq false
        expect(f3 == f4).to eq true
        expect(f3.eql? f4).to eq true
        expect(f1.eql? f4).to eq false
      end

      it 'provides each method' do
        expect { f_inst.each {} }.to_not raise_error
      end

      it 'provides whole bunch of methods from Ennumerable' do
        f_inst.a = 1
        f_inst.b = 2
        expect( f_inst.to_a ).to eq [[:a, 1], [:b, 2]]
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
      it 'factory lets to call method from block' do
        expect(f_inst.hi).to eq 'Hello'
        expect(f_inst.sum).to eq 3
      end
    end

  end
end