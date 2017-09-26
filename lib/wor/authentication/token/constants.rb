module Wor
  module Authentication
    module Token
      module Constants
        module_function

        DEFAULT_ALGORITHM = 'HS256'.freeze

        def current_time
          # TODO: Use a ruby standard library for time
          Time.zone.now.to_i
        end
      end
    end
  end
end
