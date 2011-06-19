Country::NameIndex.each do |name, code|
  code = code.downcase
  Location.create!(:name => name, :code => code, :flag => "#{code}.png")
end
