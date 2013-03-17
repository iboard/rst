module RST

  module Persistent

    # # MemoryStore 
    # doesn't really store the objects but holds them in
    # memory, in a simple Array. Perfect for testing
    # @api persistent
    class MemoryStore < Store

      # @return [Array]
      def all
        @objects || []
      end

      # Find and update or add an object to the store
      # @param [Object] object
      def update(object)
        @objects -= [object]
        @objects << object
      end

      # remove all objects
      def delete!
        @objects = []
      end

      private

      # Initialize an empty array as an in-memory-store
      def setup_backend
        @objects = []
      end

      # @param [Object] object - the object to be removed
      def remove_object(object)
        @objects -= [object]
      end

      # Make sure the current state of objects is stored
      # @abstract - Overwrite in descendants thus every object gets persistently stored.
      def sync_store
        #noop for MemoryStore
      end

    end
  end
end

