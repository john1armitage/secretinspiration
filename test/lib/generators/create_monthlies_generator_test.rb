require 'test_helper'
require 'generators/create_monthlies/create_monthlies_generator'

class CreateMonthliesGeneratorTest < Rails::Generators::TestCase
  tests CreateMonthliesGenerator
  destination Rails.root.join('tmp/generators')
  setup :prepare_destination

  # test "generator runs without errors" do
  #   assert_nothing_raised do
  #     run_generator ["arguments"]
  #   end
  # end
end
