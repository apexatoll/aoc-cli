FactoryBot.define do
  factory :progress, class: "AocCli::Progress" do
    puzzle { association :puzzle }

    started_at { Time.now }

    trait :part_one do
      level { 1 }
    end

    trait :part_two do
      level { 2 }
    end
  end
end
