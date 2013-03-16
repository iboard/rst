module RST

  module Persistent

    # # MemoryStore 
    # doesn't really store the objects but holds them in
    # memory, in a simple Array. Perfect for testing
    class MemoryStore < Store


      # @return [Array]
      def all
        @objects || []
      end

      private

      # Initialize an empty array as an in-memory-store
      def setup_backend
        @objects = []
      end

      # Find and update or add an object to the store
      # @param [Object] object
      # @abstract - override in other StoreClasses
      def update_or_add(object)
        @objects -= [object]
        @objects << object
      end

      # @param [Object] object
      # @abstract - override in concrete StoreClasses
      def remove_object(object)
        @objects -= [object]
      end
    end
  end
end

