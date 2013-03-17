require_relative '../spec_helper'

describe "Exceptions" do

  class MyDummyClass
    def implemented
      not_implemented
    end

    def not_implemented
      raise AbstractMethodCallError.new
    end
  end

  describe AbstractMethodCallError do

    it '.message should include backtrace-information' do
      dummy = MyDummyClass.new
      expect{ dummy.implemented }.to raise_error(
        AbstractMethodCallError, 
        /.*Please define.*not_implemented.*Called from\:.*implemented.*/
      )
    end

  end

end
