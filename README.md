Developed by [Infosimples](https://infosimples.com), a brazilian company that excels in [data extraction solutions](https://infosimples.com/en/data-engineering) and [Ruby on Rails development](https://infosimples.com/en/software-development).


# Deathbycaptcha

DeathByCaptcha is a Ruby API for DeathByCaptcha - http://www.deathbycaptcha.com.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'deathbycaptcha'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install deathbycaptcha


## Usage

1. Create a client

  ```ruby
  # Create a client (:socket or :http clients are available)
  #
  client = DeathByCaptcha.new('myusername', 'mypassword', :socket)
  ```

2. Solve a captcha

  ```ruby
  # Decode the text from an image
  #
  response = client.decode(url: 'https://raw.githubusercontent.com/infosimples/deathbycaptcha/master/captchas/1.png')
  response['text'] # the solution
  response['captcha'] # the ID of the captcha solved by DeathByCaptcha

  # You can also specify a file path
  client.decode(path: 'path/to/my/captcha/file')

  # or a file
  client.decode(file: File.open('path/to/my/captcha/file', 'rb'))

  # or a raw content
  client.decode(raw: File.open('path/to/my/captcha/file', 'rb').read)
  ```

3. Retrieve a previously solved captcha

  ```ruby
  client.captcha('130920620') # with 130920620 as the captcha id
  ```

4. Report incorrectly solved captcha for refund

  ```ruby
  client.report!('130920620') # with 130920620 as the captcha id
  ```

  ***Warning:*** *do not abuse of this method, you may get banned*

5. Retrieve your account's current credit balance (in US cents)

  ```ruby
  client.balance()
  ```


## Notes

### Thread-safety

The API is thread-safe, which means it is perfectly fine to share a client instance between multiple threads.

### HTTP and Socket clients

The API supports HTTP and socket-based connections, with the latter being recommended for having faster responses and overall better performance. The two clients have the same methods/interface.

When using the socket client, make sure that outgoing TCP traffic to **api.dbcapi.me** to the ports in range **8123-8130** is not blocked by your firewall.


# Maintainers

* [Débora Setton Fernandes](http://github.com/deborasetton)
* [Rafael Barbolo](http://github.com/barbolo)
* [Rafael Ivan Garcia](http://github.com/rafaelivan)


## Contributing

1. Fork it ( https://github.com/infosimples/deathbycaptcha/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. **Test/add tests (RSpec)**
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
7. Yay. Thanks for contributing :)

All contributors: https://github.com/infosimples/deathbycaptcha/graphs/contributors


# License

MIT License. Copyright (C) 2011-2015 Infosimples. https://infosimples.com/
