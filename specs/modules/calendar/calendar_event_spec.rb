require_relative '../../spec_helper'
require 'calendar_event'

describe Calendar::CalendarEvent do

  before do
    @event = Calendar::CalendarEvent.new('1964-08-31', 'Geburtstag Andi')
  end

  it 'should initialize with a date and a label' do
    @event.should be_scheduled
    @event.event_date.should == Date.new(1964,8,31)
  end

  it 'should output the label as event´s headline' do
    @event.event_headline.should == 'Geburtstag Andi'
  end

end
