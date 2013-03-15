module RST
  module Persistent

    # #DiskStore is responsible to save an Array of objects
    # persistently to the disk - We're using PStore to effort this.
    # @see RST::Persistent::Store
    class DiskStore < Store

      private

      # Initialize a PStore-instance
      def setup_backend
        @store = PStore.new(store_path)
        @objects = @store.transaction do |s|
          s[:objects] || []
        end
      end


      # Determine the store-path from RST::STOREPATH and
      # environment.
      #
      # @example
      #     .../data/development/store.data
      # 
      # @return [String] 
      def store_path
        prefix = ENV['RST_DATA'] || RST::STOREPATH
        env = ENV['RST_ENV'] || 'development'
        _dir = File.join( prefix, env )
        FileUtils.mkdir_p(_dir)
        File.join(_dir, 'store.data')
      end

      # Write objects to disk
      def sync_store
        @store.transaction { |s| s[:objects] = @objects }
      end
    end

  end
end

