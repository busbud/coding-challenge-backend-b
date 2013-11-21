# Busbud Coding Challenge

## Requirements

Design an API endpoint that provides auto-complete suggestions for large cities.
The suggestions should be restricted to cities in the USA and Canada with a population above 5000 people.

- the endpoint is exposed at `/suggestions`
- the partial (or complete) search term is passed as a querystring parameter `q`
- the caller's location can optionally be supplied via querystring parameters `lat` and `long` to help improve relative scores
- the endpoint returns a JSON response with an array of scored suggested matches, sorting by descending score
- all functional tests should pass (additional tests may be implemented as necessary).
- the final application should be [deployed to Heroku](https://devcenter.heroku.com/articles/rack).

#### Minimal sample responses

These responses are meant to provide guidance. The exact values can vary based on the data source and scoring algorithm

** Near match **

    GET /suggestions?q=Londo&latitude=43.70011&longitude=-79.4163

```json
{
  "suggestions": [
    {
      "name": "London, ON, Canada",
      "lat": "42.98339",
      "long": "-81.23304",
      "score": 0.9
    },
    {
      "name": "London, OH, USA",
      "lat": "39.88645",
      "long": "-83.44825",
      "score": 0.5
    },
    {
      "name": "London, KY, USA",
      "lat": "37.12898",
      "long": "-84.08326",
      "score": 0.5
    },
    {
      "name": "Londontowne, MD, USA",
      "lat": "38.93345",
      "long": "-76.54941",
      "score": 0.3
    }
  ]
}
```

** No match **

    GET /suggestions?q=SomeRandomCityInTheMiddleOfNowhere

```json
{
  "suggestions": []
}
```


### Non-functional

- All code should be written in Ruby
- Mitigations to handle high levels of traffic should be implemented
- Work should be submitted as a pull-request to this repo
- Documentation and maintainability is a plus

### References

- Geonames provides city lists Canada and the USA http://download.geonames.org/export/dump/readme.txt
- http://www.sinatrarb.com/


## Getting Started

Begin by forking this repo and cloning your fork. GitHub has apps for [Mac](http://mac.github.com/) and [Windows](http://windows.github.com/) that make this easier.

### Setting up a Ruby environment

Get started by installing [`rbenv`](https://github.com/sstephenson/rbenv#basic-github-checkout) and [`ruby-build`](https://github.com/sstephenson/ruby-build#installing-as-an-rbenv-plugin-recommended).

For OS X users, this will require the Xcode Command Line tools and a few [Homebrew](http://github.com/mxcl/homebrew) packages. Details [here](https://github.com/sstephenson/ruby-build/wiki#suggested-build-environment).

Once that's done run

```
rbenv install 2.0.0-p247
```

followed by

```
rbenv shell 2.0.0-p247
```

### Setting up the project

In the project directory run

```
gem install bundler
```

followed by

```
bundle install
```

(You may need to run `rbenv rehash` if the `bundle` command is unavailable).

### Running the tests

The test suite can be run with

```
bundle exec rspec
```

### Starting the application

To start a local server run

```
bundle exec thin start
```

which should produce output similar to

```
Using rack adapter
Thin web server (v1.6.1 codename Death Proof)
Maximum connections set to 1024
Listening on 0.0.0.0:3000, CTRL+C to stop
```