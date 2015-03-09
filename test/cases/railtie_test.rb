require 'rails'
require 'tzinfo'
require 'global_id/railtie'
require 'active_support/testing/isolation'

# 3.2 Port
# In 3.2 Applications can't be instantied with #new
# ActiveSupport::Testing::Isolation saves us here
# we also added deprecation notice silence
module BlogApp
  class Application < Rails::Application
    config.eager_load = false
    config.logger = Logger.new(nil)
    config.active_support.deprecation = :log
  end
end

class RailtieTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::Isolation

  test 'GlobalID.app for Blog::Application defaults to blog' do
    BlogApp::Application.initialize!
    assert_equal 'blog-app', GlobalID.app
  end

  test 'GlobalID.app can be set with config.global_id.app =' do
    BlogApp::Application.class_eval do
      config.global_id.app = 'foo'
    end
    BlogApp::Application.initialize!
    assert_equal 'foo', GlobalID.app
  end

  test 'SignedGlobalID.verifier defaults to nil in rails 3.2 even when secret token is present' do
    BlogApp::Application.class_eval do
     config.secret_token = ('x' * 30)
    end
    BlogApp::Application.initialize!
    assert_nil SignedGlobalID.verifier
  end 

# app message verifier does not exist in rails 3.2
#  test 'SignedGlobalID.verifier defaults to Blog::Application.message_verifier(:signed_global_ids) when secret_token is present' do
#    @app.config.secret_token = ('x' * 30)
#    @app.initialize!
#    message = {id: 42}
#    signed_message = SignedGlobalID.verifier.generate(message)
#    assert_equal @app.message_verifier(:signed_global_ids).generate(message), signed_message
#  end

  test 'SignedGlobalID.verifier defaults to nil when secret_token is not present' do
    BlogApp::Application.initialize!
    assert_nil SignedGlobalID.verifier
  end

  test 'SignedGlobalID.verifier can be set with config.global_id.verifier =' do
    custom_verifier = ActiveSupport::MessageVerifier.new('muchSECRETsoHIDDEN', serializer: SERIALIZER)
    BlogApp::Application.class_eval do
      config.global_id.verifier = custom_verifier
    end
    BlogApp::Application.initialize!
    message = {id: 42}
    signed_message = SignedGlobalID.verifier.generate(message)
    assert_equal custom_verifier.generate(message), signed_message
  end

end
