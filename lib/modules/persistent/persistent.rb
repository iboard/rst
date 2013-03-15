require 'securerandom'
require 'fileutils'

module RST

  # The Persistent-module injects Store-functions
  # to any Object including it.
  module Persistent

    KEY_LENGTH=8  # Length of Store-IDs

    # The interface for persistent-able objects
    module Persistentable

      # Save the object to Store
      def save
      end

      # Remove the object from Store
      def delete
      end

      # If the object doesn't provide an id-method
      # define one
      unless respond_to?(:id)
        # Set and return an unique ID
        def id
          @id ||= SecureRandom::hex(KEY_LENGTH)
        end
      end

    end

  end
end
