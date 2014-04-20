# encoding: utf-8
class Statistics::Prizes
  attr_reader :month

  def initialize(month)
    @month = Date.today
    if month.present?
      m, y = month.split("-").map(&:to_i)
      @month = Date.new(y, m, 1) if m && y
    end
  end

  def current_month
    @current_month ||= @month.beginning_of_month .. @month.next_month.beginning_of_month
  end

  def best_score(type, nb)
    Node.where(content_type: type.to_s).
         where(created_at: current_month).
         where(public: true).
         where("user_id IS NOT NULL").
         order("score DESC").
         limit(nb).
         map {|n| [n.content, n.score] }
  end

  def sum_comments_score(type, nb)
    Node.joins(:comments).
         group("comments.node_id").
         select("SUM(comments.score) AS sum_score, nodes.content_type, nodes.content_id, nodes.user_id").
         where(content_type: type.to_s).
         where(created_at: current_month).
         where(public: true).
         where("nodes.user_id IS NOT NULL").
         order("sum_score DESC").
         limit(nb).
         map {|n| [n.content, n.sum_score] }
  end

  def longest_news(type, nb)
    News.select("LENGTH(body) + LENGTH(second_part) AS total, news.*").
         joins("JOIN nodes ON nodes.content_id = news.id").
         where("nodes.content_type = 'News'").
         where("nodes.created_at" => current_month).
         where("nodes.public" => true).
         where("nodes.user_id IS NOT NULL").
         order("total DESC").
         limit(nb).
         map {|n| [n, n.total] }
  end

  def top_authors(type, nb)
    Node.where(content_type: type.to_s).
         where(created_at: current_month).
         where(public: true).
         where("user_id IS NOT NULL").
         group("user_id").
         select("COUNT(*) AS score, user_id").
         order("score DESC").
         limit(nb).
         map {|n| [n.user, n.score] }
  end

  def top_commenters(type, nb)
    Node.where(content_type: type.to_s).
         joins(:comments).
         where("comments.created_at" => current_month).
         where("comments.state" => "published").
         where("comments.user_id IS NOT NULL").
         group("comments.user_id").
         select("COUNT(*) AS score, comments.user_id").
         order("score DESC").
         limit(nb).
         map {|c| [c.user, c.score] }
  end

end
