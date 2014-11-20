module XmlDsl
  class BlockMethod
    attr_reader :method, :args, :block
    def initialize(method, *args, &block)
      @method = method
      @args = args
      @block = block if block_given?
    end

    def call(a, b = nil, c = nil)
      if block
        self.send method, *[a, b, c].compact + args, &block
      else
        self.send method, *[a, b, c].compact + args
      end
    end

    def field(instance, node, parser, target, source = nil, getter: :text, matcher: :to_s, null: false, &block)
      raise ArgumentError, 'Wrong target' unless target.is_a? Symbol
      if block_given?
        instance[target] = parser.instance_exec instance, node, &block
      else
        raise ArgumentError, 'No source specified' if source.nil?
        instance[target] = node.search(convert_source(source)).send(getter).send(matcher)
      end
      if null
        raise XmlDsl::ParseError, "#{target} is empty. Node: #{node}" if instance[target].nil? || instance[target] == ""
      end
    end

    def error_handle(exception, node, parser, &block)
      parser.instance_exec exception, node, &block
    end

    def before_parse?(node, parser, key = nil, &block)
      if block_given?
        parser.instance_exec node, &block
      else
        raise ArgumentError, 'Key to check is nil' if key.nil?
        !node.search(convert_source(key)).empty?
      end
    end

    private
    def convert_source(source)
      case [source.class]
        when [Symbol]
          source.to_s
        when [Array]
          source.join('/')
        else
          source.to_s
      end
    end
  end
end
