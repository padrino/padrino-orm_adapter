require 'padrino/orm_adapter/base'
require 'padrino/orm_adapter/to_adapter'
require 'padrino/orm_adapter/version'

module Padrino
  module OrmAdapter
    # A collection of registered adapters
    def self.adapters
      @@adapters ||= []
    end
  end
end

require 'padrino/orm_adapter/adapters/active_record' if defined?(ActiveRecord::Base)
require 'padrino/orm_adapter/adapters/data_mapper'   if defined?(DataMapper::Resource)
require 'padrino/orm_adapter/adapters/mongoid'       if defined?(Mongoid::Document)
require 'padrino/orm_adapter/adapters/mongo_mapper'  if defined?(MongoMapper::Document)
require 'padrino/orm_adapter/adapters/sequel'        if defined?(Sequel::Model)
