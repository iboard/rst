# Not sure if this is a bug. 
# Anyhow, PStore works only if the two methods are defined for Muttex.
class Mutex
  if  RUBY_VERSION >= "1.9"
    def marshal_dump
      []
    end

    def marshal_load array
      # do nothing
    end
  end
end

