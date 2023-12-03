FactoryBot.define do
  factory :stats, class: "AocCli::Stats" do
    event { association(:event) }

    1.upto(25) do |i|
      send(:"day_#{i}") { 0 }
    end
  end
end
