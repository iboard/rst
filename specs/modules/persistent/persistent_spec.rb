require_relative '../../spec_helper'
require 'ostruct'

describe Persistent do

  describe 'MemoryStore' do

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

  end

  describe 'injects store-functions to a class' do

    before do
      @store = Persistent::MemoryStore.new
    end

    class Something < Struct.new :name
      include Persistent
    end

    it 'should have store functions' do
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

  end

  describe 'store it really persistent' do
     
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
