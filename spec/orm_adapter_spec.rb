require 'spec_helper'

describe Padrino::OrmAdapter do
  subject { Padrino::OrmAdapter }
  
  describe "when a new adapter is created (by inheriting form OrmAdapter::Base)" do
    let!(:adapter) { Class.new(Padrino::OrmAdapter::Base) }
    
    describe '#adapters' do
      subject { super().adapters }
      it { is_expected.to include(adapter) }
    end
    
    after { Padrino::OrmAdapter.adapters.delete(adapter) }
  end
end
