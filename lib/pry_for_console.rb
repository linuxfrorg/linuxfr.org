# See http://burkelibbey.posterous.com/using-pry-instead-of-irb-for-rails-console

module Rails
  class Console
    class IRB
      def self.start
        Pry.start
      end
    end
  end
end
