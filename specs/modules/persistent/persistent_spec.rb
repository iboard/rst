require_relative '../../spec_helper'
require 'ostruct'

describe Persistent do

  # Some class to test with Persistentable API
  class Something < Struct.new :name
    include Persistent::Persistentable
  end

  describe 'Abstract Store' do

    it 'should raise an exception if setup_store is not overwritten' do
      expect { Persistent::Store.new }.to raise_error( AbstractMethodCallError )
    end

    describe 'if setup_store is overwritten but no other abstract method' do

      # define a dummy-store
      class Dummy < Persistent::Store
        def setup_backend
          @objects = []
        end
      end

      it 'should raise an exceptions if abstract methods not overwritten' do
        dummy = Dummy.new
        expect { dummy.all }.to raise_error( AbstractMethodCallError )
        expect { dummy << Object.new }.to raise_error( AbstractMethodCallError )
        expect { dummy -= Object.new }.to raise_error( AbstractMethodCallError )
        expect { dummy.send(:sync_store) }.to raise_error( AbstractMethodCallError )
      end

      it '.delete! should delete the store' do 
        dummy = Dummy.new
        expect { dummy.delete! }.to raise_error
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

    it '.<< adds objects to the store' do
      @store << OpenStruct.new(name:'Frank')
      @store.first.name.should == 'Frank'
    end

    it '.-= should remove objects from store' do
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

    it '.find(id) should find an object by id' do
      dummy = Something.new 'Completely'
      @store << dummy
      id = dummy.id
      dummy = nil
      reloaded = @store.find id
      reloaded.name.should == 'Completely'
    end

    it '.find(id,id,...) should find more than one object' do
      o1 = Something.new 'Object One'
      o2 = Something.new 'Object Two'
      @store << o1
      @store << o2
      @store.find(o1.id,o2.id).should == [o1,o2]
    end

    it '.find(...) { |found| ... } yields for each object found' do
      obj1= Something.new 'Find me with a block'
      obj2= Something.new 'Find me too'
      @store << obj1
      @store << obj2
      found = []
      @store.find obj1.id,obj2.id do |_obj|
        found << _obj
      end
      found.should == [obj1,obj2]
    end

    it '.find(...) should return nil if nothing is found' do
      @store.find("Nothing").should be_nil
    end

    it '.create should act as a factory for objects' do
      class Storeable < Struct.new(:name)
        include Persistent::Persistentable
      end

      object = @store.create do
        Storeable.new('Remember me')
      end

      object.store.should == @store
      @store.find(object.id).should == object
    end

    it '.delete should delete the store' do 
      expect { @store.delete! }.not_to raise_error
      @store.all.should be_empty
    end

    it 'should not allow to move the store once it\'s set' do
      class DummyKlass
        include Persistent::Persistentable
      end
      store = @store
      store2= @store.class.new
      obj = store.create { DummyKlass.new }
      expect { obj.store=store2 }.to raise_error( NotImplementedError )
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

  describe 'Persistentable' do

    class Klass 
      include Persistent::Persistentable
      attr_accessor :name
      def initialize n
        @name = n
      end
    end

    describe 'in a MemoryStore' do

      before do
        @store = Persistent::MemoryStore.new
      end

      it '.id should be a random hex if object doesn\'t provide an id' do
        obj = Klass.new('dummy')
        obj.id.should =~ /[0-9a-f]{#{Persistent::KEY_LENGTH}}/
      end

      it '.save updates the object in the store' do
        object = @store.create { Klass.new('Slow car') }
        object.name = 'Faaaast bike'
        object.save
        @store.find(object.id).name.should == 'Faaaast bike'
      end

      it '.delete removes the object from it\'s store' do
        object = @store.create { Klass.new('Slow car') }
        object.name = 'Faaaast bike'
        object.delete
        @store.find(object.id).should be_nil
      end
    end

    describe 'in a DiskStore' do

      before do
        @disk = Persistent::DiskStore.new 'teststore'
      end

      it '.save updates the object in the store' do
        object = @disk.create { Klass.new('Slow car') }
        object.name = 'Faaaast bike'
        object.save
        @disk.find(object.id).name.should == 'Faaaast bike'
      end

      it '.delete removes the object from it\'s store' do
        object = @disk.create { Klass.new('Slow car') }
        object.name = 'Faaaast bike'
        object.delete
        @disk.find(object.id).should be_nil
      end

    end

  end

end

