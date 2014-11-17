module XmlDsl
  module Extensions
    def self.included(base)
      base.send :include, InstanceMethods
      base.send :extend, ClassMethods
      base.class_eval do
        attr_reader :_xml_parse_callbacks, :_xml_root_path, :_xml_target_class

        alias_method :original_initialize, :initialize
        def initialize(*args, &block)
          self.class.instance_variable_get(:@xml_parser).setup_parser_instance(self)
          original_initialize(*args, &block)
        end
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def iterate(xml_obj = nil, acc: nil, &block)
        xml_obj ||= xml
        raise ArgumentError, "If there is no @xml in parser, pass it to iterate" if xml_obj.nil?
        xml_obj.search(_xml_root_path).each do |node|
          begin
            instance = _xml_target_class.new
            _xml_parse_callbacks[:readers].each do |bm|
              bm.call instance, node, self
            end
            yield instance if block_given?
            acc << instance if acc
          rescue XmlDsl::ParseError => e
            _xml_parse_callbacks[:error_handlers].each do |bm|
              bm.call e, node, self
            end
          end
        end
        acc
      end
    end
  end
end
