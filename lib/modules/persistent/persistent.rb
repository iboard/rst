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
  module Persistent

    KEY_LENGTH=8  # Length of Store-IDs

    # The interface for persistent-able objects
    module Persistentable

      # Save the object to Store
      def save
        store.update_or_add(self)
      end

      # Remove the object from Store
      def delete
        self.store -= self
      end

      # If the object doesn't provide an id-method
      # define one
      unless respond_to?(:id)
        # Set and return an unique ID
        def id
          @id ||= SecureRandom::hex(KEY_LENGTH)
        end
      end

      # Remember the store an object belongs to
      # @param [Store]
      def store=(store)
        @store = store
      end

      # Getter for store
      # @return [Store]
      def store
        @store
      end

    end

  end
end
