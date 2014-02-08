class ParseDatas
  MAX_POPULATIONS = 5000

  COUNTRY = {
    :CA => 'Canada',
    :US => 'USA'
  }.freeze

  STATES = {
    :CA => {
      1  => 'AB',
      2  => 'BC',
      3  => 'MB',
      4  => 'NB',
      5  => 'NL',
      7  => 'NS',
      8  => 'ON',
      9  => 'PE',
      10 => 'QC',
      11 => 'SK',
      12 => 'YT',
      13 => 'NT',
      14 => 'NU'
    }
  }.freeze

  City = Struct.new(:name, :ascii, :latitude, :longitude, :population, :country, :state)

  def self.get_datas_from_csv(file)
    csv_params = {:col_sep => "\t", :quote_char => "\0", :headers => true, :converters => :numeric}

    cities = []
    CSV.foreach(file, csv_params) do |row|
      next if row['population'] < MAX_POPULATIONS

      cities << City.new(
        row['name'],
        row['ascii'],
        row['lat'],
        row['long'],
        row['population'],
        COUNTRY[row['country'].to_sym],
        city_state(row)
      )
    end

    return cities
  end

  private

  def self.city_state(row)
    return row['admin1'] unless searching_states.include?(row['country'].to_sym)

    STATES[row['country'].to_sym].fetch(row['admin1'].to_i)
  end

  def self.searching_states
    @searching_states ||= STATES.keys
  end
end
