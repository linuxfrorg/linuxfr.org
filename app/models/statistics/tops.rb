# encoding: utf-8
class Statistics::Tops

  def last_three_months
    @months ||= (Date.today - 3.months) .. Date.tomorrow
  end

  def top_authors(type, nb, on_three_months)
    nodes = Node.where(content_type: type)
    nodes = nodes.where(created_at: last_three_months) if on_three_months
    nodes.where(public: true).
          where("user_id IS NOT NULL").
          where("user_id != 1").         # Anonyme has the user_id 1
          group("user_id").
          select("COUNT(*) AS score, user_id").
          order("score DESC").
          limit(nb).
          map {|n| [n.user, n.score] }
  end

end
