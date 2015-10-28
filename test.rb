C = Class.new do
  CC = 'Static const CC'
  def cc
    puts CC
  end

  const_set :CCC, 'Dynamic const CCC'

  define_method :dd do
    puts self.class.const_get :CCC
  end
end

C.new.cc
C.new.dd