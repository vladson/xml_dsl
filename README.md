# Xml Dsl

[![Code Climate](https://codeclimate.com/github/vladson/xml_dsl/badges/gpa.svg)](https://codeclimate.com/github/vladson/xml_dsl)

Xml Dsl adds DSL for defining easy parsers (or mappers) for XML via nokogiri XML objects.

## Install

Add `xml_dsl` gem to `Gemfile`:
```
    gem 'xml_dsl', '~> 0.1.1' 
```

## Usage

Let's pretend we have an XML output of a following structure
```
    <root>
      <offer>
        <id>703134</id>
        <distance>10</distance>
        <house>38a</house>
        <rooms>
          <room>1</room>
        </rooms>
        <prices>
          <price>2200000</price>
        </prices>
        <currency>RUR</currency>
        <floor>7</floor>
        <nfloor>17</nfloor>
        <areas>
          <area type="total">37</area>
          <area type="live">0</area>
          <area type="kitchen">10</area>
        </areas>
      </offer>
      <offer>
        <id>703102</id>
        <distance>25</distance>
        <house>7</house>
        <rooms>
          <room>1</room>
        </rooms>
        <prices>
          <price>2650000</price>
        </prices>
        <currency>RUR</currency>
        <floor>1</floor>
        <nfloor>5</nfloor>
        <areas>
          <area type="total">30</area>
          <area type="live">17</area>
          <area type="kitchen">7</area>
        </areas>
        <magick>woodoo</magick>
      </offer>
    </root>
```

Then we can define our mapper as following
```
   class Parser
     attr_accessor :xml, :external
        def initialize(xml, external)
          # Normal iteration goes from xml instance_variable
          self.xml = xml
          self.external = external
        end

        #
        # Here we definig parser, which will put attributes to Hash, and look for <offer> nodes inside <root>
        # any length of root path can be provided, also attributes full path is also a choise
        # define_xml_parser arbitrary_class, :root, "offer[type=uniq]"
        # You can pass as first argument not only Hash, but any Ruby class capable to set attributes defined in fields
        # define_xml_parser OpenStruct
        # define_xml_parser NiftyActiveRecordModel
        define_xml_parser Hash, :root, :offer do

          # Here is basic validation blocks
          # They MUST return some bool (if block)
          before_parse? do |node|
            !node.search('magick').empty?
          end
          
          # Or just check for must_have key (or path to it)
          before_parse? :jim
          before_parse? [:areas, 'area[type=hobby]']

          # We can define a block to call every time an XmlDsl::ParseError os raised
          # it is raised if null: true is passed to field declaration, or manually via raise XmlDsl::ParseError
          error_handle do |e, node|
            external.notify node
          end
            
          # Field declaration
          field :id, :id, matcher: :to_i
          
          # We can pass getter to call on Nokogiri::Xml::Element (default :text) and matcher (default :to_s)
          field :minutes, :distance, matcher: :to_i
          
          # If null: true (default false) is passed then if field is empty - it will raise XmlDsl::ParseError
          # and then triggers error_handle blocks
          field :magick, :magick, null: true
          
          # We can pass long xpath to find proper node inside our XML
          # like this:
          field :amount, [:prices, :price], matcher: :to_i
          # or even like this:
          field :total_area, [:areas, 'area[type=total]'], matcher: :to_i
          
          # If our logic is more complex we can define it inside block
          field :full_area, null: true do |instance, node|
            if !instance[:area]           
                node.search('areas').reduce(0) { |acc,n| acc + n.text.to_i }
            else
                0
            end
          end
          
          # If something goes wrong - just raise XmlDsl::ParseError manually
          field :fuu do |_, node|
            raise XmlDsl::ParseError, 'FUUU' if node.search(:areas).length > 5
          end
        end
      end
```

Then you can use your newly defined parser as you wish:
```
    parser = Parser.new(nifty_xml, some_logger_eg)
    
    # just iterate with block
    parser.iterate do |instance|
        do_stuff_with_newly_mapped_instance_whatever(instance)
    end
    
    # or you can pass some accumulator for your instances to be put into
    parser.iterate acc: []
    
    # or event call a method on instances without getting them actually
    parser.iterate after_method: :save
```

## Contributing

Feel free to request for some features or fork - implement - pul request.


