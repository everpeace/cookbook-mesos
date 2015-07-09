# encoding: utf-8

require 'chefspec'
require 'chefspec/berkshelf'
ChefSpec::Coverage.start!

require 'chef/application'

RSpec.configure do |config|
  # Default platform used
  config.platform = 'ubuntu'

  # Default platform version
  config.version = '14.04'

  # Omit warnings from output
  config.log_level = :fatal
end

require 'support/source_installation'
