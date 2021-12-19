require './lib/toggle'

Given(/^feature "(.*?)" is (.*?)$/) do |feature, value|
  Toggle.turn(feature, value == 'on')
end
