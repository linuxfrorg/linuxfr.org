# encoding: utf-8
# Monkey-patching of canable to use current_account instead of current_user
require 'canable'
module Canable
  def self.add_enforcer_method(can)
    Enforcers.module_eval <<-EOM
      def can_#{can}?(resource)
        current_account && current_account.can_#{can}?(resource)
      end

      def enforce_#{can}_permission(resource, message="")
        raise(Canable::Transgression, message) unless can_#{can}?(resource)
      end
      private :enforce_#{can}_permission
    EOM
  end
end

Canable.add(:view,    :viewable)
Canable.add(:create,  :creatable)
Canable.add(:update,  :updatable)
Canable.add(:destroy, :destroyable)
Canable.add(:vote,    :votable)
Canable.add(:comment, :commentable)
Canable.add(:tag,     :taggable)
Canable.add(:accept,  :acceptable)
Canable.add(:refuse,  :refusable)
Canable.add(:rewrite, :rewritable)
Canable.add(:reassign,:reassignable)
Canable.add(:reset,   :resetable)
Canable.add(:ppp,     :pppable)
Canable.add(:answer,  :answerable)
