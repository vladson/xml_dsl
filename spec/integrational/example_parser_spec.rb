require 'spec_helper'
require 'support/xml'

describe 'Example Xml Mapper Spec' do
  context 'basic parser' do
    before(:each) do
      clazz = Class.new
      clazz.class_eval do
        attr_accessor :xml
        def initialize(xml)
          self.xml = xml
        end

        define_xml_parser Hash, :root, :offer do
          field :id, :id, matcher: :to_i
          field :minutes, :distance, matcher: :to_i
          field :amount, [:prices, :price], matcher: :to_i
          field :currency, :currency
          field :total_area, [:areas, 'area[type=total]'], matcher: :to_i
          field :full_area, null: true do |_, node|
            node.search('areas').reduce(0) { |acc,n| acc + n.text.to_i }
          end
          field :magick, :magick
        end
      end
      @parser = clazz.new some_xml
    end

    it 'responds to iterate' do
      expect(@parser).to respond_to(:iterate)
    end

    it 'puts one Hash obj to acc' do
      expect(@parser.iterate(acc: []).first).to be_instance_of(Hash)
    end

    it 'iterates over nodes and call block twice in outer context' do
      some_obj = double
      expect(some_obj).to receive(:notify).twice
      @parser.iterate do |item|
        some_obj.notify item
      end
    end

    context 'Parser results' do
      let(:result) { @parser.iterate(acc: []).first }

      it 'has amount of kind Numeric' do
        expect(result[:amount]).to be_instance_of(Fixnum)
      end

      it 'has id of kind Fixnum' do
        expect(result[:id]).to be_instance_of(Fixnum)
      end

      it 'has currency of kind String' do
        expect(result[:currency]).to be_instance_of(String)
      end

      it 'has full area of kind Fixnum' do
        expect(result[:full_area]).to be_instance_of(Fixnum)
      end

      it 'has total area equal 37' do
        expect(result[:total_area]).to eql(37)
      end

      it 'has empty magick' do
        expect(result[:magick]).to be_empty
      end
    end
  end

  context 'parser for different errors' do
    before(:each) do
      clazz = Class.new
      @external_obj = double
      clazz.class_eval do
        attr_accessor :xml, :external
        def initialize(xml, external)
          self.xml = xml
          self.external = external
        end

        define_xml_parser Hash, :root, :offer do

          error_handle do |e, node|
            external.notify node
          end

          field :id, :id, matcher: :to_i
          field :minutes, :distance, matcher: :to_i
          field :magick, :magick, null: true
        end
      end
      @parser = clazz.new some_xml, @external_obj
    end

    it 'calls error_handler on parse error if null: true' do
      expect(@external_obj).to receive(:notify).with(kind_of(Nokogiri::XML::Element)).once
      @parser.iterate
    end
  end

  context 'Parser with before_parse validation (good)' do
    before(:each) do
      clazz = Class.new
      @external_obj = double
      clazz.class_eval do
        attr_accessor :xml, :external
        def initialize(xml, external)
          self.xml = xml
          self.external = external
        end

        define_xml_parser Hash, :root, :offer do

          before_parse? do |node|
            !node.search('magick').empty?
          end

          before_parse? :jim
          before_parse? [:areas, 'area[type=hobby]']

          field :id, :id, matcher: :to_i
          field :minutes, :distance, matcher: :to_i
        end
      end
      @parser = clazz.new some_xml, @external_obj
    end

    it 'returns only one object' do
      expect(@parser.iterate(acc:[]).length).to eql(1)
    end
  end

  context 'Output parser and arbitrary class' do
    before(:each) do
      arbitrary_class = Class.new
      arbitrary_class.class_eval do
        attr_accessor :id, :minutes, :magick

        def very_important_method
          puts self.id
        end
      end
      clazz = Class.new
      @external_obj = double
      clazz.class_eval do
        attr_accessor :xml, :external
        def initialize(xml, external)
          self.xml = xml
          self.external = external
        end

        define_xml_parser arbitrary_class, :root, "offer[type=uniq]" do
          field :id, :id, matcher: :to_i
          field :minutes, :distance, matcher: :to_i
        end
      end
      @parser = clazz.new some_xml, @external_obj
    end

    it 'calls on iterate' do
      d = double
      expect(d).to receive(:fire).once
      @parser.iterate do |i|
        d.fire i
      end
    end

    it 'appends instances to a list provided' do
      list = []
      @parser.iterate acc: list
      expect(list.length).to eql(1)
    end

    it 'instances are having attributes set' do
      list = []
      @parser.iterate acc: list
      expect(list.last.id).to eql(703102)
    end

    it 'calls after_method if provided' do
      expect_any_instance_of(@parser.instance_variable_get(:@_xml_target_class)).to receive(:very_important_method).at_least(:once)
      @parser.iterate after_method: :very_important_method
    end
  end
end
