require 'pstore'
require 'store_errors'

module RST

  module Persistent

    # # The abstract Store-base-class
    # 
    # Store provides the interface for all store-able classes
    #
    # ## usage:
    #
    #   Derive a concrete store-class from 'Store' and overwrite the
    #   following methods:
    #
    #   * setup_backend
    #   * sync_store
    #
    # @abstract
    #
    class Store

      # Sets options-hash and calls the abstract
      # 'setup_backend'-callback
      def initialize(args={})
        @options = {}.merge(args)
        setup_backend
      end

      # Add an object and sync store
      # @param [Object] object - object including the Persistent-module
      def <<(object)
        update_or_add(object)
      end

      # @return [Array]
      def all
        raise AbstractMethodCallError.new('Please, overrwrite #{__callee__} in #{self.class.to_s}')
      end

      # @return [Object|nil] the first object in the store
      def first
        all.first
      end

      # @param [Array] ids to search
      # @return [Array] objects with matching ids
      def find(*ids)
        flatten all.select { |obj| ids.include?(obj.id) }
      end

      # Delete the store
      # @abstract - override this for real persistent store-classes
      def delete!
        @objects = []
      end

      private

      # Initialize objects-array from store
      # @abstract
      def setup_backend
        raise AbstractMethodCallError.new("Please override method :setup_backend in class #{self.class.to_s}")
      end

      # Make sure the current state of objects is stored
      # @abstract
      def sync_store
        # RST.logger.warn("Store class #{self.class.to_s} should overwrite method :sync_store" )
      end

      # Flatten the result of an select
      # @param [Array] result
      # @return [Array] if result contains more than one element
      # @return [Object] if result contains exactly one element
      # @return nil if result is empty
      def flatten result
        nil if result.nil? || result.empty?
        if result.count == 1
          result.first
        elsif result.empty?
          nil
        else
          result
        end
      end


      # Find and update or add an object to the store
      # @param [Object] object
      # @abstract - override in other StoreClasses
      def update_or_add(object)
        raise AbstractMethodCallError.new('Please, overrwrite #{__callee__} in #{self.class.to_s}')
      end

    end

  end

end
