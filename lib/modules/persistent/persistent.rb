require 'securerandom'

module RST

  # The Persistent-module injects Store-functions
  # to any Object including it.
  module Persistent

    KEY_LENGTH=8  # Length of Store-IDs

    # Save the object to Store
    def save
    end

    # Remove the object from Store
    def delete
    end

    # Set and return an unique ID
    def id
      @id ||= SecureRandom::hex(KEY_LENGTH)
    end

  end
end
