require 'spec_helper'

describe ProfilesController, :type => :controller do
  include HelperMethods::Controllers

  describe 'POST update' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:params) { { user: { email: 'mynew@email.com' } } }

    subject { post :update, params }

    before { sign_in(user) }

    it 'updates user email' do
      expect_any_instance_of(User).to receive(:update_attributes).with(params[:user]).and_return(true)
      subject
    end

    it 'assigns flash message' do
      subject
      expect(flash[:notice]).to eq(I18n.t('flash.notice.profile_email_updated'))
    end

    it 'redirects to profile_path' do
      subject
      expect(response).to redirect_to(profile_path)
    end

    it 'delivers a confirmation e-mail' do
      expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    context 'when user initial email is blank (probably because of a initial sign up via twitter)' do
      let!(:user) { sign_in_user_without_email(request) }

      it 'delivers a confirmation e-mail' do
        expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end

  describe 'GET resend_confirmation_email' do
    let!(:user) { FactoryGirl.create(:user) }

    subject { get :resend_confirmation_email }

    before { sign_in(user) }

    it 'assigns flash message' do
      subject
      expect(flash[:notice]).to eq(I18n.t('flash.notice.profile_email_confirmation_sent'))
    end

    it 'delivers a confirmation e-mail' do
      expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'redirects to edit_profile_path' do
      subject
      expect(response).to redirect_to(edit_profile_path(user))
    end
  end
end
