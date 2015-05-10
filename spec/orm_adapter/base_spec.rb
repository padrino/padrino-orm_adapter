require 'spec_helper'

describe Padrino::OrmAdapter::Base do
  subject { Padrino::OrmAdapter::Base.new(Object) }

  describe "#extract_conditions!" do
    let(:conditions) { {:foo => 'bar'} }
    let(:order) { [[:foo, :asc]] }
    let(:limit) { 1 }
    let(:offset) { 2 }

    it "(<conditions>)" do
      expect(subject.send(:extract_conditions!, conditions)).to eq([conditions, [], nil, nil])
    end

    it "(:conditions => <conditions>)" do
      expect(subject.send(:extract_conditions!, :conditions => conditions)).to eq([conditions, [], nil, nil])
    end

    it "(:order => <order>)" do
      expect(subject.send(:extract_conditions!, :order => order)).to eq([{}, order, nil, nil])
    end

    it "(:limit => <limit>)" do
      expect(subject.send(:extract_conditions!, :limit => limit)).to eq([{}, [], limit, nil])
    end

    it "(:offset => <offset>)" do
      expect(subject.send(:extract_conditions!, :offset => offset)).to eq([{}, [], nil, offset])
    end

    it "(:conditions => <conditions>, :order => <order>)" do
      expect(subject.send(:extract_conditions!, :conditions => conditions, :order => order)).to eq([conditions, order, nil, nil])
    end

    it "(:conditions => <conditions>, :limit => <limit>)" do
      expect(subject.send(:extract_conditions!, :conditions => conditions, :limit => limit)).to eq([conditions, [], limit, nil])
    end

    it "(:conditions => <conditions>, :offset => <offset>)" do
      expect(subject.send(:extract_conditions!, :conditions => conditions, :offset => offset)).to eq([conditions, [], nil, offset])
    end

    describe "#valid_object?" do
      it "determines whether an object is valid for the current model class" do
        expect(subject.send(:valid_object?, Object.new)).to be_truthy
        expect(subject.send(:valid_object?, String.new)).to be_falsey
      end
    end

    describe "#normalize_order" do
      specify "(nil) returns []" do
        expect(subject.send(:normalize_order, nil)).to eq([])
      end

      specify ":foo returns [[:foo, :asc]]" do
        expect(subject.send(:normalize_order, :foo)).to eq([[:foo, :asc]])
      end

      specify "[:foo] returns [[:foo, :asc]]" do
        expect(subject.send(:normalize_order, [:foo])).to eq([[:foo, :asc]])
      end

      specify "[:foo, :desc] returns [[:foo, :desc]]" do
        expect(subject.send(:normalize_order, [:foo, :desc])).to eq([[:foo, :desc]])
      end

      specify "[:foo, [:bar, :asc], [:baz, :desc], :bing] returns [[:foo, :asc], [:bar, :asc], [:baz, :desc], [:bing, :asc]]" do
        expect(subject.send(:normalize_order, [:foo, [:bar, :asc], [:baz, :desc], :bing])).to eq([[:foo, :asc], [:bar, :asc], [:baz, :desc], [:bing, :asc]])
      end

      specify "[[:foo, :wtf]] raises ArgumentError" do
        expect { subject.send(:normalize_order, [[:foo, :wtf]]) }.to raise_error(ArgumentError)
      end

      specify "[[:foo, :asc, :desc]] raises ArgumentError" do
        expect { subject.send(:normalize_order, [[:foo, :asc, :desc]]) }.to raise_error(ArgumentError)
      end
    end
  end
end
