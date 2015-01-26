RSpec.configure do |config|
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # Print tests results with color.
  config.color = true

  # Only accept the new syntax of "expect" instead of "should".
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

require 'yaml'
require 'deathbycaptcha'


CREDENTIALS = YAML.load_file('spec/credentials.yml')
