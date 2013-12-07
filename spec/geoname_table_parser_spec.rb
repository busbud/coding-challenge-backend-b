# encoding: utf-8

require 'spec_helper'
require_relative '../geoname_parser'

describe GeonameParser do
  it 'should extract data from tsv data' do
    data = <<EOF
id	name	ascii	alt_name	lat	long	feat_class	feat_code	country	cc2	admin1	admin2	admin3	admin4	population	elevation	dem	tz	modified_at
5881791	Abbotsford	Abbotsford	Abbotsford,YXX,Абботсфорд	49.05798	-122.25257	P	PPL	CA		02	5957659			151683		114	America/Vancouver	2013-04-22
EOF
    parsed = GeonameParser.parse(data)
    first_line = parsed.first

    expect(first_line['name']).to eq('Abbotsford')
    expect(first_line['lat']).to eq(49.05798)
    expect(first_line['long']).to eq(-122.25257)
    expect(first_line['population']).to eq(151683)
  end

  it 'should import data to the city model' do
    data = {'name'       => 'Abbotsford',
            'lat'        => 49.05798,
            'long'       => -122.25257,
            'population' => 151683}
    city = GeonameParser.build_city data

    expect(city.name).to eq('Abbotsford')
    expect(city.latitude).to eq(49.05798)
    expect(city.longitude).to eq(-122.25257)
    expect(city.population).to eq(151683)
  end
end
