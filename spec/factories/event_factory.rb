FactoryBot.define do
  factory :event, class: "AocCli::Event" do
    year { (2015..2023).to_a.sample }

    trait :with_location do
      transient do
        path { "foo/bar/baz" }
      end

      after(:create) do |event, evaluator|
        create(:location, :year_dir, event:, path: evaluator.path)
      end
    end
  end
end
