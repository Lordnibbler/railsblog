FactoryBot.define do
  factory :user do
    email { "ben@benradler.com" }
    sign_in_count { 4 }
    name { "Ben Radler" }
    avatar_url { "http://1.gravatar.com/avatar/91250146d344dff9714afd00050f6bfd" }
    biography { "Ben is a Software Engineer. He works at Lyft in San Francisco, California." }
    password { 'password' }
    password_confirmation { 'password' }
  end
end