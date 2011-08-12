require 'spec_helper'

describe State do
  let(:pod) { Factory :pod }
  
  it 'validates the presence of a pod' do
    expect {
      State.create!(:up => true, :maintenance => true)
    }.to raise_error ActiveRecord::RecordInvalid,
                     "Validation failed: Pod can't be blank"
  end
  
  it 'validates the presence of up' do
    expect {
      State.create!(:maintenance => true, :pod_id => pod.id)
    }.to raise_error ActiveRecord::RecordInvalid,
                     "Validation failed: Up is not included in the list"
  end
  
  it 'allows true for up' do
    expect {
      State.create!(:up => true, :maintenance => true, :pod_id => pod.id)
    }.to_not raise_error ActiveRecord::RecordInvalid
  end
  
  it 'allows false for up' do
    expect {
      State.create!(:up => false, :maintenance => true, :pod_id => pod.id)
    }.to_not raise_error ActiveRecord::RecordInvalid
  end
  
  it 'does not allow non boolean values for up' do
    pending "why ever this is not working, further investigation needed"
    expect {
      State.create!(:up => 'foo', :maintenance => true, :pod_id => pod.id)
    }.to raise_error ActiveRecord::RecordInvalid,
                     "Validation failed: Up is not included in the list"
  end
  
  it 'validates the presence of maintenance' do
    expect {
      State.create!(:up => true, :pod_id => pod.id)
    }.to raise_error ActiveRecord::RecordInvalid,
                     "Validation failed: Maintenance is not included in the list"
  end
  
  it 'allows true for maintenance' do
    expect {
      State.create!(:up => true, :maintenance => true, :pod_id => pod.id)
    }.to_not raise_error ActiveRecord::RecordInvalid
  end
  
  it 'allows false for maintenance' do
    expect {
      State.create!(:up => true, :maintenance => false, :pod_id => pod.id)
    }.to_not raise_error ActiveRecord::RecordInvalid
  end
  
  it 'does not allow non boolean values for maintenance' do
    pending "why ever this is not working, further investigation needed"
    expect {
      State.create!(:up => true, :maintenance => 'foo', :pod_id => pod.id)
    }.to raise_error ActiveRecord::RecordInvalid,
                     "Validation failed: Maintenance is not included in the list"
  end
  
  describe '#up?' do
    it 'returns true if up is true' do
      state = Factory :up_state
      
      state.up?.should be_true
    end
    
    it 'returns false if up is false' do
      state = Factory :down_state
      
      state.up?.should be_false
    end
  end
  
  context 'scope' do
    describe '#up' do
      it 'returns up states' do
        up_state = Factory :up_state
        
        State.up.all.should include up_state
      end
      
      it 'does not return down states' do
        down_state = Factory :down_state
        
        State.up.all.should_not include down_state
      end
      
      it 'includes maintenance states if they are up' do
        up_maintenance_state = Factory :up_maintenance_state
        
        State.up.all.should include up_maintenance_state
      end
    end
    
    describe '#down' do
      it 'returns down states' do
        down_state = Factory :down_state
        
        State.down.all.should include down_state
      end
      
      it 'does not return up states' do
        up_state = Factory :up_state
        
        State.down.all.should_not include up_state
      end
      
      it 'does not return down maintenance states' do
        down_maintenance_state = Factory :down_maintenance_state
        
        State.down.all.should_not include down_maintenance_state
      end
      
      it 'does not return up maintenance states' do
        up_maintenance_state = Factory :up_maintenance_state
        
        State.down.all.should_not include up_maintenance_state
      end
    end
    
    describe '#maintenance' do
      it 'returns up maintenance states' do
        up_maintenance_state = Factory :up_maintenance_state
        
        State.maintenance.all.should include up_maintenance_state
      end
      
      it 'returns down maintenance states' do
        down_maintenance_state = Factory :down_maintenance_state
        
        State.maintenance.all.should include down_maintenance_state
      end
      
      it 'does not return up non-maintenance states' do
        up_state = Factory :up_state
        
        State.maintenance.all.should_not include up_state
      end
      
      it 'does not return down non-maintenance states' do
        down_state = Factory :down_state
        
        State.maintenance.all.should_not include down_state
      end
    end
  end
end
