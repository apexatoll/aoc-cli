FactoryBot.define do
  factory :puzzle, class: "AocCli::Puzzle" do
    event { association(:event) }

    day { (1..25).to_a.sample }

    content { "Markdown" }
    input { "input" }
  end
end
