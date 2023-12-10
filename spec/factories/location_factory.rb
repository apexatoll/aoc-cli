FactoryBot.define do
  factory :location, class: "AocCli::Location" do
    path { "foo/bar/baz" }

    trait :year_dir do
      transient do
        event { association :event }
      end

      resource { event }
    end

    trait :puzzle_dir do
      transient do
        puzzle { association :puzzle }
      end

      resource { puzzle }
    end
  end
end
