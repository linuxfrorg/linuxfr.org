class NewsVersion < ActiveRecord::Base
  belongs_to :news
  belongs_to :user

  acts_as_list :column => 'version', :scope => :news

### Append-only ###

  before_update :raise_on_update
  def raise_on_update
    raise ActiveRecordError.new "On ne modifie pas les anciennes versions !"
  end

end
