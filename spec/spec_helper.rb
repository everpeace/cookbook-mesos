# encoding: utf-8

require 'chefspec'
require 'chefspec/berkshelf'

require 'chef/application'

RSpec.configure do |config|
  # Default platform used
  config.platform = 'ubuntu'

  # Default platform version
  config.version = '12.04'
end

at_exit { ChefSpec::Coverage.report! }
