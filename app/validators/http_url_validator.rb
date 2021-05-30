# Validate if a value is a HTTP url
class HttpUrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present? && not(valid?(value, options))
      record.errors.add attribute, (options[:message] || "n'est pas une URL HTTP valide")
    end
  end

  private

  def valid?(value, options)
    uri = URI.parse(value)
    if uri.scheme.blank? && uri.host.blank?
      value = "http://#{value}"
      uri = URI.parse(value)
    end
    if options.has_key?(:protocols)
      return true if options[:protocols].include?(uri.scheme)
    end
    uri.scheme.nil? && uri.host == MY_DOMAIN
  rescue URI::InvalidURIError
    false
  end 
end
