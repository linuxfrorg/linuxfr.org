module PollsHelper

  def poll_body(poll)
    content_tag(:ul) do
      safe_join poll.answers.map do |answer|
        content_tag(:li, answer.answer)
      end
    end
  end

  def poll_current_or_archived(poll)
    poll.answerable_by?(request.remote_ip) ? 'current' : 'archived'
  end

  # Build at least 6 answers for a poll
  # and always add a blank new answer,
  # so people without js can add as many asnwers as they want
  # (one new per preview).
  def setup_poll(poll)
    (poll.answers.size ... 5).each { poll.answers.build }
    poll.answers.build
    poll
  end

end
