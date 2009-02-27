##
# if ''.not.blank?
# http://blog.jayfields.com/2007/08/ruby-adding-not-method-for-readability.html
class Object
  define_method :not do
    Not.new(self)
  end

  class Not
    private *instance_methods.select { |m| m !~ /(^__|^\W|^binding$)/ }

    def initialize(subject)
      @subject = subject
    end

    def method_missing(sym, *args, &blk)
      !@subject.send(sym,*args,&blk)
    end
  end
end

