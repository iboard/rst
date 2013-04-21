module RST
  module Persistent

    # #DiskStore is responsible to save an Array of objects
    # persistently to the disk - PStore is used to effort this.
    # @see RST::Persistent::Store
    # @see Mutex
    # @api persistent
    class DiskStore < Store

      # [String] filename - used for PStore (no path! filename only) 
      # @see #store_path
      attr_reader :filename 

      # The first argument is the filename
      # Following args are passed to base-class
      # @example
      #
      #     DiskStore.new('myfile')
      #     DiskStore.new('myfile', other_option: '...')
      #     DiskStore.new( nil, other_option: '...') # use default filename
      # @see DEFAULT_STORE_FILENAME
      # @param [String] _filename 
      # @param [Array] args - arguments passed to the super-class
      def initialize(_filename=DEFAULT_STORE_FILENAME,args={})
        @filename = _filename
        super(args)
      end

      # @return [String] full path of PStore-file
      def path
        store.path
      end

      # @

      # @todo This is bad for performance and memory - refactor!
      # @return [Array]
      def all
        return @all if @all
        @all = []
        store.transaction(true) do |s|
          s.roots.each do |_r|
            @all << s[_r]
          end
        end
        @all
      end

      # Delete the store
      def delete!
        File.unlink(store_path)
      end

      # Find and update or add object to the store.
      # @param [Object] object
      def update(object)
        @all = nil
        store.transaction do |s|
          s[object.id] = object
        end
      end

      private

      # @param [Object] object - the object to be removed.
      def remove_object(object)
        store.transaction do |s|
          s.delete(object.id)
        end
        @all = nil
      end

      # Initialize a PStore-instance
      # @see store_path
      def setup_backend
        @_store = PStore.new(store_path)
      end

      # store-accessor
      def store
        @_store ||= setup_backend
      end


      # Determine the store-path from RST::STOREPATH and
      # environment. Creates the path if not exists.
      #
      # @example
      #     RST_ENV=development
      #     RST_DATA=$HOME/.rst-data
      #
      #     ~/.rst-data/development/store.data
      # 
      # if no environment-variables defined, the defaults will be STOREPATH and 'development'
      # @see STOREPATH
      # @return [String] 
      def store_path
        store_path ||= build_store_path
      end

      # build the path from ENV-vars and create the directory
      # if necessary
      # @return [String] full path of data-file for current environment
      def build_store_path
        prefix = ENV['RST_DATA'] || RST::STOREPATH
        env = ENV['RST_ENV'] || 'development'
        _dir = File.join( prefix, env )
        FileUtils.mkdir_p(_dir)
        File.join(_dir, filename)
      end

    end

  end
end

