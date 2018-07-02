require 'rails/generators'
require 'rails/generators/base'
require 'rails/generators/active_record'

module RapSheetParser
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration

      source_root File.expand_path("../templates", __FILE__)

      def create_migrations
        Dir["#{self.class.source_root}/migrations/*.rb"].sort.each do |filepath|
          name = File.basename(filepath)
          migration_template "migrations/#{name}", "db/migrate/#{name}", skip: true
          sleep 1
        end
      end
    end
  end
end
