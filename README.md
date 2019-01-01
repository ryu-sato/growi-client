[![wercker status](https://app.wercker.com/status/837aadfe3b9e25cf5aacd36ae2bdc6a4/s/master "wercker status")](https://app.wercker.com/project/byKey/837aadfe3b9e25cf5aacd36ae2bdc6a4)

# growi-client -- client of growi with use API

A client of growi with use API.

## Compatibility

growi-client is passed the test of these Growi versions.

|growi-client|Growi|
| --- | --- |
|1.0.0|3.3.3|
|0.9.0|3.1.12|

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'growi-client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install growi-client

## Usage

Export these environments.

```
export GROWI_ACCESS_TOKEN=0123456789abcdef0123456789abcdef0123456789ab
export GROWI_URL=http://localhost:3000/
```

```ruby
require 'growi-client'

growi_client = GrowiClient.new(growi_url: ENV['GROWI_URL'], access_token: ENV['GROWI_ACCESS_TOKEN'])

p growi_client.page_exist?( path_exp: '/' )
p growi_client.attachment_exist?( path_exp: '/', attachment_name: 'LICENSE.txt' )
```

## Examples

```ruby
# get page's ID
p growi_client.page_id( path_exp: '/' )
```

```ruby
# Check existence of page by page path (you can use regular expression)
growi_client.page_exist?( path_exp: '/' )
```

```ruby
# Check existence of attachment by file name of attachment
growi_client.attachment_exist?( path_exp: '/', attachment_name: 'LICENSE.txt' )
```

```ruby
# get attachment's ID
p growi_client.attachment_id( path_exp: '/', attachment_name: 'LICENSE.txt' )
```

```ruby
# get attachment (return data is object of GrowiAttachment)
p growi_client.attachment( path_exp: '/', attachment_name: 'LICENSE.txt' )
```

```ruby
# pages list
req = GApiRequestPagesList.new path_exp: '/'
p growi_client.request(req)
```

```ruby
# pages get - path_exp
req = GApiRequestPagesList.new path_exp: '/'
p growi_client.request(req)
```

```ruby
# pages get - page_id
req = GApiRequestPagesGet.new page_id: growi_client.page_id(path_exp: '/')
p growi_client.request(req)
```

```ruby
# pages get - revision_id
reqtmp = GApiRequestPagesList.new path_exp: '/'
ret = growi_client.request(reqtmp)
path = ret.data[0].path
revision_id = ret.data[0].revision._id
req = GApiRequestPagesGet.new path: path, revision_id: revision_id
p growi_client.request(req)
```

```ruby
# pages create
test_page_path = '/tmp/growi-client test page'
body = "# growi-client\n"
req = GApiRequestPagesCreate.new path: test_page_path,
        body: body
p growi_client.request(req)
```

```ruby
# pages update
test_page_path = '/tmp/growi-client test page'
test_cases = [nil, GrowiPage::GRANT_PUBLIC, GrowiPage::GRANT_RESTRICTED,
              GrowiPage::GRANT_SPECIFIED, GrowiPage::GRANT_OWNER]
page_id = growi_client.page_id(path_exp: test_page_path)

body = "# growi-client\n"
test_cases.each do |grant|
  body = body + grant.to_s
  req = GApiRequestPagesUpdate.new page_id: page_id,
          body: body, grant: grant
  p growi_client.request(req)
end
```

```ruby
# pages seen
page_id = growi_client.page_id(path_exp: '/')
req = GApiRequestPagesSeen.new page_id: page_id
p growi_client.request(req)
```

```ruby
# likes add
test_page_path = '/tmp/growi-client test page'
page_id = growi_client.page_id(path_exp: test_page_path)
req = GApiRequestLikesAdd.new page_id: page_id
p growi_client.request(req)
```

```ruby
# likes remove
test_page_path = '/tmp/growi-client test page'
page_id = growi_client.page_id(path_exp: test_page_path)
req = GApiRequestLikesRemove.new page_id: page_id
p growi_client.request(req)
```

```ruby
# update post
test_page_path = '/tmp/growi-client test page'
req = GApiRequestPagesUpdatePost.new path: test_page_path
p growi_client.request(req)
```


```ruby
# attachments list
test_page_path = '/tmp/growi-client test page'
page_id = growi_client.page_id(path_exp: test_page_path)
req = GApiRequestAttachmentsList.new page_id: page_id
p growi_client.request(req)
```

```ruby
# attachments add
test_page_path = '/tmp/growi-client test page'
page_id = growi_client.page_id(path_exp: test_page_path)
req = GApiRequestAttachmentsAdd.new page_id: page_id,
                                     file: File.new('LICENSE.txt')
p growi_client.request(req)
```

```ruby
# attachments remove
test_page_path = '/tmp/growi-client test page'
page_id = growi_client.page_id(path_exp: test_page_path)
reqtmp = GApiRequestAttachmentsList.new page_id: page_id
ret = growi_client.request(reqtmp)
attachment_id = ret.data[0]._id
req = GApiRequestAttachmentsRemove.new attachment_id: attachment_id
p growi_client.request(req)
```

### Basic Authentication

```ruby
require 'growi-client'

# Create growiclient instance with username and password that is used by basic authentication
growi_client = GrowiClient.new(growi_url: ENV['GROWI_URL'], access_token: ENV['GROWI_ACCESS_TOKEN'],
                               rest_client_param: { user: 'who', password: 'bar'})

# Check existence of page
p growi_client.page_exist?( path_exp: '/' ) ? '/ exist' : '/ not exist'

# Create page whose path is '/tmp'
req = GApiRequestPagesCreate.new path: '/tmp', body: 'tmp'
p growi_client.request(req)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ryu-sato/growi-client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Growi::Client project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ryu-satgrowiwi-client/blob/master/CODE_OF_CONDUCT.md).

## TODO

- [ ] pagenation に対応する
