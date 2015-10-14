#require 'byebug'
class Factory
  def initialize(*args_undef, **args_def, &block)
    args = {}                                 # Argument order
    args_undef.each {|s| args.store(s, nil)}  # shouln't be changed
    args.merge! args_def                      # here

    @_members_list = []
    args.each do |name, default|
      @_members_list << name
      instance_variable_set "@#{name}", default

      self.class.send :define_method, "#{name}" do
        instance_variable_get "@#{name}"
      end
      self.class.send :define_method, "#{name}=" do |val|
        instance_variable_set "@#{name}", val
      end
    end

    instance_eval &block if block
  end

  def [] attribute
    attribute = "#{@_members_list[attribute]}" if attribute.is_a? Fixnum
    send attribute.to_s
  end

  def []= attribute, value
    attribute = "#{@_members_list[attribute]}=" if attribute.is_a? Fixnum
    send attribute.to_s, value
  end
end

1000.times do
f = Factory.new( :a, :b, :c, d: 1, e: 2) {
  def hello
    'Hi, there'
  end

  def sum
    a + b
  end
}
end
# byebug
#  puts f[:a]
# puts f['a']
# puts f[0]

# f[0] = 1
# f[:b] = 2
# f['c'] = 3

# puts f[0]
# puts f['b']
# puts f[:c]
