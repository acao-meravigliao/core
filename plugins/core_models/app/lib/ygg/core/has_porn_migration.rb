#
# Copyright (C) 2013-2016, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

module HasPornMigration
  extend ActiveSupport::Concern

  included do
    class_attribute :porn_migration
    self.porn_migration = []
  end

  module ClassMethods
    def inherited(child)
      super
      child.porn_migration = []
    end

    def pm_migrate(debug: 0, dry_run: false)
      pm_apply(diffs: pm_diff(debug: debug), dry_run: dry_run)
    end

    def pm_diff(debug: 0)
      return if !respond_to?(:porn_migration)

      reset_column_information

      schema = pm_export_schema(all_attrs: true)

      diff = []

      porn_migration.each do |mig|
        raise "Definition must be a 2-element array: #{mig.inspect}" if !mig.is_a?(Array) || mig.count != 2

        to = mig[1]

        case mig[0]
        when :must_have_column
          from =  schema[:columns][mig[1][:name].to_sym]

          if !from
            diff << { op: :column_add, column: to }
          else
            changes = {}
            to.each { |key, to_val| changes[key] = [ from[key], to[key] ] if from[key] != to[key] }
            diff << { op: :column_change, name: from[:name], changes: changes } if changes.any?
          end

        when :must_have_index
          matching_idxs = schema[:indexes].select { |x|
            x[:table] == to[:table] &&
            ((x[:columns].is_a?(Array) && to[:columns].is_a?(Array)) ? (x[:columns].sort == to[:columns].sort) : (x[:columns] == to[:columns])) &&
            (!x.has_key?(:where) || x[:where] == to[:where]) &&
            (!x.has_key?(:type) || x[:type] == to[:type])
          }

          if matching_idxs.count == 0
            diff << { op: :index_add, index: to }
          elsif matching_idxs.count == 1
            if matching_idxs.first[:unique] != to[:unique]
              diff << { op: :index_del, name: matching_idxs.first[:name] }
              diff << { op: :index_add, index: to }
            end
          else
            raise "Uh, dunno what to do! #{matching_idxs}"
          end

        when :must_have_fk
          matching_fks = schema[:fks].select { |x|
            x[:to_table] == to[:to_table] &&
            x[:column] == to[:column]
          }

          if matching_fks.count == 0
            diff << { op: :fk_add, fk: to }
          end

        when :must_have_record
          klass = to[:klass].constantize

          rec = klass.find_or_initialize_by(**to[:attrs])

          if rec.new_record?
            rec.save!
            puts "PM: record '#{to[:attrs].inspect}' CREATED!" if debug >= 1
          else
            puts "PM: record '#{to[:attrs].inspect}' OK" if debug > 1
          end
        else
          raise "Definition operand '#{mig[0]}' is not recognized"
        end
      end

      diff
    end

    class DryRun < StandardError ; end
    def pm_apply(diffs:, dry_run: false)
      transaction do
        diffs.each do |diff|
          case diff[:op]
          when :column_add
            column_def = diff[:column].dup
            column_name = column_def.delete(:name)
            column_type = column_def.delete(:type)

            df = column_def.delete(:default_function)
            if df
              column_def[:default] = lambda { df }
            end

            ActiveRecord::Migration.add_column(table_name, column_name, column_type, **column_def)

            reset_column_information

          when :column_change
            column_def = Hash[diff[:changes].map { |k,v| [ k, v[1] ] }]
            new_type = column_def.delete(:type) || columns_hash[diff[:name]].type

            df = column_def.delete(:default_function)
            if df
              column_def[:default] = lambda { df }
            end

            us = column_def.delete(:using)
            us ||= "#{diff[:name]}::#{connection.type_to_sql(new_type)}"

            if us
              new_type = connection.type_to_sql(new_type,
                           limit: column_def[:limit],
                           precision: column_def[:precision],
                           scale: column_def[:scale]) + ' USING ' + us
            else
              new_type = new_type
            end

            ActiveRecord::Migration.change_column(table_name, diff[:name], new_type, **column_def)

            reset_column_information

          when :index_del
            ActiveRecord::Migration.remove_index(table_name, name: diff[:name])

          when :index_add
            idx_def = diff[:index].dup
            idx_columns = idx_def.delete(:columns)
            ActiveRecord::Migration.add_index(table_name, idx_columns, **idx_def)

          when :fk_add
            fk_def = diff[:fk].dup
            fk_to_table = fk_def.delete(:to_table)
            ActiveRecord::Migration.add_foreign_key(table_name, fk_to_table, **fk_def)
          end
        end
        raise DryRun if dry_run
      end
    rescue DryRun
    end

    def pm_export_schema(all_attrs: false, as_rules: false)
      reset_column_information

      schema_columns = Hash[columns_hash.map { |col_name,col|
        sc = {
          name: col_name,
          type: col.type,
          default: col.has_default? ? connection.lookup_cast_type_from_column(col).deserialize(col.default) : nil,
        }

        sc[:limit] = col.limit if all_attrs || col.limit
        sc[:default_function] = col.default_function if all_attrs || !col.default_function.nil?
        sc[:precision] = col.precision if all_attrs || !col.precision.nil?
        sc[:scale] = col.scale if all_attrs || !col.scale.nil?
        sc[:null] = col.null if all_attrs || !col.null.nil?

        [
          col_name.to_sym,
          sc,
        ]
      }]

      schema_indexes = connection.indexes(table_name).map { |x|
        si = {
          columns: x.columns,
          unique: x.unique,
          name: x.name,
        }

        si[:comment] = x.comment if !x.comment.nil?
        si[:where] = x.where if !x.where.nil?

        si
      }

      schema_fks = connection.foreign_keys(table_name).map { |x|
        sfk = {
          to_table: x.to_table,
          column: x.options[:column],
          primary_key: x.options[:primary_key],
          on_delete: x.options[:on_delete],
          on_update: x.options[:on_update],
        }

        sfk
      }

      if as_rules
        schema = []

        schema_columns.each do |col_name,col|
          schema << [ :must_have_column, col ]
        end

        schema_indexes.each do |fk|
          schema << [ :must_have_index, fk ]
        end

        schema_fks.each do |fk|
          schema << [ :must_have_fk, fk ]
        end
      else
        schema = {
          columns: schema_columns,
          indexes: schema_indexes,
          fks: schema_fks,
        }
      end

      schema
    end
  end

  def self.diff_all(debug: 0)
    diff = {}

    all_models.each do |cls|
      puts "Processing class '#{cls}'" if debug >= 1

      subdiff = cls.pm_diff(debug: debug)

      diff[cls.name] = subdiff if subdiff.any?
    end

    diff
  end

  def self.migrate_all(debug: 0, dry_run: false)
    diffs = diff_all(debug: debug)

    ActiveRecord::Base.transaction do
      diffs.each do |table,table_diffs|
        table.constantize.pm_apply(diffs: table_diffs, dry_run: dry_run)
      end

      raise "DryRun" if dry_run
    end

    diffs
  end

  def self.dump
    schema = {}

    all_models.each do |cls|
      schema[cls.name] = cls.pm_export_schema
    end

    schema
  end

  def self.all_models
    Rails.configuration.eager_load_namespaces.each { |x| x.eager_load! }

    ActiveRecord::Base.descendants.select { |x| !x.abstract_class && x.respond_to?(:pm_migrate) }
  end
end

end
end
