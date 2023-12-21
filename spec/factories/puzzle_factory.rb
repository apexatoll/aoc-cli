FactoryBot.define do
  factory :puzzle, class: "AocCli::Puzzle" do
    transient do
      year { (2015..2023).to_a.sample }
    end

    event { association(:event, year:) }

    day { (1..25).to_a.sample }

    content { "Markdown" }
    input { "input" }

    trait :with_location do
      transient do
        path { "foo/bar/baz" }
      end

      after(:create) do |puzzle, evaluator|
        create(:location, :puzzle_dir, puzzle:, path: evaluator.path)
      end
    end
  end
end
