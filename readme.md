# reevoomark-ruby-api

##Description

The reevoomark-ruby-api is a Ruby gem for ReevooMark and Reevoo Essentials customers who want to quickly and easily integrate Reevoo content in to their sites server-side.

##Other Languages
Tag libraries are also available for [PHP](https://github.com/reevoo/reevoomark-php-api) [.NET](https://github.com/reevoo/reevoomark-dotnet-api) and [Java](https://github.com/reevoo/reevoomark-java-api).

##Features

* Server-side inclusion of Reevoo content.
* Included CSS for display of Reevoo content.
* Server-side caching of content that respects the cache control rules set by Reevoo.

##Support
For ReevooMark and Reevoo Essentials customers, support can be obtained by emailing <operations@reevoo.com>.

There is also a [bug tracker](https://github.com/reevoo/reevoomark-ruby-api/issues) available.

##Installation

If you are using Bundler, simply add reevoomark-ruby-api to your Gemfile.

``` ruby
gem 'reevoomark-ruby-api'
```

Or if you are using rubygems, install the gem directly.

```
gem install reevoomark-ruby-api
```

##Implementation

In your view, include the relevant CSS and your customer-specific Reevoo JavaScript:

``` html
<link rel="stylesheet" href="http://mark.reevoo.com/stylesheets/reevoomark/embedded_reviews.css" type="text/css" />
```
``` html
<script src="http://mark.reevoo.com/reevoomark/<TRKREF>.js" type="text/javascript"></script>
```

In your server-side code, require the gem:

``` ruby
require 'reevoomark'
```

Initialise the client using your customer TRKREF and the product sku. Make sure you replace `<reevoo_cache>` with the path of a directory that can be used to cache review content:

``` ruby
@reevoo_mark = ReevooMark.new("<reevoo_cache>", "http://mark.reevoo.com/reevoomark/embeddable_reviews.html", "<TRKREF>", "<SKU>")
```

It is also possible to specify locale and the number of reviews you'd like in the URI:

```ruby
@reevoo_mark = ReevooMark.new("<reevoo_cache>", "http://mark.reevoo.com/reevoomark/fr-FR/10/embeddable_reviews.html", "<TRKREF>", "<SKU>")
```

Render your embedded review content inside your view.
```ruby
<%= @reevoo_mark.render %>
```

By default Reevoo will display helpful content to the user when there are no reviews available. If you'd like to handle this yourself, you can check the review count before rendering:

``` ruby
<% if @reevoo_mark.review_count.to_i > 0 %>
  <%= @reevoo_mark.render %>
<% else %>
  <h1>No reviews here.</h1>
<% end %>
```

## Tracking

If you display the reviews in a tabbed display, or otherwise require visitors to your site to click an element before seeing the embedded reviews, add the following onclick attribute to track the clickthroughs:

``` html
  onclick="ReevooMark.track_click_through(‘<SKU>’)”
```

## Overall rating

The overall rating section at the top of inline reviews contains an overall score, a summary and the score breakdowns. Your container must be at least 650px for the score breakdowns to be shown. The absolute minimum width for inline reviews is 350px.

##License

This software is released under the MIT license.  Only certified ReevooMark partners
are licensed to display Reevoo content on their sites.  Contact <sales@reevoo.com> for
more information.

(The MIT License)

Copyright (c) 2008 - 2010:

* [Reevoo](http://www.reevoo.com)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.