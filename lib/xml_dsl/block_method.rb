module XmlDsl
  class BlockMethod
    attr_reader :method, :args, :block
    def initialize(method, *args, &block)
      @method = method
      @args = args
      @block = block if block_given?
    end

    def call(instance, node, parser)
      if block
        self.send method, *[instance, node, parser] + args, &block
      else
        self.send method, *[instance, node, parser] + args
      end
    end

    def field(instance, node, parser, target, source = nil, getter: :text, matcher: :to_s, null: false, &block)
      raise ArgumentError, 'Wrong target' unless target.is_a? Symbol
      if block_given?
        instance[target] = parser.instance_exec instance, node, &block
      else
        raise ArgumentError, 'No source specified' if source.nil?
        source = case [source.class]
                   when [Symbol]
                     source.to_s
                   when [Array]
                     source.join('/')
                   else
                     source.to_s
                 end
        instance[target] = node.search(source).send(getter).send(matcher)
      end
      if null
        raise XmlDsl::ParseError, "#{target} is empty. Node: #{node}" if instance[target].nil? || instance[target] == ""
      end
    end

    def error_handle(exception, node, parser, &block)
      parser.instance_exec exception, node, &block
    end
  end
end
