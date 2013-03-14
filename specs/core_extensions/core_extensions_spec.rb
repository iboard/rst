require_relative '../spec_helper'

describe "Ruby core-extensions" do

  describe Numeric do
    it 'should support calendar-functions' do
      1.second.should == 1
      1.minute.should == 60.seconds
      1.hour.should   == 60.minutes
      1.day.should    == 24.hours
      1.week.should   == 7.days
      1.month.should  == 30.5.days
      1.year.should   == 365.25.days
    end
  end
end
