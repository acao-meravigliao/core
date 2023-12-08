#
# Copyright (C) 2008-2015, Daniele Orlandi
#
# Author:: Daniele Orlandi <daniele@orlandi.com>
#
# License:: You can redistribute it and/or modify it under the terms of the LICENSE file.
#

require File.join(File.dirname(__FILE__), '../..', 'spec_helper')

describe 'Group' do

  before(:each) do
    @grp = Factory.create(:group_admin)
    @idn = Factory.create(:identity_weak)
  end

  it 'should register identities to itself' do
    @grp.identities.length.should == 0
    @grp.register_identity(@idn)
    @grp.identities.length.should == 1
  end

  it 'should unregister identities to itself' do
    @grp.identities.length.should == 0
    @grp.register_identity(@idn)
    @grp.identities.length.should == 1
    @grp.unregister_identity(@idn)
    @grp.identities.length.should == 0
  end

  it 'should not register nothing but Ygg::Core::Identity model' do
    @grp.identities.length.should == 0

    lambda { @grp.register_identity('test') }.should raise_error(RuntimeError)
    lambda { @grp.register_identity({:id => 1}) }.should raise_error(RuntimeError)
    lambda { @grp.register_identity(Factory.create(:person_test)) }.should raise_error(RuntimeError)

    @grp.identities.length.should == 0
  end

  it 'should not unregister nothing but Ygg::Core::Identity model' do
    @grp.identities.length.should == 0
    @grp.register_identity(@idn)
    @grp.identities.length.should == 1

    lambda { @grp.register_identity('test') }.should raise_error(RuntimeError)
    lambda { @grp.register_identity({:id => 1}) }.should raise_error(RuntimeError)
    lambda { @grp.register_identity(Factory.create(:person_test)) }.should raise_error(RuntimeError)

    @grp.identities.length.should == 1
    @grp.identities[0].qualified.should == @idn.qualified
  end
end
