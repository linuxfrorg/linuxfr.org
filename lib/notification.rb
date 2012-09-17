# encoding: utf-8

# First we need to override AtomFeedHelper to add a line to resulting
# Atom like <link rel="hub" href="http://pubsubhubbub.appspot.com"/>
module ActionView
  module Helpers
    module AtomFeedHelper

      class AtomFeedBuilder
        def pubsubhubbub_hub url
          @xml.link(:rel => 'hub', :href => url) if url
        end
      end

    end
  end
end

module Notification
  require 'redis'

  def notify url

    # 1st command adds urls to notify
    # 2nd and 3rd commands make sure that the key is a list that
    # contains 1 element, used as a relay for client processing
    lua_script = <<-EOF
      redis.call('SADD', KEYS[0], ARGS[0])
      redis.call('DEL', KEYS[1])
      redis.call('LPUSH', KEYS[1], "anchor")
    EOF

    error = begin
              Redis::CommandError
            rescue NameError
              RuntimeError # Dirty dirty hack for redis gem before 3.0
            end

    begin
      $redis.eval(lua_script, ["updated_atom", "updated_atom_blocker"], [url])
    rescue error
      # No scripting, use old-style transactions
      $redis.multi do
        $redis.sadd "updated_atom", url
        $redis.del "updated_atom_blocker"
        $redis.lpush "updated_atom_blocker", "anchor"
      end
    end
  end

end

