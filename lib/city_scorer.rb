require 'haversine'
require 'json'

# This class takes as input an Array of cities, a string that partially matches
# the names of these cities, and optionally the latitude and longitude of the
# user. It is responsible for assigning a score to each city, which represets
# how confident it is that the user is attempting to select each of the cities. The array
# of cities is then returned in order of confidence, with the most confident
# match at the top.
#
# Scoring is based on three criteria:
# 1. Name completeness:
#     Potentially matching cities for the partial match 'Plymouth' are
#     'Plymouth, PA, USA' and 'Plymouth Meeting, PA, USA'. The closer the
#     partial match is to the full city name, the more likely it is that the
#     person is attempting to match that city, so 'Plymouth, PA, USA' will have
#     a higher confidence score.
# 2. Population:
#     Buses are more likely to depart from cities with higher populations, and an
#     individual is more likely to be living in a city with more people.
#     Therefore, cities with higher populations are assinged a higher confidence score.
# 3. Distance:
#     If the latitude and longitude of the user are given, a closer city will be
#     assigned a higher confidence score.
#
# The highest score that can be assigned to an attribute is 1.0, while the lowest that
# can be assigned is 0.0. A higher score represents a more confident suggestion.
# The total confidence score is a weighted average of the individual attributes, again
# from 0.0 to 1.0, with the following weighting schemes used:
#
# 1. Latitude and longitude provided:
#   0.3 * name completeness score + 0.2 * population score + 0.5 * distance score
# 2. Latitude and longitude not provided:
#   0.6 * name completeness score + 0.4 * name population score
#
#
# Expceted usage of the class is as follows:
#
# city_scorer = CityScorer.new(city_list)
# city_scorer.score_cities
# city_scorer.cities_to_hash
# => An array of the cities, sorted by score descending, where each city is of type Hash
class CityScorer

  City = Struct.new(:name, :lat, :long, :population, :name_completeness_score,
                    :population_score, :distance, :distance_score, :score)

  def initialize(cities, partial_match, lat = nil, long = nil)
    @cities = cities.map { |c| City.new(c.name, c.lat, c.long, c.population) }
    @partial_match_size = partial_match.size.to_f
    @lat = lat
    @long = long
  end

  def score_cities
    score_population
    score_name_completeness
    score_distance

    @cities.each do |city|
      if should_score_distance?
        city.score = 0.3 * city.name_completeness_score +
                     0.2 * city.population_score +
                     0.5 * city.distance_score
      else
        city.score = 0.6 * city.name_completeness_score +
                     0.4 * city.population_score
      end
    end
  end

  def cities_to_hash
    sorted_cities = @cities.sort_by(&:score).reverse
    cities_hashed = sorted_cities.map do |c|
      {'name' => c.name,
       'latitude' => c.lat,
       'longitude' => c.long,
       'score' => c.score}
    end
  end

  private

  def score_population
    max_pop = @cities.max_by(&:population).population.to_f

    @cities.each do |city|
      city.population_score = city.population / max_pop
    end
  end

  def score_name_completeness
    @cities.each do |city|
      city.name_completeness_score = @partial_match_size / city.name.size
    end
  end

  def should_score_distance?
    return !@lat.nil? && !@long.nil?
  end

  def score_distance
    return unless should_score_distance?

    @cities.each do |city|
      city.distance = Haversine.distance(@lat, @long, city.lat, city.long).to_m
    end

    max_distance = @cities.max_by(&:distance).distance

    @cities.each do |city|
      city.distance_score = 1 - city.distance / max_distance
    end
  end

end
