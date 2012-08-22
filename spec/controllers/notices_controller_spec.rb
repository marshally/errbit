require 'spec_helper'

describe NoticesController do

  context 'notices API' do
    before do
      @xml = Rails.root.join('spec','fixtures','hoptoad_test_notice.xml').read
      @app = Fabricate(:app_with_watcher)
      App.stub(:find_by_api_key!).and_return(@app)
      @notice = App.report_error!(@xml)

      request.env['Content-type'] = 'text/xml'
      request.env['Accept'] = 'text/xml, application/xml'
    end

    it "generates a notice from xml [POST]" do
      App.should_receive(:report_error!).with(@xml).and_return(@notice)
      request.should_receive(:raw_post).and_return(@xml)
      post :create
      response.should be_success
      # Same RegExp from Airbrake::UserInformer#replacement (https://github.com/airbrake/airbrake/blob/master/lib/airbrake/user_informer.rb#L8)
      # Inspired by https://github.com/airbrake/airbrake/blob/master/test/sender_test.rb
      response.body.should match(%r{<id[^>]*>#{@notice.id}</id>})
    end

    it "generates a notice from xml [GET]" do
      App.should_receive(:report_error!).with(@xml).and_return(@notice)
      get :create, {:data => @xml}
      response.should be_success
      response.body.should match(%r{<id[^>]*>#{@notice.id}</id>})
    end

    it "sends a notification email" do
      App.should_receive(:report_error!).with(@xml).and_return(@notice)
      request.should_receive(:raw_post).and_return(@xml)
      post :create
      response.should be_success
      response.body.should match(%r{<id[^>]*>#{@notice.id}</id>})
      email = ActionMailer::Base.deliveries.last
      email.to.should include(@app.watchers.first.email)
      email.subject.should include(@notice.message)
      email.subject.should include("[#{@app.name}]")
      email.subject.should include("[#{@notice.environment_name}]")
    end
  end

end

