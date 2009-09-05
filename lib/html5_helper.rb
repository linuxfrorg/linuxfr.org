module ActionView
  module Helpers
    module FormHelper
      def email_field(object_name, method, options = {})
        InstanceTag.new(object_name, method, self, options.delete(:object)).to_input_field_tag("email", options)
      end

      def url_field(object_name, method, options = {})
        InstanceTag.new(object_name, method, self, options.delete(:object)).to_input_field_tag("url", options)
      end
    end

    class FormBuilder
      def email_field(method, options={})
        @template.send("email_field", @object_name, method, objectify_options(options))
      end

      def url_field(method, options={})
        @template.send("url_field", @object_name, method, objectify_options(options))
      end
    end
  end
end
