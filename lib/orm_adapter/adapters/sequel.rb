require 'sequel'

module OrmAdapter
  class Sequel < Base
    # get a list of column names for a given class
    def column_names
      klass.columns
    end

    # @see OrmAdapter::Base#get!
    def get!(id)
      klass.with_pk!(wrap_key(id))
    end

    # @see OrmAdapter::Base#get
    def get(id)
      klass.with_pk(wrap_key(id))
    end

    # @see OrmAdapter::Base#find_first
    def find_first(options = {})
      construct_query(options).first
    end

    # @see OrmAdapter::Base#find_all
    def find_all(options = {})
      construct_query(options).all
    end

    # @see OrmAdapter::Base#create!
    def create!(attributes = {})
      own_attributes, associated_children = split_attributes(attributes)
      return klass.create(own_attributes) if associated_children.empty?
      klass.db.transaction do
        object = klass.create(own_attributes)
        associated_children.each do |association,children|
          children.each{ |child| object.send(association.add_method, child) }
        end
        object
      end
    end

    # @see OrmAdapter::Base#destroy
    def destroy(object)
      object.destroy if valid_object?(object)
    end

    protected

    def split_attributes(attributes)
      own_attributes = attributes.dup
      associated_children = {}
      klass.association_reflections.each do |key,association|
        if association[:type].to_s.end_with?('_to_many')
          associated_children[association] = own_attributes.delete(key) || []
        end
      end
      [own_attributes, associated_children]
    end

    def construct_query(options)
      conditions, order, limit, offset = extract_conditions!(options)
      order = order_clause(order)
      query = klass.where(conditions)
      query = query.order(*order) if order
      query = query.limit(limit) if limit
      query = query.offset(offset) if offset
      query
    end

    def order_clause(order)
      return nil if order.empty?
      order.map{ |pair| ::Sequel.send(pair.last, pair.first) }
    end
  end
end

class Sequel::Model
  plugin :active_model
  extend ::OrmAdapter::ToAdapter
  self::OrmAdapter = ::OrmAdapter::Sequel
end
