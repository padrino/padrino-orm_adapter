require 'dynamoid'

module Dynamoid
  module Errors
    class DocumentNotFound < StandardError; end
  end
end

module Dynamoid
  module Document
    module ClassMethods
      include Padrino::OrmAdapter::ToAdapter
    end

    class OrmAdapter < Padrino::OrmAdapter::Base
      def column_names
        klass.attributes.keys
      end

      def get!(id)
        klass.find_by_id(wrap_key(id)) || raise(Dynamoid::Errors::DocumentNotFound)
      end

      def get(id)
        klass.where(klass.hash_key => wrap_key(id)).first
      rescue NoMethodError
      end

      def find_first(options = {})
        conditions, order = extract_conditions!(options)
        records = klass.where(conditions_to_fields(conditions))
        (order.present? ? sort_order(order, records.to_a) : records).first
      rescue NoMethodError
      end

      def find_all(options = {})
        conditions, order, limit, _ = extract_conditions!(options)
        records = klass.where(conditions_to_fields(conditions))
        if order.present?
          ordered_records = sort_order(order, records.to_a)
          limit ? ordered_records.slice(0, limit) : ordered_records
        else
          records.limit(limit)
        end
      end

      def create!(attributes = {})
        klass.create!(attributes)
      end

      def destroy(object)
        object.destroy if valid_object?(object)
      end

    protected

      def conditions_to_fields(conditions)
        conditions = conditions.inject({}) do |fields, (key, value)|
          if value.is_a?(Dynamoid::Document) && assoc_key = association_key(key)
            fields.merge(assoc_key => Set[value.id])
          else
            fields.merge(key => value)
          end
        end
      end

      def association_key(key)
        k = "#{key}_ids"
        column_names.find{|c| c == k || c == k.to_sym}
      end

    private

      def sort_order(order, records)
        field, asc_or_desc = order.shift
        records = sort_by_field(field, records, :asc_or_desc => asc_or_desc)
        order.empty? ? records.flatten : sort_order(order, records)
      end

      def sort_by_field(field, records, options = {})
        if records.first.instance_of?(Array)
          records.map { |nested_records| sort_by_field(field, nested_records, options) }
        else
          current_value = nil
          records =
            if options[:asc_or_desc] == :desc
              records.sort { |a, b| b.send(field) <=> a.send(field) }
            else
              records.sort { |a, b| a.send(field) <=> b.send(field) }
            end
          records.each_with_object([]) do |record, new_records|
            value = record.send(field)
            unless current_value == value
              current_value = value
              new_records << []
            end
            new_records.last << record
          end
        end
      end
    end
  end
end
