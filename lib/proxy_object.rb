require "proxy_object/version"

# ProxyObject turns your object into a proxy which will forward all method missing
# calls to object it's wrapping
#
# @example
#
#   class UserPresenter
#     include ProxyObject.new(:user)
#   end
#
#   user = OpenStruct.new(:name => "Jane")
#   presenter = user.name # => "Jane"
#   presenter.user == user # => true
#
class ProxyObject < Module
  attr_reader :name

  def initialize(name)
    attr_reader name

    define_method(:initialize) do |*args, &block|
      instance_variable_set("@#{name}", args.first)
      @__proxy_args = args[1..args.size]
    end

    define_method(:method_missing) do |method_name, *args, &block|
      target = send(name)

      if target.respond_to?(method_name)
        response = target.public_send(method_name, *args, &block)

        if response.equal?(target)
          self
        elsif response.kind_of?(target.class)
          self.class.new(*@__proxy_args.unshift(response))
        else
          response
        end
      else
        super(method_name, *args, &block)
      end
    end

    define_method(:respond_to_missing?) do |method_name, include_all|
      send(name).respond_to?(method_name, include_all)
    end
  end
end
