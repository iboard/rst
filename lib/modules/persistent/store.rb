require 'pstore'
require 'store_errors'

module RST

  module Persistent

    # # The abstract Store-base-class
    # 
    # Store provides the interface for all store-able classes
    #
    # @abstract public API-methods should not be overwritten by descendant classes. 
    #  But descendants must overwrite all methods marked as abstract here.
    #
    class Store

      # @group PUBLIC API

      # Sets options-hash and calls the abstract
      # 'setup_backend'-callback
      def initialize(args={})
        @options = {}.merge(args)
        setup_backend
      end

      # Add an object and sync store
      # @param [Persistentable] object - any object including the Persistent-module
      def <<(object)
        update(object)
      end

      # Remove an object from the store
      # @param [Persistentable] object - the object to be removed from store
      # @return [Store] self
      def -(object)
        remove_object(object)
        self
      end

      # @return [Object|nil] the first object in the store or nil if the store is empty.
      def first
        all.first
      end

      # @param [Array|String] ids or id to search
      # @return [nil]    if nothing found
      # @return [Object] if exactly one object found
      # @return [Array]  of objects with matching ids if more than one matched
      def find(*ids)
        flatten all.select { |obj| ids.include?(obj.id) }
      end


      # Create objects and set the object's store-attribute
      # @example
      #
      #   new_object = store.create
      #     MyClass.new(....)
      #   end
      #
      # @return [Persistentable] - the newly created object
      def create
        obj = yield
        obj.store = self
        self << obj
        obj
      end

      # @group ABSTRACT METHODS TO BE OVERWRITTEN IN DESCENDANTS

      # @return Enumerable
      # @abstract Overwrite in descendants thus it returns an Enumerable of all objects in the store
      def all
        raise AbstractMethodCallError.new
      end

      # Delete the store
      # @abstract - override this method in descendants thus the store removes all objects.
      def delete!
        raise AbstractMethodCallError.new
      end

      # Find and update or add an object to the store
      # @param [Object] object
      # @abstract - override in other StoreClasses
      def update(object)
        raise AbstractMethodCallError.new
      end

      # @endgroup
      
      private

      # @group PRIVATE API
      
      # Flatten the result of a select
      # @param [Array] result
      # @return [Array] if result contains more than one element
      # @return [Object] if result contains exactly one element
      # @return [nil] if result is empty
      def flatten result
        if result.count == 1
          result.first
        elsif result.nil? || result.empty?
          nil
        else
          result
        end
      end

      # @group ABSTRACT METHODS TO BE OVERWRITTEN IN DESCENDANTS

      # callback called from initializer. Aimed to initialize the
      # objects-array, PStore, database-connection,...
      # @abstract - Overwrite in descendants thus they initialize the store.
      def setup_backend
        raise AbstractMethodCallError.new
      end

      # Make sure the current state of objects is stored
      # @abstract - Overwrite in descendants thus every object gets persistently stored.
      def sync_store
        raise AbstractMethodCallError.new
      end

      # @param [Object] object
      # @abstract - override in concrete StoreClasses
      def remove_object(object)
        raise AbstractMethodCallError.new
      end

    end

  end

end
