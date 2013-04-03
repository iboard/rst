require_relative '../../spec_helper'

describe 'Calendar module:' do

  describe 'Calendar Class' do

    it 'should define a start and ending date' do
      calendar = Calendar::Calendar.new( 'noname', Date.today, Date.today-42.years )
      calendar.start_date.should == Date.today
      calendar.end_date.should == Date.today-42.years
    end

    it 'should initialize with strings' do
      calendar = Calendar::Calendar.new('dob', '31. Aug. 1964', '12. Mar. 2013' )
      calendar.start_date.year.should == 1964
      calendar.end_date.year.should == 2013
    end

    it 'should return spanned days' do
      calendar = Calendar::Calendar.new('dob','31. 8. 1964', '2014-08-31')
      (calendar.span/1.year).round.should == 50
    end

    it 'should list week days' do
      calendar = Calendar::Calendar.new('dob','31. 8. 1964', '1964-09-02')
      calendar.list_days('31.8.1964','1964-09-02',true).join("\n").should =~ /Mon, Aug 31 1964/
      calendar.list_days('31.8.1964','1964-09-02',true).join("\n").should =~ /Tue, Sep 01 1964/
      calendar.list_days('31.8.1964','1964-09-02',true).join("\n").should =~ /Wed, Sep 02 1964/
    end

    it 'should display lines with entries if empty==true (bugfix)' do
      calendar = Calendar::Calendar.new('dob','31. 8. 1964', '1964-09-02')
      calendar << Calendar::CalendarEvent.new('31.8.1964', 'Andi Altendorfer')
      calendar.list_days('31.8.1964','1964-09-02',true).join("\n").should =~ /Mon, Aug 31 1964: Andi Altendorfer/
    end

    it 'should interpret today as argument' do
      calendar = Calendar::Calendar.new('dob','1.1.1970', 'today')
      calendar.end_date.should == Date.today
    end

    it 'should default to ´today´ if one date is missing' do
      cend  = Calendar::Calendar.new('dob','today')
      cfrom = Calendar::Calendar.new('dob',nil,'today')
      cend.end_date    == Date.today
      cfrom.start_date == Date.today
    end

    it 'shoul interpret -e 1w as today+1week' do
      today = Date.today
      Calendar::Calendar.new(nil,'1d').start_date.to_s.should == (today+1).to_s
      Calendar::Calendar.new(nil,'1w').start_date.to_s.should == (today+7).to_s
      Calendar::Calendar.new(nil,'1m').start_date.to_s.should == (today+30.5).to_s
      expect { Calendar::CalendarEvent.new('1x','dummy') }.to raise_error RuntimeError
    end

    it 'should have a setter method for :from, and :to' do
      cal = Calendar::Calendar.new('dob','1.1.1970', '2.1.1970')
      cal.start_date.year.should == 1970
      cal.end_date.year.should == 1970
      cal.from = '31.8.1964'
      cal.to   = '28.8.1969'
      cal.start_date.year.should  == 1964
      cal.end_date.year.should    == 1969
    end

    it '.id should be the name of the calendar' do
      cal = Calendar::Calendar.new('Hurray')
      cal.id.should == 'Hurray'
    end

  end

  describe 'Eventable module' do

    class TestObject 
      prepend Calendar::Eventable
    end

    before do
      @obj = TestObject.new
    end

    it 'should inject the event_date-method' do
      @obj.event_date == nil
    end

    it 'should know if it\'s scheduled' do
      @obj.should_not be_scheduled
    end

    it 'should be schedule-able' do
      @obj.schedule! Date.today
      @obj.should be_scheduled
    end

    it 'should respond to event_headline' do
      @obj.event_headline.should == @obj.inspect
    end

    it 'should allow to overwrite event_headline' do
      class MySpecialObject < Struct.new(:name)
        include Calendar::Eventable
        def event_headline
          "Meeting with: #{self.name}"
        end
      end
      MySpecialObject.new('Johnny').event_headline.should == 'Meeting with: Johnny'
      MySpecialObject.new('Alfred').event_headline.should == 'Meeting with: Alfred'
    end

  end

  describe 'A calendar with event-able objects' do
    class TestMeeting < Struct.new(:name,:date)
      include Calendar::Eventable
      def event_headline
        "MEETING with #{name.to_s}"
      end
    end

    before do
      @calendar = Calendar::Calendar.new('dob','1.1.2013', '7.1.2013')
    end

    describe 'Calendar' do
      it 'should collect event-able objects' do
        @calendar << TestMeeting.new('Frank').schedule!('2.1.2013')
        @calendar << TestMeeting.new('Zappa').schedule!('5.1.2013')
        @calendar.list_days.join("\n").should =~ /Wed, Jan 02 2013\: MEETING with Frank/
        @calendar.list_days.join("\n").should =~ /Sat, Jan 05 2013\: MEETING with Zappa/
      end

    end
  end

end


