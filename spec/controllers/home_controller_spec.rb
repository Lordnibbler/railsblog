require 'rails_helper'

describe HomeController do
    fixtures :posts

    let!(:post) { posts(:short) }
    let!(:long_post) { posts(:long) }

    describe 'get #show' do
        subject(:get_show) { get "show" }

        before { get_show }

        pending 'fetches blog posts' do
            get '/'
            expect(assigns(:posts)).to eq([post, long_post])
        end
    end
end