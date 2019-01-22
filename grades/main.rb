=begin
https://github.com/atipugin/telegram-bot-ruby
https://www.seleniumhq.org

ToDo
-create functions
-"driver.quit" with wait condition
-send message if no new grades and its in the evening ()
=end
require "selenium-webdriver"
require_relative 'config'
require 'rubygems'
require 'telegram/bot'

token = Config::TOKEN

#Chrome browser instantiation
puts "Browser starten"
driver = Selenium::WebDriver.for :chrome
 
##LOGIN
puts "Einloggen"
#Loading the  URL
driver.navigate.to Config::URL
 
#Typing the UserName
userName = driver.find_element(:id, "asdf")
userName.send_keys Config::USERNAME

#Typing the password
userName = driver.find_element(:id, "fdsa")
userName.send_keys Config::PASSWORD

#Clicking on the Submit Button
SubmitButton = driver.find_element(:id, "loginForm:login")
SubmitButton.click

##Navigate to correct page
puts "Navigiere"
#logedin
pVerwaltung = driver.find_element(:link_text, "Prüfungsverwaltung")
pVerwaltung.click

notenspiegel = driver.find_element(:link_text, "Notenspiegel")
notenspiegel.click

bachleor = driver.find_element(:css, "#wrapper > div.divcontent > div.content > form > ul > li > a:nth-child(2)")
bachleor.click

#noten auswerten
puts "Noten auslesen"
table = driver.find_elements(:xpath, "//*[@id=\"wrapper\"]/div[5]/div[2]/form/table[2]/tbody/tr")


posTabelle = []
table[2..18].each do |row|
    values = row.find_elements(:xpath, "td")
    tempArray = []
    values.each {|cell| tempArray.push(cell.text)}
    puts "#{tempArray}"
    posTabelle.push(tempArray)
end

puts "Neue Noten Senden, falls neue da"
posTabelle.each do |row| 
    if(row[2] == "WS 18/19" &&  row[3] != "")
        Telegram::Bot::Client.run(token) do |bot|
            bot.api.send_message(chat_id: 69127513, text: "#{row}")
        end
    end
end

##berechne Durchschnitt
tempECTS = 0.0
average = 0.0
average = posTabelle.reduce(average) do |ave, row|
    if( row[3]!= "" && row[0]!= "2000")
        tempECTS += row[5].to_f
        puts "#{row[3]}*#{row[5]}"
        puts ave
        ave += row[3].to_f * row[5].to_f
        ave
    end
    ave
end
puts "Average: #{average/tempECTS}"
puts average/tempECTS

driver.quit

