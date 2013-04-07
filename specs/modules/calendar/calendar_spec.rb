require_relative '../../spec_helper'

describe 'Calendar module:' do

  describe 'Calendar Class' do

    it '.new(name,from,to) should initialize with Date-objects' do
      calendar = Calendar::Calendar.new( 'noname', Date.today, Date.today-42.years )
      calendar.start_date.should == Date.today
      calendar.end_date.should == Date.today-42.years
    end

    it '.new(name,str_from,str_to) should initialize with strings' do
      calendar = Calendar::Calendar.new('dob', '31. Aug. 1964', '12. Mar. 2013' )
      calendar.start_date.year.should == 1964
      calendar.end_date.year.should == 2013
    end

    it '.span should return number of days between start and end' do
      calendar = Calendar::Calendar.new('dob','31. 8. 1964', '2014-08-31')
      (calendar.span/1.year).round.should == 50
    end

    it '.list_days(from,to,true) should list week days' do
      calendar = Calendar::Calendar.new('dob','31. 8. 1964', '1964-09-02')
      calendar.list_days('31.8.1964','1964-09-02',true).join("\n").should =~ /Mon, Aug 31 1964/
      calendar.list_days('31.8.1964','1964-09-02',true).join("\n").should =~ /Tue, Sep 01 1964/
      calendar.list_days('31.8.1964','1964-09-02',true).join("\n").should =~ /Wed, Sep 02 1964/
    end

    it '.list_days(from,to,true) should display lines with entries if empty==true (bugfix)' do
      calendar = Calendar::Calendar.new('dob','31. 8. 1964', '1964-09-02')
      calendar << Calendar::CalendarEvent.new('31.8.1964', 'Andi Altendorfer')
      calendar.list_days('31.8.1964','1964-09-02',true).join("\n").should =~ /Mon, Aug 31 1964: Andi Altendorfer/
    end

    it '.new(name,string,string) should interpret today as argument' do
      calendar = Calendar::Calendar.new('dob','1.1.1970', 'today')
      calendar.end_date.should == Date.today
    end

    it '.new(name,nil,string) should default to \'today\' if an argument is missing' do
      cend  = Calendar::Calendar.new('dob','today')
      cfrom = Calendar::Calendar.new('dob',nil,'today')
      cend.end_date    == Date.today
      cfrom.start_date == Date.today
    end

    it '.new(name, string) should interpret -e 1w as today+1week' do
      today = Date.today
      Calendar::Calendar.new(nil,'1d').start_date.to_s.should == (today+1).to_s
      Calendar::Calendar.new(nil,'1w').start_date.to_s.should == (today+7).to_s
      Calendar::Calendar.new(nil,'1m').start_date.month.should == (today+31).month
      expect { Calendar::CalendarEvent.new('1x','dummy') }.to raise_error RuntimeError
    end

    it '.form=, .to=, setter method for :from, and :to should be defined' do
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

    it '.to_text(name,from,to) should output a pretty formatted calendar' do
      cal = Calendar::Calendar.new('Formatted','1.4.2013', '30.4.2013')
      ev1 = Calendar::CalendarEvent.new('1.4.2013','Event 1')
      ev2 = Calendar::CalendarEvent.new('20.4.2013','Event 2')
      cal << ev1
      cal << ev2
      cal.to_text('1.4.2013','30.4.2013').strip.should == <<-EOT
                April 2013        EVENTS:
           Su Mo Tu We Th Fr Sa   Mon, Apr 01 2013: Event 1
               1  2  3  4  5  6   Sat, Apr 20 2013: Event 2
            7  8  9 10 11 12 13
           14 15 16 17 18 19 20
           21 22 23 24 25 26 27
           28 29 30
      EOT
      .gsub(/^           /,'').strip
    end

  end

  describe 'Eventable module' do

    class TestObject 
      prepend Calendar::Eventable
    end

    before do
      @obj = TestObject.new
    end

    it '.event_date - should be injected to the object' do
      @obj.event_date == nil
    end

    it '.scheduled? should return true if the object is scheduled' do
      @obj.should_not be_scheduled
    end

    it '.schedule!(date) should schedule the object' do
      @obj.schedule! Date.today
      @obj.should be_scheduled
    end

    it '.event_headline() should respond with a simple string representation' do
      @obj.event_headline.should == @obj.inspect
    end

    it '.event_headline() should be overwritten' do
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

      it '.list_days(start_on,end_on,show_empty,show_ids=false) shows entries between start_on and end_on' do
        @calendar << TestMeeting.new('Frank').schedule!('2.1.2013')
        @calendar << TestMeeting.new('Zappa').schedule!('5.1.2013')
        @calendar.list_days.join("\n").should =~ /Wed, Jan 02 2013\: MEETING with Frank/
        @calendar.list_days.join("\n").should =~ /Sat, Jan 05 2013\: MEETING with Zappa/
      end

      it '.list_days(nil,nil,false,true) show entries with :id and :calendar-name' do
        TestMeeting.send(:include, RST::Persistent::Persistentable)
        meeting = TestMeeting.new('MyMeeting').schedule!(Date.today)
        @calendar << meeting
        @calendar.list_days(nil,nil,false,true).first.should =~ /#{Date.today.strftime(DEFAULT_DATE_FORMAT)}:\n  ([a-f0-9]*) > MEETING with MyMeeting/
      end

      describe '.dump(show_ids=false) calendar-events' do
        before do
          meeting = TestMeeting.new('MyMeeting').schedule!(Date.today)
          @calendar << meeting
        end
        it '(false) plain dump only' do
          @calendar.dump.should =~ /#{Date.today.strftime('%Y-%m-%d')},MEETING with MyMeeting/
        end
        it '(true) dumps with id and calendar' do
          @calendar.dump(true).should =~ /[0-9a-f]{8}\s+dob\s+ "#{Date.today.strftime('%Y-%m-%d')},MEETING with MyMeeting"/
        end
      end
    end
  end

end


