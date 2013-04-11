require_relative '../../spec_helper'

describe CalendarHelper do

  include CalendarHelper

  describe '.parse_date_param(string) should interpret' do
    before do
      @today = Date.today
    end

    it 'interprets [-]1d' do
      parse_date_param('1d').to_s.should == (@today+1).to_s
      parse_date_param('-1d').to_s.should == (@today-1).to_s
    end

    it 'interprets [-]1w' do
      parse_date_param('1w').to_s.should == (@today+7).to_s
      parse_date_param('-1w').to_s.should == (@today-7).to_s
    end

    it 'interprets [-]1m' do
      parse_date_param('1m').month.should == (@today+31).month
      parse_date_param('-1m').month.should == (@today-31).month
    end

    it 'interprets \'today\'' do
      parse_date_param('today').should == Date.today
    end

    it 'should throws an ArgumentError if string can\'t be parsed' do
      expect { parse_date_param('dummy') }.to raise_error ArgumentError
    end
  end
end

