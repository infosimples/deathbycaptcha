DeathByCaptcha
==============

DeathByCaptcha is a Ruby API for acessing the http://www.deathbycaptcha.com services.

It supports HTTP and socket-based connections, with the latter being recommended for having faster responses and overall better performance.

When using socket connections, make sure that outgoing TCP traffic to <b>api.deathbycaptcha.com</b> to the ports range in <b>8123-8130</b> is not blocked by your firewall.

Thread-safety note
------------------

The API is thread-safe, which means it is perfectly fine to share a client instance between multiple threads.

Latest version
--------------

The latest version of this API is 4.1.0.

Installation
------------

You can install the latest DeathByCaptcha gem with:

	gem install deathbycaptcha

You can add it to your Gemfile:

	gem 'deathbycaptcha'

Examples
--------

### Create a client

#### HTTP client

	require 'deathbycaptcha'

	client = DeathByCaptcha.http_client('myusername', 'mypassword')
	
#### Socket client

	require 'deathbycaptcha'

	client = DeathByCaptcha.socket_client('myusername', 'mypassword')
	
#### Verbose mode (for debugging purposes)

	client.config.is_verbose = true
	
#### Decoding captcha

##### From URL
	
	response = client.decode 'http://www.phpcaptcha.org/securimage/securimage_show.php'
	
	puts "captcha id: #{response['captcha']}, solution: #{response['text']}, is_correct: #{response['is_correct']}}"

##### From file path

	response = client.decode 'path/to/my/captcha/file'

	puts "captcha id: #{response['captcha']}, solution: #{response['text']}, is_correct: #{response['is_correct']}}"
	
##### From a file

	file = File.open('path/to/my/captcha/file', 'r')

	response = client.decode file

	puts "captcha id: #{response['captcha']}, solution: #{response['text']}, is_correct: #{response['is_correct']}}"
	
##### From raw content

	raw_content = File.open('path/to/my/captcha/file', 'r').read

	response = client.decode(raw_content, :is_raw_content => true)

	puts "captcha id: #{response['captcha']}, solution: #{response['text']}, is_correct: #{response['is_correct']}}"

#### Get the solution of a captcha
	
	puts client.get_captcha('130920620')['text'] # where 130920620 is the captcha id
	
#### Get user account information

	puts client.get_user

Maintainers
-----------

* Rafael Barbolo Lopes (http://github.com/barbolo)
* Rafael Ivan Garcia (http://github.com/rafaelivan)

License
-------

MIT License. Copyright (C) 2011 by Infosimples. http://www.infosimples.com.br