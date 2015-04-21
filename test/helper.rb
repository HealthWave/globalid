require 'bundler/setup'
require 'active_support'
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/date/calculations'
require 'time_helper'
require 'minitest/autorun'
require 'active_model'
require 'global_id'
require 'models/person'
require 'models/person_model'

require 'json'

# 3.2 Port
# all the changes here to make tests that were written to
# run in a 4.2 environment work here.
#
# Note these are also added to "get it working":
#   test/time_helper.rb
#   test/models/active_modle

# just not going to work in 3.2
#if ActiveSupport::TestCase.respond_to?(:test_order)
#  # TODO: remove check once ActiveSupport depencency is at least 4.2
#  ActiveSupport::TestCase.test_order = :random
#end

GlobalID.app = 'bcx'

# Default serializers is Marshal, whose format changed 1.9 -> 2.0,
# so use a trivial serializer for our tests.
SERIALIZER = JSON

VERIFIER = ActiveSupport::MessageVerifier.new('muchSECRETsoHIDDEN', serializer: SERIALIZER)
SignedGlobalID.verifier = VERIFIER

class ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  def assert_not(object, message = nil)
    message ||= "Expected #{mu_pp(object)} to be nil or false"
    assert !object, message
  end
end
