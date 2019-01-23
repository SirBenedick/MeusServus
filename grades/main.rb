=begin
https://github.com/atipugin/telegram-bot-ruby
https://www.seleniumhq.org

=end
require "selenium-webdriver"
require_relative 'config'
require_relative 'helper'
require 'rubygems'
require 'telegram/bot'

token = Config::TOKEN

#Chrome browser instantiation
puts "Browser starten"
driver = Selenium::WebDriver.for :chrome
#Loading the  URL
driver.navigate.to Config::URL

Helper.login(driver)
Helper.navigate(driver)
posTabelle = Helper.extract(driver)
driver.quit

Helper.sendNewGrades(posTabelle, Config::TOKEN)

