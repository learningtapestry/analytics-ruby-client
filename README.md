Analytics Ruby client library
=============================

# Overview

This library aides in obtaining data from the Learning Tapestry APIs.  You must
have an organization API key and secret in order to use the library.  For
organization setup or any questions, please contact
support@learningtapestry.com.

# License

The Learning Tapestry Library for Ruby is licensed under The MIT License (MIT).
Please see LICENSE for more details.

# Requirements

Ruby 2.0.0 or later

# Usage

To use within an application

* Install the gem

```ruby
gem install analytics
```

* And remember to require it before using it:

```ruby
require 'analytics'
```

# Initialization

Initialize a new agent class:

```ruby
lt_agent = Analytics::Agent.new
```

If present, the Learning Tapestry agent will use analytics.yml for configuration
or directly initialize it with parameters. Direct parameters have precedence
over file configuration.

```ruby
lt_agent = Analytics::Agent.new(org_api_key: '[API_KEY]',
                                org_secret_key: '[SECRET]'
                                entity: 'page_visits',
                                filters: filters,
                                usernames: usernames)
```

# Queries

## Users

```ruby
lt_agent = Analytics::Agent.new
lt_agent.org_api_key = '[API_KEY]'
lt_agent.org_secret_key = '[SECRET]'
users = lt_agent.users
```

## Site or Page Visits

To issue a query, follow the syntax below.

```ruby
lt_agent = Analytics::Agent.new
lt_agent.org_api_key = '[API_KEY]'
lt_agent.org_secret_key = '[SECRET]'
lt_agent.entity = 'site_visits' # or page_visits
lt_agent.usernames = [ 'joesmith@foo.com' ] # Array of usernames

response = lt_agent.obtain
puts response[:status]  # = HTTP status code, 200
puts response[:results] # = data from query
puts response[:entity] # = 'site_visits'
puts response[:date_range] # = date begin-end range of query, default 24 hours
```
Optionally:

```ruby
lt_agent.type = 'detail' # will obtain a detail listing by date
```

# Filters

Optionally, the following filters may be used:

```ruby
lt_agent.add_filter :date_begin, '2014-10-01'
lt_agent.add_filter :date_end, '2014-10-31'
lt_agent.add_filter :site_domains, 'google.com'
lt_agent.add_filter :page_urls, 'http://mail.google.com'
```

# Result Examples

Site Vists - Summary:

```ruby
{:results=>
  [{:username=>"joesmith@foo.com",
    :site_visits=>
     [{:site_name=>"Ars Technica",
       :site_domain=>"arstechnica.com",
       :time_active=>"00:02:03"},
      {:site_name=>"Stack Overflow",
       :site_domain=>"stackoverflow.com",
       :time_active=>"23:36:24"},
      {:site_name=>"TechCrunch",
       :site_domain=>"techcrunch.com",
       :time_active=>"00:05:57"}]}],
 :entity=>"site_visits",
 :date_range=>
  {:date_begin=>"2014-10-01T00:00:00",
   :date_end=>"2014-10-31T23:59:59"},
 :status=>200}
```

Site Visits - Detail:

```ruby
{:results=>
  [{:username=>"joesmith@foo.com",
    :site_visits=>
     [{:site_name=>"Ars Technica",
       :site_domain=>"arstechnica.com",
       :time_active=>"00:00:58",
       :date_visited=>"2014-10-12"},
      {:site_name=>"Ars Technica",
       :site_domain=>"arstechnica.com",
       :time_active=>"00:01:05",
       :date_visited=>"2014-10-13"},
      {:site_name=>"Gizmodo",
       :site_domain=>"gizmodo.com",
       :time_active=>"00:00:50",
       :date_visited=>"2014-10-14"},
      {:site_name=>"Slashdot",
       :site_domain=>"slashdot.org",
       :time_active=>"00:00:05",
       :date_visited=>"2014-10-12"}}],
 :entity=>"site_visits",
 :date_range=>
  {:date_begin=>"2014-10-01T00:00:00",
   :date_end=>"2014-10-31T23:59:59"},
 :status=>200}
```

Page Visits - Summary:

```ruby
{:results=>
  [{:username=>"bob@foo.com",
    :page_visits=>
     [{:site_name=>"Ars Technica",
       :site_domain=>"arstechnica.com",
       :page_name=>"Ars Technica",
       :page_url=>"http://arstechnica.com/",
       :time_active=>"00:00:08"},
      {:site_name=>"Ars Technica",
       :site_domain=>"arstechnica.com",
       :page_name=>
        "Former NSA director had thousands personally invested | Ars Technica",
       :page_url=>
        "http://arstechnica.com/tech-policy/2014/10/former-nsa-director-had",
       :time_active=>"00:00:30"},
      {:site_name=>"Ars Technica",
       :site_domain=>"arstechnica.com",
       :page_name=>"Law & Disorder | Ars Technica",
       :page_url=>"http://arstechnica.com/tech-policy/",
       :time_active=>"00:00:07"},
      {:site_name=>"Ars Technica",
       :site_domain=>"arstechnica.com",
       :page_name=>"Ministry of Innovation | Ars Technica",
       :page_url=>"http://arstechnica.com/business/",
       :time_active=>"00:00:19"}]}],
 :entity=>"page_visits",
 :date_range=>
  {:date_begin=>"2014-10-11T00:00:00.000+00:00",
   :date_end=>"2014-10-17T23:59:59"},
 :status=>200}
```


Page Visits - Detail:

```ruby
{:results=>
  [{:username=>"bob@foo.com",
    :page_visits=>
     [{:site_name=>"Ars Technica",
       :site_domain=>"arstechnica.com",
       :page_name=>"Ars Technica",
       :page_url=>"http://arstechnica.com/",
       :time_active=>"00:00:03",
       :date_visited=>"2014-10-12T20:33:00.000Z"},
      {:site_name=>"Ars Technica",
       :site_domain=>"arstechnica.com",
       :page_name=>"Technology Lab | Ars Technica",
       :page_url=>"http://arstechnica.com/information-technology/",
       :time_active=>"00:00:18",
       :date_visited=>"2014-10-12T20:33:00.000Z"},
      {:site_name=>"Ars Technica",
       :site_domain=>"arstechnica.com",
       :page_name=>nil,
       :page_url=>
        "http://arstechnica.com/gadgets/2014/10/guitar-hero-ars-builds",
       :time_active=>"00:00:23",
       :date_visited=>"2014-10-12T20:33:00.000Z"},
      {:site_name=>"Ars Technica",
       :site_domain=>"arstechnica.com",
       :page_name=>"Technology Lab | Ars Technica",
       :page_url=>"http://arstechnica.com/information-technology/",
       :time_active=>"00:00:02",
       :date_visited=>"2014-10-12T20:34:00.000Z"},
      {:site_name=>"Ars Technica",
       :site_domain=>"arstechnica.com",
       :page_name=>nil,
       :page_url=> "http://arstechnica.com/security/2014/10/snapchat-images",
       :time_active=>"00:00:09",
       :date_visited=>"2014-10-12T20:34:00.000Z"},
      {:site_name=>"Ars Technica",
       :site_domain=>"arstechnica.com",
       :page_name=>"Why throw early and catch late? | Ars Technica",
       :page_url=>
        "http://arstechnica.com/information-technology/2014/10/why-throw-early",
       :time_active=>"00:01:14",
       :date_visited=>"2014-10-12T20:35:00.000Z"}]}],
 :entity=>"page_visits",
 :date_range=>
  {:date_begin=>"2014-10-11T00:00:00.000+00:00",
   :date_end=>"2014-10-17T23:59:59"},
 :status=>200}
```

# Contributing

Run the test suite with

```shell
bundle exec rake
```

and start coding.
