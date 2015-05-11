require 'spec_helper'
require 'orm_adapter/example_app_shared'

if !defined?(MiniRecord::AutoSchema)
  puts "** require 'mini_record' to run the specs in #{__FILE__}"
else
  ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ":memory:")

  module MrOrmSpec
    class User < ActiveRecord::Base
      field :name, :as => :string
      field :rating, :as => :integer
      has_many :notes, :as => :owner
    end

    class AbstractNoteClass < ActiveRecord::Base
      field :owner, :as => :references
      belongs_to :owner, :polymorphic => true
      self.abstract_class = true
    end

    class Note < AbstractNoteClass
      field :owner, :as => :references
      belongs_to :owner, :polymorphic => true
    end

    ActiveRecord::Base.auto_upgrade!

    # here be the specs!
    describe '[MiniRecord orm adapter]' do
      before do
        User.delete_all
        Note.delete_all
      end

      it_should_behave_like "example app with orm_adapter" do
        let(:user_class) { User }
        let(:note_class) { Note }
      end

      describe "#conditions_to_fields" do
        describe "with non-standard association keys" do
          class PerverseNote < Note
            belongs_to :user, :foreign_key => 'owner_id'
            belongs_to :pwner, :polymorphic => true, :foreign_key => 'owner_id', :foreign_type => 'owner_type'
          end

          let(:user) { User.create! }
          let(:adapter) { PerverseNote.to_adapter }

          it "should convert polymorphic object in conditions to the appropriate fields" do
            expect(adapter.send(:conditions_to_fields, :pwner => user)).to eq({'owner_id' => user.id, 'owner_type' => user.class.name})
          end

          it "should convert belongs_to object in conditions to the appropriate fields" do
            expect(adapter.send(:conditions_to_fields, :user => user)).to eq({'owner_id' => user.id})
          end
        end
      end
    end
  end
end
