require 'generator_spec'
require_relative '../../../lib/wor/generators/wor/authentication/install_generator'

describe Wor::Authentication::Generators::InstallGenerator, type: :generator do
  context 'generating the initializer ' do
    destination File.expand_path('../../../../tmp', __FILE__)

    before(:all) do
      prepare_destination
      run_generator
    end

    it 'generates the correct structure for initializer' do
      expect(destination_root).to have_structure do
        no_file 'wor_authentication.rb'
        directory 'config' do
          no_file 'wor_authentication.rb'
          directory 'initializers' do
            file 'wor_authentication.rb' do
              contains 'Wor::Authentication.configure do'
            end
          end
        end
      end
    end
  end
end
