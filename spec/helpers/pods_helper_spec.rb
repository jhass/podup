require 'spec_helper'


describe PodsHelper do
  describe "#location_for" do
    let(:location) { Factory :location, :name => "Test country",
                                        :flag => "dummy.png" }
    it 'allows a location as arguement' do
      helper.location_for(location).should_not be_nil
    end
    
    it 'allows a pod as arguement' do
      helper.location_for(Factory :pod).should_not be_nil
    end
    
    it 'returns nil with an unknown arguement' do
      helper.location_for("dummy").should be_nil
    end
    
    it 'includes the locations flag ' do
      helper.location_for(location).should include location.flag
    end
    
    it 'includes the locations name' do
      helper.location_for(location).should include location.name
    end
    
    it 'returns a link' do
      helper.location_for(location).should include "<a href"
    end
    
    it 'links to the locations path' do
      helper.location_for(location).should include country_path(location)
    end
  end
end
