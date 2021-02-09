arr = ["hello", true, false, "world", nil]
print arr.map.with_index{|a, i| [i, a == false ? nil : a]}.to_h


arr.each do |a|
	if a
		p a
	end
end
puts "nil nil nil" if true
p File.read(".meta") ||= :hello
