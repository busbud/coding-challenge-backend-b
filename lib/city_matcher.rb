require 'trie'

require_relative 'common'
require_relative 'strict_tsv'

# This class is responsible for parsing the city data file, and returning
# cities whose names match a given partial name.
# Usage should be as follows:
#
# city_matcher = CityMatcher.new(data_file)
# city_matcher.possible_cities('partial city name')
# => Array of matching cities, where each city is of type CityMatcher::City
class CityMatcher
  # Canadian provinces are encoded as numbers in the data file.
  # This maps the numbers to the corresponding provinces
  PROV_MAPPINGS = {
    '01' => 'AB',
    '02' => 'BC',
    '03' => 'MB',
    '04' => 'NB',
    '05' => 'NL',
    '07' => 'NS',
    '08' => 'ON',
    '09' => 'PE',
    '10' => 'QC',
    '11' => 'SK',
    '12' => 'YT',
    '13' => 'NT',
    '14' => 'NU'
  }

  COUNTRY_MAPPINGS = {
    'CA' => 'Canada',
    'US' => 'USA'
  }

  City = Struct.new(:name, :lat, :long, :population)

  # Load a city data file in tsv format
  def initialize(city_file)
    # A trie allows us to efficiently find every city that matches a pattern.
    # http://en.wikipedia.org/wiki/Trie
    @city_trie = Trie.new

    # @city_trie will return to us the names of cities that match a certain
    # pattern as strings.  We use @cities to look up the corresponding City
    # structs (this way, our trie is smaller)
    @cities = {}

    tsv = StrictTsv.new(city_file)
    tsv.parse do |row|
      population = row['population'].to_i
      next if population <= 5000 # reject if population is 5000 or lower
      name = row['name']
      prov = PROV_MAPPINGS[row['admin1']] || row['admin1']
      country = COUNTRY_MAPPINGS[row['country']]
      full_name = [name, prov, country].join(', ')
      city = City.new(
        full_name,
        row['lat'].to_f,
        row['long'].to_f,
        population
      )

      lookup_name = normalize_name(full_name)
      @cities[lookup_name] = @cities.fetch(lookup_name, []) << city
      @city_trie.add(lookup_name)
    end
  end

  # Takes a partial city name, and returns an Array of City structs that match
  # the string. The input city name is downcased, and accented characters are
  # replaced with their non-accented counterparts, so that the lookup is case
  # and language insensitive.
  def possible_cities(partial_name)
    return nil unless partial_name
    city_names = @city_trie.children(normalize_name(partial_name))
    return city_names.map { |c| @cities[c] }.flatten.compact
  end

  private
  def normalize_name(name)
    # In order for our lookups to be case-insensitive, we use a city's downcased
    # name as keys in @citiess and @city_trie.
    # We also remove any accented characters, so that English users can still find
    # cities with French accents.
    # (For example, 'Montré' and 'Montre' will both match 'Montréal')
    # The Trie class used does not support "'" in strings, so we sub these out.
    # A better solution would be to implement our own trie
    remove_accented_characters(name.downcase.gsub("'", ''))
  end
end
