FactoryGirl.define do
  factory :user do
    email     { Faker::Internet.email }
    # Random #'s here because Fake doesn't really have that many unique names
    username  { "#{Faker::Name.first_name}#{rand(1000)}" }
    password 'swordfish'
  end

  factory :team do
    name       { Faker::Lorem.words(num = 3).join(" ")}
    salary      0
    bankroll    10000000
    user
    points      0
    past_points 0
    watches     0
  end

  factory :video do
    salary          0
    initial_watches { rand(100000) }
    watches         0
    yt_id           { Faker::Lorem.characters(char_cout = 6) }
    description     { Faker::Lorem.sentences(sentence_count = 4).join(" ")}
    embed_html5     { Faker::Internet.url }
    thumbnail       { Faker::Internet.url }
    points          0
    team
  end
end
