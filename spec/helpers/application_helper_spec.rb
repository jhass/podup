require 'spec_helper'

describe ApplicationHelper do
  describe '#stars' do
    it 'adds some stars' do
      helper.stars(2).should include "icons/star.png"
    end
    
    it 'add some images' do
      helper.stars(2).should include "<img"
    end
    
    it 'takes a second parameter to specify the maximum available stars' do
      helper.stars(2, 2).should_not include "icons/star_inactive.png"
    end
    
    it 'second parameter defaults to 5' do
      helper.stars(5).should_not include "icons/star_inactive.png"
    end
    
    it 'fills up with inactive stars according to the total parameter' do
      helper.stars(2, 3).should include "icons/star_inactive.png"
    end
    
    it 'adds exactly as much images as the second paremeter specifies' do
      helper.stars(2, 3).should match /^<img.+?<img.+?<img.+?>[^<img]*$/
    end
    
    it 'should return html safe content' do
      helper.stars(2).html_safe?.should be_true
    end
  end
  
  describe '#acceptance_state' do
    it 'returns an image' do
      helper.acceptance_state(true).should include "<img"
    end
    
    it 'returns the right image for true' do
      helper.acceptance_state(true).should include 'icons/accepted.png'
    end
    
    it 'returns the right image for false' do
      helper.acceptance_state(false).should include 'icons/not_accepted.png'
    end
    
    it 'should return html safe content' do
      helper.acceptance_state(true).html_safe?.should be_true
    end
  end
  
  describe '#uptime' do
    it 'includes "Up since" when passed nil' do
      helper.uptime(nil).should include "Up since"
    end
    
    it 'includes "Up since when passed a time' do
      helper.uptime(3.days.from_now).should include "Up since"
    end
    
    it 'includes "never" if passed nil' do
      helper.uptime(nil).should include "never"
    end
    
    it 'includes not "never" if passed in a time' do
      helper.uptime(3.days.from_now).should_not include "never"
    end
    
    it 'should call time_ago_in_words when passed in a time' do
      time = 3.days.from_now
      helper.should_receive(:time_ago_in_words).with(time).exactly(1).times.and_return("foo")
      
      helper.uptime(time)
    end
    
    it 'should include the return value of time_ago_in_words in the return value when passed in a time' do
      helper.stub!(:time_ago_in_words).and_return("test")
      
      helper.uptime(3.days.from_now).should include "test"
    end
    
    it 'should return html safe content when passed in nil' do
      helper.uptime(nil).html_safe?.should be_true
    end
    
    it 'should return html safe content when passed in a time' do
      helper.uptime(3.days.from_now).html_safe?.should be_true
    end
  end
end
