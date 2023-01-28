# Validate if a value is a URI
class UriValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present? && not(valid?(value, options))
      record.errors.add attribute, (options[:message] || "n'est pas un lien valide")
    end
  end

  private

  def valid?(value, options)
    # Valid links can be parsed by URI
    uri = URI.parse(value)

    # Authorize only given protocol
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

  def self.before_validation(raw, default_scheme='http://')
    raw.strip!
    return nil if raw.blank?

    # Automatically encodes sharp signs (#) found in URI fragment:
    # RFC 3986 uses sharp to define URI fragment and requires other sharps
    # to be percent encoded
    fragments = raw.split("#")
    if (fragments.length > 2)
      raw = fragments[0] + '#' + fragments[1..-1].join('%23')
    end

    uri = URI.parse(raw)

    # If user forgot to add scheme, add default
    if default_scheme.present? && uri.scheme.blank? && uri.host.blank?
      raw = "#{default_scheme}#{raw}"
      uri = URI.parse(raw)
    end

    return uri.to_s

  # Let raw value if error occured when we tried to parse it, because
  # the UriValidator will manage it itself on validation
  rescue URI::InvalidURIError
    return raw
  end

  def self.after_validation(raw)
    # Decodes sharp signs (#) found in URI fragment to keep visual match with
    # the user input
    fragments = raw.split("#")
    if (fragments.length == 2)
      raw = fragments[0] + '#' + fragments[1].gsub('%23', '#')
    end

    return raw
  end

end
