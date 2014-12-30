require 'spec_helper'

describe Padrino::OrmAdapter do
  subject { Padrino::OrmAdapter }
  
  describe "when a new adapter is created (by inheriting form OrmAdapter::Base)" do
    let!(:adapter) { Class.new(Padrino::OrmAdapter::Base) }
    
    its(:adapters) { should include(adapter) }
    
    after { Padrino::OrmAdapter.adapters.delete(adapter) }
  end
end
