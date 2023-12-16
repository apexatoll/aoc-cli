FactoryBot.define do
  factory :puzzle, class: "AocCli::Puzzle" do
    event { association(:event) }

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
