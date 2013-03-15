module RST

  module Persistent

    # # MemoryStore 
    # doesn't really store the objects but holds them in
    # memory, in a simple Array. Perfect for testing
    class MemoryStore < Store

      private

      # Initialize an empty array as an in-memory-store
      def setup_backend
        @objects = []
      end

    end
  end
end

