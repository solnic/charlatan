require 'spec_helper'

describe ProxyObject do
  let(:parent_class) do
    Class.new {
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def test_new_instance(name)
        self.class.new(name)
      end

      def test_same_instance
        self
      end

      def test_return_value
        'return value'
      end
    }
  end

  let(:proxy_class)  do
    Class.new(parent_class) {
      include ProxyObject

      def initialize(parent)
        @parent = parent
      end
    }
  end

  describe 'forwarding parent methods' do
    let(:parent) { parent_class.new(:test) }
    let(:object) { proxy_class.new(parent) }

    context 'when method returns new instance of parent class' do
      subject { object.test_new_instance(:other) }

      it { should be_instance_of(proxy_class) }

      its(:name) { should be(:other) }
    end

    context 'when method returns an instance equal to the decorated instance' do
      subject { object.test_same_instance }

      it { should be(object) }
    end

    context 'when method returns an arbitrary object' do
      subject { object.test_return_value }

      it { should eql('return value') }
    end
  end
end
