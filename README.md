# Charlatan

Turn any object into a proxy wrapping another object. Like that:

``` ruby
require 'charlatan'

class ArrayProxy
  include Charlatan.new(:array)
end

array_proxy = ArrayProxy.new([])

array_proxy << 'Hello'
array_proxy << 'World'

array_proxy.size # => 2
array_proxy.join(' ') # => 'Hello World'

# always wraps responses with the proxy class
other = array_proxy + ['Oh Hai']
other.class # => ArrayProxy
```

## Installation

Add this line to your application's Gemfile:

    gem 'charlatan'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install charlatan

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
