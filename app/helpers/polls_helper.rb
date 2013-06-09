# encoding: utf-8
module PollsHelper

  def poll_body(poll)
    content_tag(:ul) do
      poll.answers.map do |answer|
        content_tag(:li, answer.answer)
      end.join.html_safe
    end
  end

  def poll_current_or_archived(poll)
    poll.answerable_by?(request.remote_ip) ? 'current' : 'archived'
  end

  # Build at least 6 answers for a poll
  # and always add a new answer if the last is not blank,
  # so people without js can add as many answers as they want
  # (one new per preview).
  def setup_poll(poll)
    (poll.answers.size ... 6).each { poll.answers.build }
    poll.answers.build unless poll.answers.last.answer.blank?
    poll
  end

end
