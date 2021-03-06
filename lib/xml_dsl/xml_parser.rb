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

    # Field for parse definition
    # receives args: target, source = nil, getter: :text, matcher: :to_s, null: false
    # or block with |instance, node|
    def field(*args, &block)
      callbacks[:readers] << XmlDsl::BlockMethod.new(:field, *args, &block)
    end

    # Error handler for automatic or manually raised XmlDsl::ParseError exceptions
    # receives block with two args error and node, that caused the error to occur
    # block with |exception, node|
    def error_handle(*args, &block)
      callbacks[:error_handlers] << XmlDsl::BlockMethod.new(:error_handle, *args, &block)
    end

    # Validation like block
    # receives key: symbol, string, or array of similar
    # returns bool if true - normal, false - skip this node
    def before_parse?(*args, &block)
      callbacks[:before_parsers] << XmlDsl::BlockMethod.new(:before_parse?, *args, &block)
    end

    def setup_parser_instance(instance)
      state_lock.synchronize do
        instance.instance_variable_set :@_xml_root_path, root_path
        instance.instance_variable_set :@_xml_parse_callbacks, callbacks.dup
        instance.instance_variable_set :@_xml_target_class, target_class
      end
    end

    def root_path
      rp = @root_path.join('/')
      rp.prepend('//') if @root_path.map {|part| part.is_a? Symbol}.reduce(true, :&)
      rp
    end
  end
end
