# DeathByCaptcha

DeathByCaptcha is a Ruby API for DeathByCaptcha - http://www.deathbycaptcha.com

> DeathByCaptcha is recommended for solving the most popular CAPTCHA types,
> such as image to text, reCAPTCHA v2, reCAPTCHA v3 and FunCaptcha.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'deathbycaptcha', '~> 6.0.0'
```

And then execute:

```bash
$ bundle
````

Or install it yourself as:

```bash
$ gem install deathbycaptcha
````

## Usage

### 1. Create a client

```ruby
client = DeathByCaptcha.new('myusername', 'mypassword')
```

### 2. Solve a CAPTCHA

There are two types of methods available: `decode_*` and `decode_*!`:

- `decode_*` does not raise exceptions.
- `decode_*!` may raise a `DeathByCaptcha::Error` if something goes wrong.

If the solution is not available, an empty CAPTCHA object will be returned.

```ruby
captcha = client.decode_image!(path: 'path/to/my/captcha/file')
captcha.text # CAPTCHA solution
captcha.id   # CAPTCHA numeric id
```

#### Image CAPTCHA

You can specify `url`, `path`, `file`, `raw` or `raw64` when decoding an image.

```ruby
client.decode_image!(url: 'http://bit.ly/1xXZcKo')
client.decode_image!(path: 'path/to/my/captcha/file')
client.decode_image!(file: File.open('path/to/my/captcha/file', 'rb'))
client.decode_image!(raw: File.open('path/to/my/captcha/file', 'rb').read)
client.decode_image!(raw64: Base64.encode64(File.open('path/to/my/captcha/file', 'rb').read))
```

#### reCAPTCHA v2

```ruby
captcha = client.decode_recaptcha_v2!(
  googlekey:   "6Ld2sf4SAAAAAKSgzs0Q13IZhY02Pyo31S2jgOB5",
  pageurl:     "https://patrickhlauke.github.io/recaptcha/",
  # proxy:     "http://user:password@127.0.0.1:3128", # OPTIONAL
  # proxytype: "HTTP",                                # OPTIONAL
)

# The response will be a text (token), which you can access with `text` or `token` methods.

captcha.text
"03AOPBWq_RPO2vLzyk0h8gH0cA2X4v3tpYCPZR6Y4yxKy1s3Eo7CHZRQntxrd..."

captcha.token
"03AOPBWq_RPO2vLzyk0h8gH0cA2X4v3tpYCPZR6Y4yxKy1s3Eo7CHZRQntxrd..."
```

*Parameters:*

- `googlekey`: the Google key for the reCAPTCHA.
- `pageurl`: the URL of the page with the reCAPTCHA challenge.
- `proxy`: optional parameter. Proxy URL and credentials (if any).
- `proxytype`: optional parameter. Proxy connection protocol.

#### reCAPTCHA v3

```ruby
captcha = client.decode_recaptcha_v3!(
  googlekey:   "6LdyC2cUAAAAACGuDKpXeDorzUDWXmdqeg-xy696",
  pageurl:     "https://recaptcha-demo.appspot.com/recaptcha-v3-request-scores.php",
  action:      "examples/v3scores",
  # min_score:   0.3,                                 # OPTIONAL
  # proxy:     "http://user:password@127.0.0.1:3128", # OPTIONAL
  # proxytype: "HTTP",                                # OPTIONAL
)

# The response will be a text (token), which you can access with `text` or `token` methods.

captcha.text
"03AOPBWq_RPO2vLzyk0h8gH0cA2X4v3tpYCPZR6Y4yxKy1s3Eo7CHZRQntxrd..."

captcha.token
"03AOPBWq_RPO2vLzyk0h8gH0cA2X4v3tpYCPZR6Y4yxKy1s3Eo7CHZRQntxrd..."
```

*Parameters:*

- `googlekey`: the Google key for the reCAPTCHA.
- `pageurl`: the URL of the page with the reCAPTCHA challenge.
- `action`: the action name used by the CAPTCHA.
- `min_score`: optional parameter. The minimal score needed for the CAPTCHA resolution. Defaults to `0.3`.
- `proxy`: optional parameter. Proxy URL and credentials (if any).
- `proxytype`: optional parameter. Proxy connection protocol.

> About the `action` parameter: in order to find out what this is, you need to inspect the JavaScript
> code of the website looking for a call to the `grecaptcha.execute` function.
>
> ```javascript
> // Example
> grecaptcha.execute('6Lc2fhwTAAAAAGatXTzFYfvlQMI2T7B6ji8UVV_f', { action: "examples/v3scores" })
> ````

> About the `min_score` parameter: it's strongly recommended to use a minimum score of `0.3` as higher
> scores are rare.

#### FunCaptcha

```ruby
captcha = client.decode_fun_captcha!(
  publickey:   "12345678-0000-1111-2222-123456789012",
  pageurl:     "https://www.site.with.funcaptcha/example",
  # proxy:     "http://user:password@127.0.0.1:3128", # OPTIONAL
  # proxytype: "HTTP",                                # OPTIONAL
)

# The response will be a text (token), which you can access with `text` or `token` methods.

captcha.text
"380633616d817f2b8.2351188603|r=ap-southeast-2|met..."

captcha.token
"380633616d817f2b8.2351188603|r=ap-southeast-2|met..."
```

*Parameters:*

- `publickey`: the public key for the FunCaptcha.
- `pageurl`: the URL of the page with the challenge.
- `proxy`: optional parameter. Proxy URL and credentials (if any).
- `proxytype`: optional parameter. Proxy connection protocol.

### 3. Retrieve a previously solved CAPTCHA

```ruby
captcha = client.captcha('28624378') # with 28624378 being the CAPTCHA id
```

### 4. Report an incorrectly solved CAPTCHA for a refund

```ruby
captcha = client.report!('28624378') # with 28624378 being the CAPTCHA id
```

> **Warning:** *abusing on this method may get you banned.*

### 5. Retrieve your user information and credit balance

```ruby
user = client.user
user.is_banned # true if the user is banned
user.balance   # Credit balance in USD cents
user.rate      # CAPTCHA rate, i.e. charges for one solved CAPTCHA in USD cents
user.id        # Numeric id of your account
```

### 6. Retrieve DeathByCaptcha server status

```ruby
status = client.status
status.todays_accuracy       # Current accuracy of DeathByCaptcha
status.solved_in             # Estimated seconds to solve a CAPTCHA right now
status.is_service_overloaded # true if DeathByCaptcha is overloaded/unresponsive
```

## Notes

### Thread-safety

The API is thread-safe, which means it is perfectly fine to share a client
instance between multiple threads.

### HTTP and Socket clients

The API supports HTTP (recommended) and socket-based connections.

```ruby
# HTTP-based connection.
client = DeathByCaptcha.new('myusername', 'mypassword')
# or
client = DeathByCaptcha.new('myusername', 'mypassword', :http)

# Socket-based connection.
client = DeathByCaptcha.new('myusername', 'mypassword', :socket)
```

When using the socket client, make sure that outgoing TCP traffic to
`api.dbcapi.me` to the ports in range `8123-8130` is not blocked by your
firewall.

> We strongly recommend using the HTTP client (default) because only image
> CAPTCHAs (`decode_image!`) are supported by the socket client in this gem.
> Other CAPTCHA types are supported by the HTTP client only.

### Ruby dependencies

DeathByCaptcha >= 5.0.0 does not require specific dependencies. That saves you
memory and avoid conflicts with other gems.

### Input image format

Any format you use in the `decode_image!` method (`url`, `file`, `path`, `raw` or `raw64`) will
always be converted to a `raw64`, which is a base64-encoded binary string. So, if
you already have this format on your end, there is no need for convertions before
calling the API.

> Our recomendation is to never convert your image format, unless needed. Let
> the gem convert internally. It may save you resources (CPU, memory and IO).

### Versioning

We no longer follow the versioning system of the official clients of
DeathByCaptcha. From `5.0.0` onwards, we will use
[Semantic Versioning](http://semver.org/).

## Contributing

1. Fork it ( https://github.com/infosimples/deathbycaptcha/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. **Run/add tests (RSpec)**
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
7. Yay. Thanks for contributing :)

All contributors:
https://github.com/infosimples/deathbycaptcha/graphs/contributors


# License

MIT License. Copyright (C) 2011-2022 Infosimples. https://infosimples.com/
