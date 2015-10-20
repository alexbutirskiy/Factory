# Factory class provides a way to store in the same objects other different
# predefined objects also as methods.
# Usage:
#   Customer = Struct.new(:name, :address, :zip)
#   => Customer
#
#   joe = Customer.new("Joe Smith", "123 Maple, Anytown NC", 12345)
#   => #<struct Customer name="Joe Smith", address="123 Maple, Anytown NC",
#   zip=12345>
#
#   joe.name
#   joe["name"]
#   joe[:name]
#   joe[0]
#   => "Joe Smith"
class Factory
  def initialize *attributes, &block
    raise ArgumentError, 'wrong number of arguments (0 for 1+)' if attributes.empty?
    @_attributes = attributes.map(&:to_sym)
    @_block = block
  end

  def new *values
    raise ArgumentError, 'factory size differs' if values.size > @_attributes.size
    (@_attributes.size - values.size).times { values << nil }
    inst = Class.new
    inst.instance_variable_set :@_attributes, @_attributes
    inst.instance_variable_set :@_block, @_block
    inst.extend AttributeCheck

    @_attributes.each_with_index do |attribute, index|
      inst.instance_variable_set "@#{attribute}", values[index]

      inst.class.send :define_method, "#{attribute}" do
        instance_variable_get "@#{attribute}"
      end

      inst.class.send :define_method, "#{attribute}=" do |value|
        instance_variable_set "@#{attribute}", value
      end

      inst.class.send :define_method, '[]' do |attribute|
        attribute = attribute_check attribute
        instance_variable_get "@#{attribute}"
      end

      inst.class.send :define_method, '[]=' do |attribute, value|
        attribute = attribute_check attribute
        instance_variable_set "@#{attribute}", value
      end
    end
    inst.instance_eval(&@_block) unless @_block.nil?
    inst
  end
end

# AttributeCheck is used to extend dynamicaly created Factory instances with
# some static methods
module AttributeCheck
  include Enumerable
  def == other
    val_attributes = other.instance_variable_get :@_attributes
    return false if val_attributes - @_attributes != []
    return false if @_attributes - val_attributes != []
    return false if @_block != other.instance_variable_get(:@_block)

    @_attributes.each do |v|
      return false if instance_variable_get("@#{v}") != other.instance_variable_get("@#{v}")
    end
    true
  end

  def each &block
    if block
      @_attributes.each do |a|
        block.call send(a)
      end
    end
    self
  end

  alias_method :eql?, :==

  private

    # When val is String or Symbol
    #   it checks if val presents in attribute's list and raise an error 
    #   in abscence case
    # When val is Fixnum
    #   it checks if val is in valid range
    #     raise an error if out of range
    #     converts to attribute name otherwise
    def attribute_check val
      case val
      when Fixnum
        if val >= @_attributes.size
          raise IndexError, "offset #{val} is to large for #{description}"
        elsif val < (@_attributes.size * -1)
          raise IndexError, "offset #{val} is to small for #{description}"
        end

        val = @_attributes.size + val if val < 0
        val = @_attributes[val]
      when Symbol, String
        val = val.to_sym
        unless @_attributes.include? val
          raise NameError, "no attribute #{val} in factory"
        end
      else
        raise TypeError
      end
      val
    end

    def description
      "factory size #{@_attributes.size}"
    end
end
