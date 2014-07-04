#! /bin/bash
set -o errexit -o pipefail
bundle exec rspec spec/recipes/default_spec.rb
bundle exec rspec spec/recipes/master_spec.rb
bundle exec rspec spec/recipes/slave_spec.rb
