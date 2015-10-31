require './factory_helper'
# Factory class provides a way to store in the same objects other different
# predefined objects also as methods.
# Usage:
#   Customer = Factory.new(:name, :address, :zip)
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
  def self.new *attributes, &block
    raise ArgumentError, 'wrong number of arguments (0 for 1+)' if attributes.empty?

    # If the first argument is a String we treat it as new Factory class name
    class_name = attributes[0].is_a?(String) ? attributes.shift : nil
    attributes.map!(&:to_sym)
    
    # New class is inhereted from self (Factory), so superclass call will
    # return "Factory". Unfortunately this inheritance brake down "new" method
    # so we have to restore it inside class definition
    new_class = Class.new(self) do
      include Enumerable
      include FactoryHelper
      const_set :MEMBERS, attributes
      const_set :BLOCK, block

      def self.new *values
        inst = allocate
        inst.send :initialize, *values
        inst
      end

      def initialize *values
        raise ArgumentError, 'factory size differs' if values.size > members.size
        values.each_with_index { |val, i| instance_variable_set "@#{members[i]}", val }
      end

      attributes.each do |attribute|
        attr_accessor attribute

        define_method '[]' do |key|
          instance_variable_get "@#{attribute_convert key}"
        end

        define_method '[]=' do |key, value|
          instance_variable_set "@#{attribute_convert key}", value
        end
      end

      def == other
        if self.class != other.class
          return false if other.members.sort - members.sort != []
          return false if self.class.const_get(:BLOCK) != other.class.const_get(:BLOCK)
        end

        members.each do |attribute|
          return false if send(attribute) != other.send(attribute)
        end
        true
      end

      def each &block
        if block
          members.each { |a| block.call send(a) }
          self
        else
          to_enum(:each)
        end
      end

      def each_pair &block
        if block
          members.each { |a| block.call a, send(a) }
          self
        else
          to_enum(:each_pair)
        end
      end

      def to_h
        h = {}
        each_pair {|a, b| h.merge!([[a, b]].to_h)}
        h
      end

      def length
        members.size
      end

      def self.members
        const_get :MEMBERS
      end

      def members
        self.class.members
      end

      def values_at start, size
        to_a.values_at start, size
      end

      alias_method :values, :to_a
      alias_method :eql?, :==
      alias_method :size, :length

      class_eval(&block) unless block.nil?
    end

    class_name ? const_set(class_name, new_class) : new_class

  end
end
