module Wor
  module Authentication
    module Generators
      class InstallGenerator < Rails::Generators::Base
        source_root File.expand_path('../../../templates', __FILE__)
        desc 'Creates wor_authentication initializer for your application'

        def copy_initializer
          template 'wor_authentication.rb', 'config/initializers/wor_authentication.rb'
        end
      end
    end
  end
end
