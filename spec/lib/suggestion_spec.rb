require 'spec_helper'

describe Suggestion do
  class StubbedCity < Struct.new(:name, :ascii, :latitude, :longitude, :population, :country, :state)
    def complete_name
      "#{name}, #{state}, #{country}"
    end
  end

  let(:datas) do
    [
      StubbedCity.new("Abbotsford", "Abbotsford", 49.05798, -122.25257, 151683, "Canada", "BC"),
      StubbedCity.new("London", "London", 42.98339, -81.23304, 346765, "Canada", "ON"),
      StubbedCity.new("Londonderry", "Londonderry", 42.86509, -71.37395, 11037, "USA", "NH"),
    ]
  end
  let(:city) { StubbedCity.new("London", "London", 42.98339, -81.23304, 346765, "Canada", "ON") }

  let(:suggestion) { Suggestion.new(datas, params) }
  let(:params) { {} }

  describe '#errors?' do
    context "with invalid params" do
      let(:datas) { [] }

      it "should have error" do
        expect(suggestion.errors?).to be_true
      end
    end
  end

  describe '#errors' do
    context "with invalid params" do
      let(:datas) { [] }
      let(:params) { {} }

      it "should have error" do
        expect(suggestion.errors).to be_present
      end
    end
  end

  describe '#results' do
    subject { suggestion.results }

    context "with q" do
      let(:params) { {:q => "london"} }

      it "should return results" do
        expect(subject.length).to eql(2)
      end
    end

    context "with lat/long" do
      let(:params) { {:q => 'london', :latitude => 43.70011, :longitude => -79.4163} }

      it "should return results" do
        expect(subject.length).to eql(2)
      end
    end

    context 'with limit' do
      let(:params) { {:q => 'london', :limit => 1} }

      it "should return results" do
        expect(subject.length).to eql(1)
      end
    end
  end

  describe '#search_according_query' do
    before { suggestion.stub(:q).and_return("london") }

    subject { suggestion.send(:search_according_query) }

    it "should filter results" do
      expect(subject.length).to eql(2)
    end
  end

  describe '#lat_long_present?' do
    subject { suggestion.send(:lat_long_present?) }

    context "with lat/long not set" do
      it "should be false" do
        expect(subject).to be_false
      end
    end

    context "with lat/long set" do
      before { suggestion.stub(:latitude => 12, :longitude => 13) }

      it "should be true" do
        expect(subject).to be_true
      end
    end
  end

  describe '#lat_or_long_missing?' do
    subject { suggestion.send(:lat_or_long_missing?) }

    context "with lat set" do
      before { suggestion.stub(:latitude => 12) }

      it "should be false" do
        expect(subject).to be_true
      end
    end

    context "with long set" do
      before { suggestion.stub(:longitude => 13) }

      it "should be true" do
        expect(subject).to be_true
      end
    end

    context "with lat/long set" do
      before { suggestion.stub(:latitude => 12, :longitude => 13) }

      it "should be true" do
        expect(subject).to be_false
      end
    end
  end

  describe '#query_parameterize' do
    before { suggestion.stub(:q).and_return("montréal") }

    subject { suggestion.send(:query_parameterize) }

    it "should return max score" do
      expect(subject).to eql("montreal")
    end
  end

  describe '#score_by_length_for' do
    before { suggestion.stub(:q).and_return("london") }

    subject { suggestion.send(:score_by_length_for, city) }

    it "should return max score" do
      expect(subject).to eql(1.0)
    end
  end

  describe '#score_by_population_for' do
    before { city.stub(:population => 5000) }

    subject { suggestion.send(:score_by_population_for, city) }

    it "should return score eql 0" do
      expect(subject).to eql(0.0)
    end
  end

  describe '#score_by_distance_for' do
    before { suggestion.stub(:q => "london", :latitude => 42.98339, :longitude => -81.23304) }

    subject { suggestion.send(:score_by_distance_for, city) }

    it "should return max score" do
      expect(subject).to eql(1.0)
    end
  end

  describe '#distance_for' do
    before { suggestion.stub(:q => "london", :latitude => 42.98339, :longitude => -81.23304) }

    subject { suggestion.send(:distance_for, city) }

    it "should return distance eql 0" do
      expect(subject).to eql(0.0)
    end
  end

  describe '#calculate_score_with' do
    let(:scores) { [1,1,1] }
    before { suggestion.stub(:population => 5000) }

    subject { suggestion.send(:calculate_score_with, scores) }

    it "should return score eql 0" do
      expect(subject).to eql(1.0)
    end
  end
end
