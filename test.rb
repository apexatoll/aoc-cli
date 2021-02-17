



#cookie=>main=>session=


key = "session=53616c7465645f5f3a1c14bc758190ea09843bae1f9a4d6b6aa59895587d48dbe7e5a973dd6f69b5325eedcad3877038"

puts key.length

/session=[a-f0-9]{96}/.match?(key)
