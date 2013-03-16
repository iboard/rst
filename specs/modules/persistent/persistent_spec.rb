require_relative '../../spec_helper'
require 'ostruct'

describe Persistent do

  class Something < Struct.new :name
    include Persistent::Persistentable
  end

  describe 'Abstract Store' do

    it 'should raise an exception if setup_store is not overwritten' do
      expect { Persistent::Store.new }.to raise_error( AbstractMethodCallError )
    end

    describe 'if setup_store is overwritten but no other abstract method' do
      before do
        class Dummy < Persistent::Store
          def setup_backend
            @objects = []
          end
        end
      end

      it 'should raise an exceptions if abstract methods not overwritten' do
        dummy = Dummy.new
        expect { dummy.all }.to raise_error( AbstractMethodCallError )
        expect { dummy << Object.new }.to raise_error( AbstractMethodCallError )
        expect { dummy -= Object.new }.to raise_error( AbstractMethodCallError )
      end

      it 'should delete the store' do 
        dummy = Dummy.new
        expect { dummy.delete! }.not_to raise_error
      end
    end
  end

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

    it 'should remove objects from store' do
      jimi  = Something.new('Jimi Hendrix')
      frank = Something.new('Frank Zappa')
      hansi = Something.new('Hansi Hinterseer')
      [jimi,frank,hansi].each { |m| @store << m }
      @store.all.should == [jimi,frank,hansi]
      @store -= hansi
      @store.all.should == [jimi, frank]
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

    it 'should return nil if nothing is found' do
      @store.find("Nothing").should be_nil
    end

  end

  describe 'DiskStore' do
     
    before do
      @store = Persistent::DiskStore.new('hardstore.data')
    end
    
    it '.delete! should remove the file' do
      @store << OpenStruct.new(id: 'Hello')
      File.exist?(@store.path).should be_true
      @store.delete!
      File.exist?(@store.path).should be_false
    end

    it '.<< should add an object and store it to disk' do
      object = OpenStruct.new id: nil, name: 'HardStore'
      @store << object
      another_store =  Persistent::DiskStore.new('hardstore.data')
      reloaded = another_store.find object.id
      reloaded.name.should == 'HardStore'
    end

    it 'should remove objects from store' do
      @store.delete!
      jimi  = Something.new('Jimi Hendrix')
      frank = Something.new('Frank Zappa')
      hansi = Something.new('Hansi Hinterseer')
      [jimi,frank,hansi].each { |m| @store << m }
      @store.all.should == [jimi,frank,hansi]
      @store -= hansi
      @store.all.should == [jimi, frank]
    end

    it '.<< should update existing objects rather than add new objects' do
      @store.delete!
      @store << object = OpenStruct.new( id: '1', name: 'HardStore' )
      @store.all.count.should == 1
      object[:name] = 'SoftStore'
      @store << object
      @store.all.count.should == 1
      @store.find('1')[:name].should == 'SoftStore'
    end
  end

end
