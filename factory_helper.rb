# Some helper method for Factory class
module FactoryHelper
  include Enumerable

  def each &block
    if block
      members.each { |a| block.call send(a) }
      self
    else
      members.to_enum
    end
  end

  def to_s
    str = "\#<factory #{self.class.name}"
    str << members.inject("") { |str, a| str << " #{a}=#{(send a).inspect}" }
    str << ">"
  end

  alias_method :inspect, :to_s

  private

  # When val is String or Symbol
  #   it checks if val is present in attribute's list and raise an error
  #     if abscent
  # When val is Fixnum
  #   it checks if val is in valid range
  #     raise an error if out of range
  #     converts to attribute name otherwise
  def attribute_convert val
    case val
    when Fixnum
      if val >= members.size
        raise IndexError, "offset #{val} too large for #{description}"
      elsif val < (members.size * -1)
        raise IndexError, "offset #{val} too small for #{description}"
      end

      val = members.size + val if val < 0
      val = members[val]
    when Symbol, String
      val = val.to_sym
      unless members.include? val
        raise NameError, "no attribute #{val} in factory"
      end
    else
      raise TypeError
    end
    val
  end

  def description
    "factory size #{members.size}"
  end
end
