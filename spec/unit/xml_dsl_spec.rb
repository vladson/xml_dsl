require 'spec_helper'

describe XmlDsl do
  context 'Within class' do
    let(:clazz) { Class.new }

    it 'added :define_xml_parser to class_methods' do
      expect(clazz).to respond_to(:define_xml_parser)
    end

    it 'has no :define_xml_parser on instance' do
      expect { clazz.new.instance_eval { define_xml_parser Hash, :root }}.to raise_error(NoMethodError)
    end

    it 'but no :iterate on instance before definition' do
      expect { clazz.new.iterate }.to raise_error(NoMethodError)
    end

    context 'on instance after empty parser definition' do
      before(:all) do
        clazz.instance_eval do
          define_xml_parser Hash, :root, :item do
          end
        end
        @parser = clazz.new
      end

      it 'has no :iterate on class after defenition' do
        expect { clazz.iterate }.to raise_error(NoMethodError)
      end
      it 'has :iterate method on instance' do
        expect(@parser).to respond_to(:iterate)
      end
      it 'has xml_parser on class' do
        expect(clazz.instance_variable_get(:@xml_parser)).to be_instance_of(XmlDsl::XmlParser)
      end
      it 'doesn\'t have xml_parser on instance' do
        expect(@parser.instance_variable_get(:@xml_parser)).to be_nil
      end
      it 'have callbacks stack on instance' do
        expect(@parser.instance_variable_get(:@_xml_parse_callbacks)).to be_instance_of(Hash)
      end

      context 'defining different callbacks' do
        let(:xml_parser) { clazz.instance_variable_get(:@xml_parser) }

        it 'defining field callback is put inside :readers' do
          expect { in_definition { field :name, :ext_name } }.to change(xml_parser.callbacks[:readers], :length).by(1)
        end

        it 'defining error_handler is put inside error_handlers' do
          expect { in_definition { error_handle  } }.to change(xml_parser.callbacks[:error_handlers], :length).by(1)
        end

        def in_definition(&block)
          xml_parser.instance_eval &block
        end
      end
    end
  end
end
