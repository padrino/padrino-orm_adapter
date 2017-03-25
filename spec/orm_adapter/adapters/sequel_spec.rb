require 'spec_helper'
require 'orm_adapter/example_app_shared'

if !defined?(Sequel)
  puts "** require 'sequel' to run the specs in #{__FILE__}"
else
  DB = Sequel.sqlite

  DB.create_table(:users) do
    primary_key :id
    String :name
    Integer :rating
  end

  DB.create_table(:notes) do
    primary_key :id
    String :body
    Integer :owner_id
  end

  module SequelOrmSpec
    class User < Sequel::Model
      one_to_many :notes, :key => :owner_id
    end

    class Note < Sequel::Model
      many_to_one :owner, :class => User
    end

    describe Padrino::OrmAdapter::Sequel do
      before do
        User.truncate
        Note.truncate
      end

      it_should_behave_like "example app with orm_adapter" do
        let(:nonexistent_id_error) { Sequel::NoMatchingRow }
        let(:unknown_attribute_error) { Sequel::MassAssignmentRestriction }
        let(:user_class) { User }
        let(:note_class) { Note }

        def create_model(klass, attrs = {})
          klass.create(attrs)
        end

        def reload_model(model)
          model.class[model.id]
        end
      end
    end
  end
end
