require 'rails_helper'

RSpec.describe WelcomeController, type: :controller do
  describe 'GET /' do
    it 'renders the welcome/index' do
      get :index
      expect(response).to render_template('welcome/index')
      expect(response).to have_http_status(200)
    end
  end
end
