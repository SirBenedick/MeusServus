=begin
https://github.com/atipugin/telegram-bot-ruby
https://www.seleniumhq.org

ToDo
-->check time hour and Minutes, not just hour
=end
require "selenium-webdriver"
require_relative "config"
require_relative "helper"
require "rubygems"
require "telegram/bot"

token = Config::TOKEN

#Chrome browser instantiation
puts "Browser starten"
options = Selenium::WebDriver::Chrome::Options.new
options.add_argument("--headless")
driver = Selenium::WebDriver.for :chrome, options: options
#Loading the  URL
driver.navigate.to Config::URL

Helper.login(driver)
Helper.navigate(driver)
posTabelle = Helper.extract(driver)
driver.quit

Helper.sendNewGrades(posTabelle, Config::TOKEN)
# puts "New Average: #{Helper.calculateAverage(posTabelle)}"
