# Validate if a value is a HTTP url
class HttpUrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present? && not(valid?(value, options))
      record.errors.add attribute, (options[:message] || "n'est pas une URL HTTP valide")
    end
  end

  private

  def valid?(value, options)
    # Valid links can be parsed by URI
    uri = URI.parse(value)
    # Authorize protocol
    if options.has_key?(:protocols)
      return options[:protocols].include?(uri.scheme)
    end
    # Links starting with "//MY_DOMAIN" are current scheme dependent and are valid
    return true if uri.scheme.nil? && uri.host == MY_DOMAIN
    # All other links are valid only if scheme and host exists
    return uri.scheme.present? && uri.host.present?
  rescue URI::InvalidURIError
    false
  end 
end
