module Moderation::NewsHelper

  def voters_for(news)
    votes  = news.node.votes.all(:conditions => {:vote => true})
    voters = votes.map {|v| v.user.public_name}
    voters.to_sentence
  end

  def voters_against(news)
    votes  = news.node.votes.all(:conditions => {:vote => false})
    voters = votes.map {|v| v.user.public_name}
    voters.to_sentence
  end

end
