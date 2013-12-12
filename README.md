# Charlatan

Turn any object into a proxy delegating to another object. Like that:

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

Planned features:

* optional support for equality methods
* optional support for kind_of? and === 
* transparent vs restricted delegation (as in, allow all calls or explicitly specify what should be delegated)

## Why?

The idea is that a delegator object wrapping another object delegates method calls but it preserves the original type for return values which match the wrapped object's kind. This means if you decorate an array object and you call concat on the decorator you will get an instance of the decorator back rather than an array.

Other cool aspects of this library:

* You get a constructor for free which plays well with your own, just remember to call super if you override it
* You get attr reader for the wrapped object
* Your object correctly handles method missing and respond_to? - something that is really easy to break accidentely in an ad-hoc custom implementation
* You don't need to inherit from any superclass, just mix it in and call it a day

## Installation

Add this line to your application's Gemfile:

    gem 'charlatan'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install charlatan

## Credits

* [Dan Kubb](https://github.com/dkubb) for the original idea behind a proxy
wrapping another object.
* [Don Morrison](https://github.com/elskwid) for the awesome name that happened
to be available on github and rubygems *at the same time*

## Similar libraries

* [casting](https://github.com/saturnflyer/casting)
* simple_delegator in ruby stdlib

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
