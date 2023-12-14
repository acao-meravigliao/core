#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require File.join(File.dirname(__FILE__), '../..', 'spec_helper')

#
# 4 locations
#
describe 'Person can have different locations and' do

  before(:each) do
    @p = Factory.create(:person_test)
    @location = 'Springfield, Illinois'
    @no_where_location = 'mars earth sun'
  end

  it 'should set and avoid to reinsert the default location' do
    @p.locations.length.should == 0
    @p.add_default_location(@location)
    @p.locations.length.should == 1
    lambda { @p.add_default_location(@location)}.should raise_error(RuntimeError)
  end


  it 'should set and avoid to reinsert the birth location' do
    @p.locations.length.should == 0
    @p.add_birth_location(@location)
    @p.locations.length.should == 1
    lambda { @p.add_birth_location(@location+', Fifth Avenue')}.should raise_error(RuntimeError)
  end

  it 'should set all the locations' do
    @p.locations.length.should == 0
    @p.add_default_location(@location)
    @p.locations.length.should == 1
    @p.add_birth_location(@location)
    @p.locations.length.should == 2
  end

  it 'should permit to add the same locations when not using methods' do # Mah ...
    @p.locations.length.should == 0
    @p.add_default_location(@location)
    @p.locations.length.should == 1
    @p.locations << Ygg::Core::Location.new_for(@location)
    @p.locations.length.should == 2
  end

  it 'should not add an not resolvable location as default location' do
    @p.locations.length.should == 0
    @p.add_default_location(@no_where_location)
    @p.locations.length.should == 0
  end

  it 'should not add an not resolvable location as birth location' do
    @p.locations.length.should == 0
    @p.add_birth_location(@no_where_location)
    @p.locations.length.should == 0
  end
end
