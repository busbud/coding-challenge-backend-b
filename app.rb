require 'csv'
require 'sinatra/base'
require 'json'


# FIXME: Load this from ISO 3166 documentation
COUNTRIES = {
  'CA' => 'Canada',
  'US' => 'USA',
}

# FIXME: Load this from admin1Codes.txt, found in the geonames dump.
STATES = {
  'CA.00' => 'Canada (general)',
  'CA.01' => 'Alberta',
  'CA.02' => 'British Columbia',
  'CA.03' => 'Manitoba',
  'CA.04' => 'New Brunswick',
  'CA.05' => 'Newfoundland and Labrador',
  'CA.07' => 'Nova Scotia',
  'CA.08' => 'Ontario',
  'CA.09' => 'Prince Edward Island',
  'CA.10' => 'Quebec',
  'CA.11' => 'Saskatchewan',
  'CA.12' => 'Yukon',
  'CA.13' => 'Northwest Territories',
  'CA.14' => 'Nunavut',
  'US.00' => 'United States (general)',
  'US.AK' => 'Alaska',
  'US.AL' => 'Alabama',
  'US.AR' => 'Arkansas',
  'US.AZ' => 'Arizona',
  'US.CA' => 'California',
  'US.CO' => 'Colorado',
  'US.CT' => 'Connecticut',
  'US.DC' => 'Washington, D.C.',
  'US.DE' => 'Delaware',
  'US.FL' => 'Florida',
  'US.GA' => 'Georgia',
  'US.HI' => 'Hawaii',
  'US.IA' => 'Iowa',
  'US.ID' => 'Idaho',
  'US.IL' => 'Illinois',
  'US.IN' => 'Indiana',
  'US.KS' => 'Kansas',
  'US.KY' => 'Kentucky',
  'US.LA' => 'Louisiana',
  'US.MA' => 'Massachusetts',
  'US.MD' => 'Maryland',
  'US.ME' => 'Maine',
  'US.MI' => 'Michigan',
  'US.MN' => 'Minnesota',
  'US.MO' => 'Missouri',
  'US.MS' => 'Mississippi',
  'US.MT' => 'Montana',
  'US.NC' => 'North Carolina',
  'US.ND' => 'North Dakota',
  'US.NE' => 'Nebraska',
  'US.NH' => 'New Hampshire',
  'US.NJ' => 'New Jersey',
  'US.NM' => 'New Mexico',
  'US.NV' => 'Nevada',
  'US.NY' => 'New York',
  'US.OH' => 'Ohio',
  'US.OK' => 'Oklahoma',
  'US.OR' => 'Oregon',
  'US.PA' => 'Pennsylvania',
  'US.RI' => 'Rhode Island',
  'US.SC' => 'South Carolina',
  'US.SD' => 'South Dakota',
  'US.TN' => 'Tennessee',
  'US.TX' => 'Texas',
  'US.UT' => 'Utah',
  'US.VA' => 'Virginia',
  'US.VT' => 'Vermont',
  'US.WA' => 'Washington',
  'US.WI' => 'Wisconsin',
  'US.WV' => 'West Virginia',
  'US.WY' => 'Wyoming',
}


# Cities loads a tab-separated file containing all the cities that can be
# suggested.
class Cities
  def initialize(filename=nil)
    filename ||= File.join(File.dirname(__FILE__),
                           "data", "cities_canada-usa.tsv")

    # FIXME: When the datasets get big enough, turn @data into a prefix-trie
    # to reduce the need to scan the whole table.
    @data = {}
    options = {
      :col_sep => "\t",
      :headers => :first_row,
      :quote_char => "\0",      # Not a quoted TSV.
    }
    CSV.foreach(filename, options) do |row|
      # FIXME: For better results, use unidecode to transliterate names into
      # ASCII. This also means .find() needs to also decode the prefix.
      key = row["ascii"].downcase
      (@data[key] ||= []) << {
        :name => _name(row),
        :latitude => Float(row["lat"]),
        :longitude => Float(row["long"]),
      }
    end
  end

  def _name(row)
    city = row['name']
    country = COUNTRIES[row['country']]

    # "00" as admin1 is always a generic non-state code.
    if row['admin1'] == '00'
      return "#{city}, #{country}"
    end

    state = STATES["#{row['country']}.#{row['admin1']}"] || row['admin1']
    "#{city}, #{state}, #{country}"
  end

  def find(prefix)
    return [] if not prefix or prefix == ""
    prefix = prefix.downcase

    @data.select{|k, v| k.start_with?(prefix)}
  end

  def suggest(prefix, lat=nil, lon=nil)
    suggestions = []
    find(prefix).each_pair do |k, values|
      values.each do |v|
        score = 1.0

        # Small penalty if the prefix and key don't match lengths. This should
        # be faster than comparing exact strings. Strings closer to the prefix
        # will be ranked higher.
        #
        # FIXME: The Levenshtein distance gives better results, but is slower.
        # If the key is encoded in a different way, it will give better matches
        # when used against the city name, though.
        score *= 1 - 0.0001 * (k.length - prefix.length)

        # Penalty for distance from suggested latitude and longitude, using a
        # distance-decay function.
        #
        # FIXME: This only works for small distances, where we can pretend that
        # the Earth is a plane. For larger distances, we need to use the
        # great-circle distance, because the Earth is an ellipsoid. A useful
        # example of this would be to consider the north pole: this score will
        # return different results at various longitudes, even though it
        # shouldn't.
        if lat and lon
          squared_distance = ((v[:latitude] - lat) ** 2 +
                              (v[:longitude] - lon) ** 2)
          score *= 1 / (squared_distance + 1)
        end

        suggestions << v.merge({:latitude => v[:latitude].to_s,
                                 :longitude => v[:longitude].to_s,
                                 :score => score})
      end
    end

    suggestions.sort_by{|e| e[:score]}.reverse!
  end
end


class InvalidCoordinates < StandardError
  attr_reader :errors

  def initialize(errors)
    @errors = errors
  end
end


# http://www.sinatrarb.com/
class App < Sinatra::Base

  def sanitize_coordinates(lat, lon)
    errors = {}

    if lat
      msg = "Invalid latitude: #{lat}"
      begin
        lat = Float(lat)
        if lat < -90.0 or lat > 90.0
          errors[:latitude] = msg
        end
      rescue ArgumentError => e
        errors[:latitude] = msg
      end
    elsif lon
      errors[:latitude] = "Missing latitude"
    end

    if lon
      msg = "Invalid longitude: #{lon}"
      begin
        lon = Float(lon)
        if lat < -180.0 or lat > 180.0
          errors[:longitude] = msg
        end
      rescue ArgumentError => e
        errors[:longitude] = msg
      end
    elsif lat
      errors[:longitude] = "Missing longitude"
    end

    if not errors.empty?
      raise InvalidCoordinates.new(errors)
    end

    [lat, lon]
  end

  # Endpoints
  get '/suggestions' do
    content_type "application/json"

    # Sanitize lat and lon
    begin
      lat, lon = sanitize_coordinates(params["latitude"], params["longitude"])
    rescue InvalidCoordinates => e
      status 400
      return {:errors => e.errors}.to_json
    end

    suggestions = @@cities.suggest(params["q"], lat, lon)
    status 404 if suggestions.empty?
    {:suggestions => suggestions}.to_json
  end

  # Static database initialized on module load
  @@cities = Cities.new
end
