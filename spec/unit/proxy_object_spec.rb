require 'spec_helper'

describe ProxyObject do
  let(:other) { [1, 2, 3] }
  let(:proxy) { klass.new(other, 'stuff') }

  let(:klass) do
    Class.new {
      include ProxyObject.new(:other)

      def initialize(other, extra, &block)
        super(other, extra, &block)
      end
    }
  end

  it 'adds reader method for target object' do
    expect(proxy.other).to be(other)
  end

  it 'forwards method calls to target that return other objects' do
    expect(proxy.size).to be(3)
  end

  it 'forwards method calls to target that return equal object' do
    expect(proxy.concat([])).to eql(proxy)
  end

  it 'forwards method calls to target that return new instance of target object' do
    expect((proxy + [4]).other).to eql(klass.new([1, 2, 3, 4], 'stuff').other)
  end

  it 'responds to methods defined on the target object' do
    expect(proxy).to respond_to(:concat)
  end

  it 'does not respond unknown method names' do
    expect(proxy).not_to respond_to(:no_idea_what_you_want)
  end

  it 'forwards multiple levels down to the last target' do
    proxy1 = Class.new { include ProxyObject.new(:arr) }
    proxy2 = Class.new { include ProxyObject.new(:proxy1) }
    proxy3 = Class.new { include ProxyObject.new(:proxy2) }

    object = proxy3.new(proxy2.new(proxy1.new([1, 2, 3])))

    expect(object.size).to be(3)
  end

  context 'when target kind is provided' do
    subject(:proxy) { klass.new(other_class.new) }

    let(:klass) do
      Class.new { include ProxyObject.new(:other, :kind => Enumerable) }
    end

    let(:other_class) do
      Class.new {
        include Enumerable

        def to_set
          Set[1, 2]
        end
      }
    end

    it 'forwards to target and returns proxy for return value that matches the kind' do
      expect(proxy.to_set).to be_instance_of(proxy.class)
    end
  end
end
