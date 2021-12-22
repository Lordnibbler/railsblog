require 'rails_helper'

describe HomeController do
    it 'successfully renders the index template on GET /', type: :request do
      get "/"
      
      expect(response).to be_successful
      expect(response).to render_template(:index)
      expect(response).to render_template("home/_hero")
      expect(response).to render_template("home/_about")
      expect(response).to render_template("home/_expertise")
      expect(response).to render_template("home/_work")
      expect(response).to render_template("home/_games")
      expect(response).to render_template("home/_videos")
      expect(response).to render_template('home/_blog')
      expect(response).to render_template("home/_contact")
      expect(response).to render_template("home/_newsletter")
    end
  end