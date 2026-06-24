# encoding: UTF-8
# == Schema Information
#
# Table name: poll_answers
#
#  id         :integer          not null, primary key
#  poll_id    :integer          not null
#  answer     :string(128)      not null
#  votes      :integer          default(0), not null
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#

#
class PollAnswer < ActiveRecord::Base
  belongs_to :poll

  acts_as_list scope: :poll

  validates :answer, presence: { message: "La description de la réponse ne peut pas être vide" },
                     length: { maximum: 128, message: "La description de la réponse est trop longue" }

  PROTOCOLS = HTML::Pipeline::SanitizationFilter::WHITELIST[:protocols]['a']['href'] - [:relative]

  def answer=(raw)
    raw.strip!
    # Filter invalid URIs in []() links
    uri_parser = URI::Parser.new
    raw.gsub(/\[([^\]]*)\]\(([^)]*)\)/) {
      |item|
      uri = uri_parser.parse("#{$2}")
      if PROTOCOLS.include?(uri.scheme)
        "[#{$1}](#{uri})"
      else
        "❌protocol"
      end
    }
    write_attribute :answer, raw
  rescue URI::InvalidURIError
    "❌URI"
  end

  def percent
    return 0.0 if poll.total_votes == 0
    "%.1f" % (100.0 * votes / poll.total_votes)
  end

  def vote(ip)
    self.class.increment_counter(:votes, self.id)
    poll.vote(ip)
  end

  # Escape HTML + transform []() to links on the given text
  def formatted
    uri_parser = URI::Parser.new
    ERB::Util.html_escape(answer).to_param.gsub(/\[([^\]]*)\]\(([^)]*)\)/) {
      |item|
      uri = uri_parser.parse("#{$2}")
      if PROTOCOLS.include?(uri.scheme)
        %Q[<a href="#{uri}">#{$1}</a>]
      else
        "❌protocol"
      end
    }.html_safe
  rescue URI::InvalidURIError
    "❌URI"
  end
end
