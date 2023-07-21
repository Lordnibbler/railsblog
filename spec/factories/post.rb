FactoryBot.define do
  factory :post, class: 'Blog::Post' do
    user

    title { 'I love bacon' }
    body { 'Bacon ipsum dolor amet shankle beef ribs bresaola chicken.' }
    slug { 'i-love-bacon' }
    published { true }

    after :build do |post|
      post.featured_image.attach(
        io: Rails.root.join('spec/factories/fixture_files/test.jpg').open,
        filename: 'test.jpg',
        content_type: 'image/jpeg',
      )
    end

    factory :long_post do
      title { 'I hate bacon' }
      body do
        'Spicy jalapeno bacon ipsum dolor amet ullamco nisi deserunt, labore sed velit excepteur.' \
          '<!--more--> ' \
          'Deserunt venison ball tip chislic, est veniam enim do. Velit pork chop filet mignon buffalo. ' \
          'Meatball tri-tip dolore corned beef quis shankle, do culpa nulla biltong.'
      end
      slug { 'i-hate-bacon' }
    end

    factory :unpublished_post do
      title { 'I unpublished the bacon' }
      body { 'Bacon no longer was published.' }
      slug { 'i-unpublished-the-bacon' }
      published { false }
    end
  end
end
