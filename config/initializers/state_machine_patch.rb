# See https://github.com/pluginaweek/state_machine/issues/251
module StateMachine
  module Integrations
     module ActiveModel
        public :around_validation
     end

     module ActiveRecord
        public :around_save
     end
  end
end
