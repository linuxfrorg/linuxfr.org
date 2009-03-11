# == Schema Information
# Schema version: 20090310234743
#
# Table name: poll_ips
#
#  id :integer(4)      not null, primary key
#  ip :integer(4)      not null
#

class PollIp < ActiveRecord::Base

  def self.has_voted?(ip)
    exists?(:ip => ip2int(ip))
  end

  # Transform a dotted IP address to an integer
  #   PollIp.ip2int('127.0.0.1')  # => 2130706433
  def self.ip2int(addr)
    addr.split('.').inject(0) {|s,v| 256 * s + v.to_i }
  end

  # Transform an integer to a dotted IP address
  #   PollIp.int2ip(2130706433)  # => '127.0.0.1'
  def self.int2ip(value)
    addr  = []
    4.times do
      value, x = value.divmod(256)
      addr.unshift x
    end
    addr.join('.')
  end

  def ip=(addr)
    write_attribute :ip, self.class.ip2int(addr)
  end

  def ip
    self.class.int2ip read_attribute(:ip)
  end

end
