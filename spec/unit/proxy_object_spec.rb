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
end
