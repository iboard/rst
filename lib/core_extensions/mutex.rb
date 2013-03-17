# Not sure if this is a bug. 
# Anyhow, PStore works only if the two methods are defined for Muttex.
# @see Persistent::DiskStore
class Mutex
  if  RUBY_VERSION >= "1.9"
    #:nodoc
    def marshal_dump
      []
    end

    #:nodoc
    def marshal_load array
      # do nothing
    end
  end
end

