# Busbud Coding Challenge

## Requirements

Design an API endpoint that provides auto-complete suggestions for large cities.
The suggestions should be restricted to cities in the USA and Canada with a population above 5000 people.

- the endpoint is exposed at `/suggestions`
- the partial (or complete) search term is passed as a querystring parameter `q`
- the caller's location can optionally be supplied via querystring parameters `latitude` and `longitude` to help improve relative scores
- the endpoint returns a JSON response with an array of scored suggested matches
    - the suggestions are sorted by descending score
    - each suggestion has a score between 0 and 1 (inclusive) indicating confidence in the suggestion (1 is most confident)
    - each suggestion has a name which can be used to disambiguate between similarly named locations
    - each suggestion has a latitude and longitude
- all functional tests should pass (additional tests may be implemented as necessary).
- the final application should be [deployed to Heroku](https://devcenter.heroku.com/articles/rack).
- feel free to add more features if you like!

#### Sample responses

These responses are meant to provide guidance. The exact values can vary based on the data source and scoring algorithm

**Near match**

    GET /suggestions?q=Londo&latitude=43.70011&longitude=-79.4163

```json
{
  "suggestions": [
    {
      "name": "London, ON, Canada",
      "latitude": "42.98339",
      "longitude": "-81.23304",
      "score": 0.9
    },
    {
      "name": "London, OH, USA",
      "latitude": "39.88645",
      "longitude": "-83.44825",
      "score": 0.5
    },
    {
      "name": "London, KY, USA",
      "latitude": "37.12898",
      "longitude": "-84.08326",
      "score": 0.5
    },
    {
      "name": "Londontowne, MD, USA",
      "latitude": "38.93345",
      "longitude": "-76.54941",
      "score": 0.3
    }
  ]
}
```

**No match**

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

## Implementation

Implemented on Heroku here: http://powerful-sierra-1219.herokuapp.com/

My solution consists of two main components:
- `CityMatcher`, a class responsible for parsing the city data file, and then
  returning cities that match a partial city name. Partial city names provided
  for the lookup are case insensitive, and do not treat accented characters
  specially (é is considered the same as e). Lookups are done using a trie,
  a space-efficient data structure that allows for fast partial string match
  lookups.
- `CityScorer`, a class which is responsble for assigning a confidence scores to
   a set of cities.

### Scoring

Scoring is based on three criteria:

 1. Name completeness: Potentially matching cities for the partial match
    'Plymouth' are 'Plymouth, PA, USA' and 'Plymouth Meeting, PA, USA'. The
    closer the partial match is to the full city name, the more likely it is that
    the person is attempting to match that city, so 'Plymouth, PA, USA' will have a
    higher confidence score.
 2. Population: Buses are more likely to depart from cities with higher
    populations, and an individual is more likely to be living in a city with
    more people. Therefore, cities with higher populations are assinged a higher
    confidence score.
 3. Distance: If the latitude and longitude of the user are given, a closer city
    will be assigned a higher confidence score.

The highest score that can be assigned to an attribute is 1.0, while the lowest
that can be assigned is 0.0. A higher score represents a more confident
suggestion. The total confidence score is a weighted average of the individual
attributes, again from 0.0 to 1.0, with the following weighting schemes used:

 1. Latitude and longitude provided:

    `0.3 * name completeness score + 0.2 * population score + 0.5 * distance core`

 2. Latitude and longitude not provided:

    `0.6 * name completeness score + 0.4 * population score`

### Mitigations to handle high levels of traffic

In order to handle potentially high amounts of traffic, a Memcache instance
has been created on Heroku (using MemCachier). This cache is used in two ways:

 1. HTTP requests are cached using `Rack::Cache` for 30 seconds
 2. The lookup for cities that match a partial city name is cached for 60
    seconds. (This is the output of `CityMatcher`, which used by `CityScorer` to
    compute the scores).

### Future Improvements

Several improvements could be made to this implementation. Some of them are:
- Take city names in different languages into account. Right now, only the
  primary name of the city is used (the English name for non-Quebec cities, and
  the French name for Quebec cities). However, the city data file has city
  names in several different languages for many Canadian cities, which could be
  used for better matching.
- Add the ability to limit the number of cities returned. This would be passed
  in the query string as `&limit=n`, where only the top `n` cities would be
  returned in the json response.
- Update the scoring algorithm to figure out if the user is in Canada or the
  United States by latitude/longitude or IP address, and then provide higher
  scores to cities in the same country.
- Use a more persistent key-value store (Redis) instead of Memcache, so that if
  there is an outage our caches do not go cold.
