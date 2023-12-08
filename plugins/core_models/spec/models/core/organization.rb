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

describe 'Organization can have different locations and' do

  before(:each) do
    @org = Factory.create(:organization_test)
    @location = 'Springfield, Illinois'
    @nowhere_location = 'mars earth sun'
  end

  it 'should set and avoid to reinsert the default location' do
    @org.locations.length.should == 0
    @org.add_default_location(@location)
    @org.locations.length.should == 1
    lambda { @org.add_default_location(@location)}.should raise_error(RuntimeError)
  end

  it 'should set and avoid to reinsert the billing location' do
    @org.locations.length.should == 0
    @org.add_billing_location(@location)
    @org.locations.length.should == 1
    lambda { @org.add_billing_location(@location)}.should raise_error(RuntimeError)
  end

  it 'should set and avoid to reinsert the headquarter location' do
    @org.locations.length.should == 0
    @org.add_headquarter_location(@location)
    @org.locations.length.should == 1
    lambda { @org.add_headquarter_location(@location)}.should raise_error(RuntimeError)
  end

  it 'should set all the locations' do
    @org.locations.length.should == 0
    @org.add_default_location(@location)
    @org.locations.length.should == 1
    @org.add_billing_location(@location)
    @org.locations.length.should == 2
    @org.add_headquarter_location(@location)
    @org.locations.length.should == 3
  end

  it 'should permit to add the same locations when not using methods' do # Mah ...
    @org.locations.length.should == 0
    @org.add_default_location(@location)
    @org.locations.length.should == 1
    @org.locations << Ygg::Core::Location.new_for(@location)
    @org.locations.length.should == 2
  end

  it 'should not add an not resolvable location as default location' do
    @org.locations.length.should == 0
    @org.add_default_location(@nowhere_location)
    @org.locations.length.should == 0
  end

  it 'should not add an not resolvable location as headquarter location' do
    @org.locations.length.should == 0
    @org.add_headquarter_location(@nowhere_location)
    @org.locations.length.should == 0
  end

  it 'should not add an not resolvable location as billing location' do
    @org.locations.length.should == 0
    @org.add_billing_location(@nowhere_location)
    @org.locations.length.should == 0
  end
end
