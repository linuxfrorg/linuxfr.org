module Moderation::NewsHelper

  def voters_for(news)
    voters_condition(news, true)
  end

  def voters_against(news)
    voters_condition(news, false)
  end

  def voters_condition(news, bool)
    votes  = news.node.votes.all(:conditions => { :vote => bool })
    voters = votes.map { |v| v.user.name }
    voters.to_sentence
  end
  # TODO safe_helper :voters_condition

end
