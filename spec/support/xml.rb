def some_xml
  Nokogiri::XML(open('spec/fixtures/some.xml') { |f| f.read })
end