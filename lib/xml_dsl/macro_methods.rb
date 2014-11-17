require 'xml_dsl/xml_parser'

module XmlDsl
  module MacroMethods
    def define_xml_parser(*args, &block)
      XmlDsl::XmlParser.create(self, *args, &block)
    end
  end
end
