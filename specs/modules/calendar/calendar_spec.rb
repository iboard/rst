require_relative '../../spec_helper'

describe 'Calendar module:' do

  context 'Calendar Class' do

    it 'should define a start and ending date' do
      calendar = Calendar::Calendar.new( Date.today, Date.today-42.years )
      calendar.start_date.should == Date.today
      calendar.end_date.should == Date.today-42.years
    end

    it 'should initialize with strings' do
      calendar = Calendar::Calendar.new( '31. Aug. 1964', '12. Mar. 2013' )
      calendar.start_date.year.should == 1964
      calendar.end_date.year.should == 2013
    end

    it 'should return spanned days' do
      calendar = Calendar::Calendar.new('31. 8. 1964', '2014-08-31')
      (calendar.span/1.year).round.should == 50
    end

    it 'should list week days' do
      calendar = Calendar::Calendar.new('31. 8. 1964', '1964-09-02')
      calendar.list_days.should == <<-EOT
        Mon, Aug 31 1964
        Tue, Sep 01 1964
        Wed, Sep 02 1964
        EOT
        .gsub(/^\s*/, '').strip
    end

    it 'should interpret today as argument' do
      calendar = Calendar::Calendar.new('1.1.1970', 'today')
      calendar.end_date.should == Date.today
    end

    it 'should default to ´today´ if one date is missing' do
      cend  = Calendar::Calendar.new('today')
      cfrom = Calendar::Calendar.new(nil,'today')
      cend.end_date    == Date.today
      cfrom.start_date == Date.today
    end

  end
end


