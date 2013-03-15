require_relative '../../spec_helper'
require 'ostruct'

describe Persistent do

  describe 'Abstract Store' do

    it 'should raise an exception if setup_store is not overwritten' do
      expect { s = Persistent::Store.new }.to raise_error( AbstractMethodCallError )
    end

  end

  describe 'MemoryStore' do

    class Something < Struct.new :name
      include Persistent
    end

    before do
      @store = Persistent::MemoryStore.new
    end

    it 'should initialize an in-memory store' do
      @store.all.should be_empty
    end

    it 'should be able to add and retrieve from store' do
      @store << OpenStruct.new(name:'Frank')
      @store.first.name.should == 'Frank'
    end

    it 'should have persistence functions' do
      @store.respond_to?(:find).should be_true
      dummy = Something.new
      dummy.respond_to?(:save).should be_true
      dummy.respond_to?(:delete).should be_true
      dummy.respond_to?(:id).should be_true
    end

    it 'should persist an object' do
      dummy = Something.new 'different'
      @store << dummy
      @store.all.first.name.should == 'different'
    end

    it 'should find an object by id' do
      dummy = Something.new 'Completely'
      @store << dummy
      id = dummy.id
      dummy = nil
      reloaded = @store.find id
      reloaded.name.should == 'Completely'
    end

    it 'should find more than one object with find' do
      o1 = Something.new 'Object One'
      o2 = Something.new 'Object Two'
      @store << o1
      @store << o2
      @store.find(o1.id,o2.id).should == [o1,o2]
    end

  end

  describe 'DiskStore' do
     
    before do
      @store = Persistent::DiskStore.new
    end

    it 'should store an object to disk' do
      object = OpenStruct.new name: 'HardStore'
      @store << object
      another_store =  Persistent::DiskStore.new
      reloaded = another_store.find object.id
      reloaded.name.should == 'HardStore'
    end
  end

end
