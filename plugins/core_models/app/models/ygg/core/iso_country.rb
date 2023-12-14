#
# Copyright (C) 2013-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

module Ygg
module Core

class IsoCountry < Ygg::PublicModel
  self.table_name = 'core.iso_countries'

  self.porn_migration += [
    [:must_have_column, {:name=>"a2", :type=>:string, :default=>nil, :limit=>2, :null=>false}],
    [:must_have_column, {:name=>"a3", :type=>:string, :default=>nil, :limit=>3, :null=>false}],
    [:must_have_column, {:name=>"number", :type=>:integer, :default=>nil, :limit=>4, :null=>false}],
    [:must_have_column, {:name=>"area_code", :type=>:string, :default=>nil, :limit=>4, :null=>true}],
    [:must_have_column, {:name=>"currency", :type=>:string, :default=>nil, :limit=>40, :null=>true}],
    [:must_have_column, {:name=>"english", :type=>:string, :default=>nil, :limit=>64, :null=>true}],
    [:must_have_column, {:name=>"french", :type=>:string, :default=>nil, :limit=>64, :null=>true}],
    [:must_have_column, {:name=>"spanish", :type=>:string, :default=>nil, :limit=>64, :null=>true}],
    [:must_have_column, {:name=>"italian", :type=>:string, :default=>nil, :limit=>64, :null=>true}],
    [:must_have_column, {:name=>"german", :type=>:string, :default=>nil, :limit=>64, :null=>true}],
    [:must_have_column, {:name=>"dlv_group", :type=>:string, :default=>nil, :limit=>2, :null=>true}],
    [:must_have_column, {:name=>"dlv_days", :type=>:integer, :default=>nil, :limit=>4, :null=>true}],
    [:must_have_column, {:name=>"have_zip", :type=>:boolean, :default=>nil, :null=>false}],
    [:must_have_index, {:columns=>["a2"], :unique=>true, :name=>"core_iso_countries_a2_idx"}],
    [:must_have_index, {:columns=>["a3"], :unique=>true, :name=>"core_iso_countries_a3_idx"}],
  ]
end

end
end
