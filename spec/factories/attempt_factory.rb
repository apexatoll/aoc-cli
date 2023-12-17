FactoryBot.define do
  factory :attempt, class: "AocCli::Attempt" do
    puzzle { association :puzzle }
    level  { [1, 2].sample }
    answer { 123 }

    trait :part_one do
      level { 1 }
    end

    trait :part_two do
      level { 2 }
    end

    trait :wrong_level do
      status { :wrong_level }
    end

    trait :rate_limited do
      status { :rate_limited }
      wait_time { 1 }
    end

    trait :incorrect do
      status { :incorrect }
      wait_time { 1 }
    end

    trait :too_low do
      incorrect
      hint { :too_low }
    end

    trait :too_high do
      incorrect
      hint { :too_high }
    end

    trait :correct do
      status { :correct }
      hint { nil }
      wait_time { nil }
    end
  end
end
