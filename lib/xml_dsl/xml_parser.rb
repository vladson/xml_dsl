require 'xml_dsl/block_method'
require 'xml_dsl/extensions'
require 'xml_dsl/errors'

module XmlDsl
  class XmlParser
    class << self
      def create(owner, *args, &block)
        new(owner, *args, &block)
      end
    end

    attr_reader :owner, :target_class, :state_lock, :callbacks

    def initialize(owner, target_class, *args, &block)
      raise XmlDsl::Error, 'No block given for parser' unless block_given?
      @target_class = target_class
      @root_path = args
      @state_lock = Mutex.new
      self.owner = owner
      @callbacks = Hash.new { |h,k| h[k] = [] }
      self.instance_eval &block
    end

    def owner=(klazz)
      @owner = klazz
      @owner.send :include, XmlDsl::Extensions
      @owner.instance_variable_set :@xml_parser, self
    end

    def field(*args, &block)
      callbacks[:readers] << XmlDsl::BlockMethod.new(:field, *args, &block)
    end

    def error_handle(*args, &block)
      callbacks[:error_handlers] << XmlDsl::BlockMethod.new(:error_handle, *args, &block)
    end

    def setup_parser_instance(instance)
      state_lock.synchronize do
        instance.instance_variable_set :@_xml_root_path, root_path
        instance.instance_variable_set :@_xml_parse_callbacks, callbacks.dup
        instance.instance_variable_set :@_xml_target_class, target_class
      end
    end

    def root_path
      @root_path.join('/').prepend('//')
    end
  end
end
