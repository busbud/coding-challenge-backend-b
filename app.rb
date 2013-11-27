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
      @data[row["ascii"].downcase] = {
        :name => _name(row),
        :latitude => row["lat"],
        :longitude => row["long"],
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

  def suggest(prefix)
    suggestions = find(prefix).values.map do |e|
      score = 1.0
      e.merge({:score => score})
    end

    suggestions.sort_by{|e| e[:score]}.reverse!
  end
end


# http://www.sinatrarb.com/
class App < Sinatra::Base
  # Endpoints
  get '/suggestions' do
    suggestions = @@cities.suggest(params["q"])
    status 404 if suggestions.empty?
    content_type "application/json"
    {:suggestions => suggestions}.to_json
  end

  # Static database initialized on module load
  @@cities = Cities.new
end
