# == Schema Information
#
# Table name: dictionaries
#
#  id    :integer(4)      not null, primary key
#  key   :string(16)      not null
#  value :string(1024)
#

# The dictionary is a key-value storage for miscelanous things.
#
class Dictionary < ActiveRecord::Base

  validates_presence_of :key
  validates_presence_of :value

### Shortcuts ###

  def self.[](k)
    term = where(:key => k).select(:value).first
    term && term.value
  end

  def self.[]=(k,v)
    k = connection.quote(k)
    v = connection.quote(v)
    stmt = "INSERT INTO dictionaries(`key`, `value`) VALUES (#{k}, #{v}) ON DUPLICATE KEY UPDATE `value`=#{v}"
    connection.insert_sql(stmt)
  end

  def self.collection(coll)
    # TODO can I remove this 'all'?
    where('`key` LIKE ?', "#{coll}[%]").all
  end

  # TODO dead code?
  def self.collection_get(coll, k)
    self["#{coll}[#{k}]"]
  end

  def key
    k = read_attribute(:key)
    return $1 if k =~ /\[(\w+)\]$/
    k
  end

end
