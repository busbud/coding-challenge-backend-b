# Demo

Demo deployed on [Heroku](http://peaceful-refuge-1532.herokuapp.com/suggestions?q=london)

# Data Parsing

ParseDatas class is in charge of the parse and can be used like send the file path in params:
```
cities = ParseDatas.get_datas_from_csv(file_path)
```

All cities where population < ParseDatas::MAX_POPULATIONS (here it's 5000) are excluded.

# Suggestion

Suggestion class is in charge of the search.
```
suggestion = Suggestion.new($cities, params)
suggestion.results
```

Limit parameter has been implemented.

Results are scored about 3 arguments:
* score by length: Comparing the length of the query with the length of the city.
* score by population : Make priority to big cities.
* score by distance (when lat/long set): Make priority to small distance comparing to the maximum possible distance

What's not implemented:
A ratio would be implemented depending of the score priorities (add more points to length and distance but less to populations).

# Cache

Adding Redis to handle high levels of traffic