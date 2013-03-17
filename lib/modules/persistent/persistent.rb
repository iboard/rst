require 'securerandom'
require 'fileutils'

module RST

  # The Persistent-module injects Store-functions
  # to any Object including it.
  # @api persistent
  # @see [Store]
  # @example
  #
  #   store = MemoryStore.new
  #   object= store.create { PersistentableObject.new }
  #   ...modify object ...
  #   object.save
  #
  #   object = store.find(object.id)
  #   object.delete
  #
  module Persistent

    KEY_LENGTH=42  # Length of Store-IDs

    # The interface for persistent-able objects
    module Persistentable

      attr_reader :store # @see Persistent::Store

      # Save the object to Store
      def save
        store.update(self)
      end

      # Remove the object from Store
      def delete
        self.store -= self
      end

      # If the object doesn't provide an id-method
      # define one
      unless respond_to?(:id)
        # Return an unique ID (create one if not exists yet)
        # @return [String]
        # @see KEY_LENGTH
        def id
          @id ||= SecureRandom::hex(KEY_LENGTH)
        end
      end

      # Setter for store-attribute
      # @param [Store] store
      def store=(store)
        move_store(store)
      end

      private

      # Move the object to another store
      # @abstract - Moving is not implemented yet, though. The method sets the store-attribute if not set already.
      def move_store store
        if @store && @store != store
          raise NotImplementedError.new('An object can\'t be moved to another store')
        elsif @store == store
          self
        else
          @store = store
        end
      end
    end

  end
end
