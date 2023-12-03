FactoryBot.define do
  factory :event, class: "AocCli::Event" do
    year { (2015..2023).to_a.sample }
  end
end
