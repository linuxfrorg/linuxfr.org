# encoding: utf-8
class Statistics::Statistics

  def select_all(sql)
    ActiveRecord::Base.connection.select_all(sql)
  end

  def count(sql, field="cnt")
    rows = select_all(sql)
    rows.any? ? rows.first[field] : 0
  end

end
