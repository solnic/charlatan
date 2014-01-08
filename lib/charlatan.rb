require "charlatan/version"

# Charlatan turns your object into a proxy which will forward all method missing
# calls to object it's wrapping
#
# @example
#
#   class UserPresenter
#     include Charlatan.new(:user)
#   end
#
#   user      = OpenStruct.new(:name => "Jane")
#   presenter = UserPresenter.new(user)
#
#   user.name # => "Jane"
#   presenter.user == user # => true
#
class Charlatan < Module
  attr_reader :name

  def initialize(name, options = {})
    attr_reader name
    ivar = "@#{name}"

    attr_reader :__proxy_kind__, :__proxy_args__

    define_method(:initialize) do |proxy_target, *args, &block|
      instance_variable_set(ivar, proxy_target)

      @__proxy_kind__ = options.fetch(:kind) { proxy_target.class }
      @__proxy_args__ = args
    end

    define_method(:__proxy_target__) do
      instance_variable_get(ivar)
    end

    include Methods
  end

  module Methods
    def respond_to_missing?(method_name, include_private)
      __proxy_target__.respond_to?(method_name, include_private)
    end

    def method_missing(method_name, *args, &block)
      if __proxy_target__.respond_to?(method_name)
        response = __proxy_target__.public_send(method_name, *args, &block)

        if response.equal?(__proxy_target__)
          self
        elsif response.kind_of?(__proxy_kind__)
          self.class.new(*[response]+__proxy_args__)
        else
          response
        end
      else
        super(method_name, *args, &block)
      end
    end
  end
end
