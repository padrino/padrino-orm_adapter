# Copied from orm_adapter and fixed some Specs

# to test your new orm_adapter, make an example app that matches the functionality
# found in the existing specs for example, look at spec/orm_adapter/adapters/active_record_spec.rb
#
# Then you can execute this shared spec as follows:
#
#   it_should_behave_like "example app with orm_adapter" do
#     let(:user_class) { User }
#     let(:note_class) { Note }
#
#     # optionaly define the following functions if the ORM does not support
#     # this syntax - this should NOT use the orm_adapter, because we're testing that
#     def create_model(klass, attrs = {})
#       klass.create!(attrs)
#     end
#
#     def reload_model(model)
#       model.class.find(model.id)
#     end
#   end
#
shared_examples_for "example app with orm_adapter" do

  def create_model(klass, attrs = {})
    klass.create!(attrs)
  end

  def reload_model(model)
    model.class.find(model.id)
  end

  def skip(*orms)
    if orms.any? { |orm| described_class.to_s.split(/::/).include?(orm.to_s.camelize) }
      super "This feature isn't supported by #{orms * ','}"
    end
  end

  describe "an ORM class" do
    subject { note_class }

    it "#to_adapter should return an adapter instance" do
      expect(subject.to_adapter).to be_a(Padrino::OrmAdapter::Base)
    end

    it "#to_adapter should return an adapter for the receiver" do
      expect(subject.to_adapter.klass).to eq(subject)
    end

    it "#to_adapter should be cached" do
      expect(subject.to_adapter.object_id).to eq(subject.to_adapter.object_id)
    end
  end

  describe "adapter instance" do
    let(:note_adapter) { note_class.to_adapter }
    let(:user_adapter) { user_class.to_adapter }

    describe "#get!(id)" do
      it "should return the instance with id if it exists" do
        user = create_model(user_class)
        expect(user_adapter.get!(user.id)).to eq(user)
      end

      it "should allow to_key like arguments" do
        user = create_model(user_class)
        expect(user_adapter.get!(user.to_key)).to eq(user)
      end

      it "should raise an error if there is no instance with that id" do
        expect { user_adapter.get!("nonexistent id") }.to raise_error(nonexistent_id_error)
      end
    end

    describe "#get(id)" do
      it "should return the instance with id if it exists" do
        user = create_model(user_class)
        expect(user_adapter.get(user.id)).to eq(user)
      end

      it "should allow to_key like arguments" do
        user = create_model(user_class)
        expect(user_adapter.get(user.to_key)).to eq(user)
      end

      it "should return nil if there is no instance with that id" do
        expect(user_adapter.get("nonexistent id")).to be_nil
      end
    end

    describe "#find_first" do
      describe "(conditions)" do
        it "should return first model matching conditions, if it exists" do
          user = create_model(user_class, :name => "Fred")
          expect(user_adapter.find_first(:name => "Fred")).to eq(user)
        end

        it "should return nil if no conditions match" do
          expect(user_adapter.find_first(:name => "Betty")).to eq(nil)
        end

        it 'should return the first model if no conditions passed' do
          skip :dynamoid
          user = create_model(user_class)
          create_model(user_class)
          expect(user_adapter.find_first).to eq(user)
        end

        it "when conditions contain associated object, should return first model if it exists" do
          skip :dynamoid
          user = create_model(user_class)
          note = create_model(note_class, :owner => user)
          expect(note_adapter.find_first(:owner => user)).to eq(note)
        end

        it "understands :id as a primary key condition (allowing scoped finding)" do
          create_model(user_class, :name => "Fred")
          user = create_model(user_class, :name => "Fred")
          expect(user_adapter.find_first(:id => user.id, :name => "Fred")).to eq(user)
          expect(user_adapter.find_first(:id => user.id, :name => "Not Fred")).to be_nil
        end
      end

      describe "(:order => <order array>)" do
        it "should return first model in specified order" do
          user1 = create_model(user_class, :name => "Fred", :rating => 1)
          user2 = create_model(user_class, :name => "Fred", :rating => 2)
          expect(user_adapter.find_first(:order => [:name, [:rating, :desc]])).to eq(user2)
        end
      end

      describe "(:conditions => <conditions hash>, :order => <order array>)" do
        it "should return first model matching conditions, in specified order" do
          user1 = create_model(user_class, :name => "Fred", :rating => 1)
          user2 = create_model(user_class, :name => "Fred", :rating => 2)
          expect(user_adapter.find_first(:conditions => {:name => "Fred"}, :order => [:rating, :desc])).to eq(user2)
        end
      end
    end

    describe "#find_all" do
      describe "(conditions)" do
        it "should return only models matching conditions" do
          user1 = create_model(user_class, :name => "Fred")
          user2 = create_model(user_class, :name => "Fred")
          user3 = create_model(user_class, :name => "Betty")
          expect(user_adapter.find_all(:name => "Fred").to_a).to match_array([user1, user2])
        end

        it "should return all models if no conditions passed" do
          user1 = create_model(user_class, :name => "Fred")
          user2 = create_model(user_class, :name => "Fred")
          user3 = create_model(user_class, :name => "Betty")
          expect(user_adapter.find_all.to_a).to match_array([user1, user2, user3])
        end

        it "should return empty array if no conditions match" do
          expect(user_adapter.find_all(:name => "Fred")).to eq([])
        end

        it "when conditions contain associated object, should return first model if it exists" do
          skip :dynamoid
          user1, user2 = create_model(user_class), create_model(user_class)
          note1 = create_model(note_class, :owner => user1)
          note2 = create_model(note_class, :owner => user2)
          expect(note_adapter.find_all(:owner => user2)).to eq([note2])
        end
      end

      describe "(:order => <order array>)" do
        it "should return all models in specified order" do
          user1 = create_model(user_class, :name => "Fred", :rating => 1)
          user2 = create_model(user_class, :name => "Fred", :rating => 2)
          user3 = create_model(user_class, :name => "Betty", :rating => 1)
          expect(user_adapter.find_all(:order => [:name, [:rating, :desc]])).to eq([user3, user2, user1])
        end
      end

      describe "(:conditions => <conditions hash>, :order => <order array>)" do
        it "should return only models matching conditions, in specified order" do
          user1 = create_model(user_class, :name => "Fred", :rating => 1)
          user2 = create_model(user_class, :name => "Fred", :rating => 2)
          user3 = create_model(user_class, :name => "Betty", :rating => 1)
          expect(user_adapter.find_all(:conditions => {:name => "Fred"}, :order => [:rating, :desc])).to eq([user2, user1])
        end
      end

      describe "(:limit => <number of items>)" do
        it "should return a limited set of matching models" do
          user1 = create_model(user_class, :name => "Fred", :rating => 1)
          user2 = create_model(user_class, :name => "Fred", :rating => 2)
          user3 = create_model(user_class, :name => "Betty", :rating => 3)
          expect(user_adapter.find_all(:limit => 1, :order => [:rating, :asc])).to eq([user1])
          expect(user_adapter.find_all(:limit => 2, :order => [:rating, :asc])).to eq([user1, user2])
        end
      end

      describe "(:offset => <offset number>) with limit (as DataMapper doesn't allow offset on its own)" do
        it "should return an offset set of matching models" do
          skip :dynamoid
          user1 = create_model(user_class, :name => "Fred", :rating => 1)
          user2 = create_model(user_class, :name => "Fred", :rating => 2)
          user3 = create_model(user_class, :name => "Betty", :rating => 3)
          expect(user_adapter.find_all(:limit => 3, :offset => 0, :order => [:rating, :asc])).to eq([user1, user2, user3])
          expect(user_adapter.find_all(:limit => 3, :offset => 1, :order => [:rating, :asc])).to eq([user2, user3])
          expect(user_adapter.find_all(:limit => 1, :offset => 1, :order => [:rating, :asc])).to eq([user2])
        end
      end
    end

    describe "#create!(attributes)" do
      it "should create a model with the passed attributes" do
        user = user_adapter.create!(:name => "Fred")
        expect(reload_model(user).name).to eq("Fred")
      end

      it "should raise error when create fails" do
        expect { user_adapter.create!(:user => create_model(note_class)) }.to raise_error(unknown_attribute_error)
      end

      it "when attributes contain an associated object, should create a model with the attributes" do
        user = create_model(user_class)
        note = note_adapter.create!(:owner => user)
        expect(reload_model(note).owner).to eq(user)
      end

      it "when attributes contain an has_many assoc, should create a model with the attributes" do
        skip :dynamoid
        notes = [create_model(note_class), create_model(note_class)]
        user = user_adapter.create!(:notes => notes)
        expect(reload_model(user).notes).to eq(notes)
      end
    end

    describe "#destroy(instance)" do
      it "should destroy the instance if it exists" do
        user = create_model(user_class)
        expect(!!user_adapter.destroy(user)).to eq(true)  # make it work with both RSpec 2.x and 3.x
        expect(user_adapter.get(user.id)).to be_nil
      end

      it "should return nil if passed with an invalid instance" do
        expect(user_adapter.destroy("nonexistent instance")).to be_nil
      end

      it "should not destroy the instance if it doesn't match the model class" do
        user = create_model(user_class)
        expect(note_adapter.destroy(user)).to be_nil
        expect(user_adapter.get(user.id)).to eq(user)
      end
    end
  end
end
