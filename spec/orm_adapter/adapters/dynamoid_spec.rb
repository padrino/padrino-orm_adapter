if !defined?(Dynamoid)
  puts "** require 'dynamoid' to run the specs in #{__FILE__}"
else
  require 'fake_dynamo'
  require 'fileutils'

  module FakeDynamo
    class Server
      def pp(*); end
      def puts(*); end
    end

    class Storage
      def initialize
        delete_db
        init_db
      end
    end
  end

  data_file = File.join(Dir.mktmpdir, "data.fdb")
  FileUtils.touch(data_file)
  FileUtils.chmod(0777, data_file)

  FakeDynamo::Storage.db_path = data_file
  FakeDynamo::Storage.instance.load_aof

  dynamo_thread = Thread.new do
    FakeDynamo::Server.run!(port: 4567, bind: 'localhost') do |server|
      if server.respond_to?('config') && server.config.respond_to?('[]=')
        server.config[:AccessLog] = []
      end
    end
  end

  at_exit { 
    FakeDynamo::Storage.instance.shutdown
    dynamo_thread.exit
  }

  require 'aws-sdk'

  AWS.config({
    :access_key_id => 'abcd',
    :secret_access_key => 'efgh',
    :dynamo_db_endpoint => 'localhost',
    :dynamo_db_port => 4567,
    :use_ssl => false
  })

  sleep 1

  Dynamoid.configure do |config|
    config.adapter   = "aws_sdk"
    config.namespace = "orm_adapter-dynamoid_test"
    config.logger    = Logger.new($stdout)
    config.logger.level = Logger::ERROR
    config.warn_on_scan = false
  end

  class User
    include Dynamoid::Document
    field :name
    field :rating
    has_many :notes
  end

  class Note
    include Dynamoid::Document
    field :body, :default => "made by orm"
    belongs_to :owner, :class => User
  end

  User.create_table(:table_name => User.table_name)
  Note.create_table(:table_name => Note.table_name)

  describe Dynamoid::Document::OrmAdapter do
    before do
      User.all.each(&:destroy)
      Note.all.each(&:destroy)
    end

    it_should_behave_like "example app with orm_adapter" do
      let(:nonexistent_id_error) { Dynamoid::Errors::DocumentNotFound }
      let(:unknown_attribute_error) { NoMethodError }
      let(:user_class) { User }
      let(:note_class) { Note }
    end
  end
end
