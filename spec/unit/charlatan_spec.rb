require 'spec_helper'

describe Charlatan do
  let(:other) { [1, 2, 3] }
  let(:charlatan) { klass.new(other, 'stuff') }

  let(:klass) do
    Class.new {
      include Charlatan.new(:other)

      def inspect
        '#<TestClass>'
      end

      def initialize(other, extra, &block)
        super(other, extra, &block)
      end
    }
  end

  it 'adds reader method for target object' do
    expect(charlatan.other).to be(other)
  end

  it 'forwards method calls to target that returns other objects' do
    expect(charlatan.size).to be(3)
  end

  it 'forwards method calls to target that returns equal object and returns self' do
    expect(charlatan.concat([])).to equal(charlatan)
  end

  it 'forwards method calls to target that returns a new instance of itself' do
    expect((charlatan + [4]).other).to eql(klass.new([1, 2, 3, 4], 'stuff').other)
  end

  it 'forwards method calls with a block' do
    expect(charlatan.map(&:to_s).other).to eql(%w(1 2 3))
  end

  it 'does not mutate original args from the constructor' do
    2.times do
      expect((charlatan + [4]).other).to eql(klass.new([1, 2, 3, 4], 'stuff').other)
    end
  end

  it 'responds to methods defined on the target object' do
    expect(charlatan).to respond_to(:concat)
  end

  it 'does not respond to private methods defined on the target object' do
    expect(charlatan).not_to respond_to(:Integer)
  end

  it 'does not respond to unknown method names' do
    expect(charlatan).not_to respond_to(:no_idea_what_you_want)
  end

  it 'raises no method error when method is not defined' do
    expect { charlatan.not_here}.to raise_error(
      NoMethodError,
      /undefined method `not_here' for #<TestClass>/
    )
  end

  it 'forwards multiple levels down to the last target' do
    charlatan1 = Class.new { include Charlatan.new(:arr) }
    charlatan2 = Class.new { include Charlatan.new(:charlatan1) }
    charlatan3 = Class.new { include Charlatan.new(:charlatan2) }

    object = charlatan3.new(charlatan2.new(charlatan1.new([1, 2, 3])))

    expect(object.size).to be(3)
  end

  context 'when target kind is provided' do
    subject(:charlatan) { klass.new(other_class.new) }

    let(:klass) do
      Class.new { include Charlatan.new(:other, :kind => Enumerable) }
    end

    let(:other_class) do
      Class.new {
        include Enumerable

        def to_set
          Set[1, 2]
        end
      }
    end

    it 'forwards to target and returns charlatan for return value that matches the kind' do
      expect(charlatan.to_set).to be_instance_of(charlatan.class)
    end
  end
end
