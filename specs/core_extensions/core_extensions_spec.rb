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

  describe String do
    it 'should respond to blank?' do
      "".should be_blank
      "  ".should be_blank
      "\t".should be_blank
      "x".should_not be_blank
    end
  end
end
