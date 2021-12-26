# rubocop:disable Layout/LineLength
FactoryBot.define do
  factory :post, class: Blog::Post do
    user

    title { 'I love bacon' }
    body { 'Bacon ipsum dolor amet shankle beef ribs bresaola chicken.' }
    slug { 'i-love-bacon' }
    published { true }

    factory :long_post do
      title { 'I hate bacon' }
      body { 'Bacon ipsum dolor amet shankle beef ribs bresaola chicken. <!--more--> Shoulder boudin pork, capicola venison doner landjaeger prosciutto biltong filet mignon porchetta chicken pork belly tenderloin pancetta.' }
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
# rubocop:enable Layout/LineLength
