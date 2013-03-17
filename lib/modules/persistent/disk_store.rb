module RST
  module Persistent

    # #DiskStore is responsible to save an Array of objects
    # persistently to the disk - PStore is used to effort this.
    # @see RST::Persistent::Store
    # @api persistent
    class DiskStore < Store

      attr_reader :filename

      # The first argument is the filename
      # Following args are passed to base-class
      # @example
      #
      #     DiskStore.new('myfile')
      #     DiskStore.new(filename: 'myfile', other_option: '...')
      #
      # @param [String] _filename 
      # @param [Array] args - arguments passed to the super-class
      def initialize(_filename='store.data',args={})
        @filename = _filename
        super(args)
      end

      # @return [String] full path of PStore-file
      def path
        @store.path
      end

      # @todo This is bad for performance and memory - refactor!
      # @return [Array]
      def all
        _all = []
        @store.transaction(true) do |s|
          s.roots.each do |_r|
            _all << s[_r]
          end
        end
        _all
      end

      # Delete the store
      def delete!
        File.unlink(store_path)
      end

      # Find and update or add object to the store.
      # @param [Object] object
      def update_or_add(object)
        @store.transaction do |s|
          s[object.id] = object
        end
      end
     
      private

      # Initialize a PStore-instance
      def setup_backend
        @store = PStore.new(store_path)
      end


      # Determine the store-path from RST::STOREPATH and
      # environment. Creates the path if not exists.
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
        File.join(_dir, filename)
      end

      # @param [Object] object - the object to be removed.
      def remove_object(object)
        @store.transaction do |s|
          s.delete(object.id)
        end
      end
    end

  end
end

