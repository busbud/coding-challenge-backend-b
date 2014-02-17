require 'spec_helper'

describe ParseDatas do
  let(:file) { File.join(File.dirname(__FILE__), '..', "fixtures", "example_file.tsv") }

  describe "self.get_datas_from_csv" do
    subject { ParseDatas.get_datas_from_csv(file) }

    it "should return cities" do
      expect(subject.length).to eql(3)
    end

    it "should includes specified keys" do
      keys = subject.first.to_h.keys

      expect(keys).to include(:name)
      expect(keys).to include(:ascii)
      expect(keys).to include(:latitude)
      expect(keys).to include(:longitude)
      expect(keys).to include(:population)
      expect(keys).to include(:country)
      expect(keys).to include(:state)
    end
  end

  describe "self.city_state" do
    let(:row) { { "id" => 5881791, "name" => "Abbotsford", "country" => "CA", "admin1" => 2 } }

    subject { ParseDatas.send(:city_state, row)}

    it "should return state" do
      expect(subject).to eql("BC")
    end
  end
end