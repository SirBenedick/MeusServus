module Helper

    def Helper.login(driver)
        ##LOGIN
        puts "Einloggen"
        #Typing the UserName
        userName = driver.find_element(:id, "asdf")
        userName.send_keys Config::USERNAME
    
        #Typing the password
        userName = driver.find_element(:id, "fdsa")
        userName.send_keys Config::PASSWORD
    
        #Clicking on the Submit Button
        submitButton = driver.find_element(:id, "loginForm:login")
        submitButton.click
    end

    def Helper.navigate(driver)
        ##Navigate to correct page
        puts "Navigiere"
        #logedin
        pVerwaltung = driver.find_element(:link_text, "Prüfungsverwaltung")
        pVerwaltung.click
    
        notenspiegel = driver.find_element(:link_text, "Notenspiegel")
        notenspiegel.click
    
        bachleor = driver.find_element(:css, "#wrapper > div.divcontent > div.content > form > ul > li > a:nth-child(2)")
        bachleor.click
    end

    def Helper.extract(driver)
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
        puts "posTabelleLength: #{posTabelle.length}"
        posTabelle
    end

    def Helper.sendNewGrades(posTabelle, token)
        puts "Neue Noten Senden, falls neue da"
        file_name = "oldGrads.txt"
        oldGrades = File.read(file_name).split("-")
        Telegram::Bot::Client.run(token) do |bot|
            sendNewGrade = false
            posTabelle.each do |row| 
                if(row[3] != "" && !(oldGrades.include? row[0]))
                        puts "Neue Note wird verschickt: #{row[1]}"
                        bot.api.send_message(chat_id: Config::TELEGRAMACCOUNT, text: "#{row}")
                    oldGrades.push(row[0])
                    sendNewGrade = true
                end
            end
            newOut = oldGrades.join("-")
            File.write(file_name, newOut)
            
            average = Helper.calculateAverage(posTabelle)
            if sendNewGrade
                    bot.api.send_message(chat_id: Config::TELEGRAMACCOUNT, text: "Neuer Durchschnitt: #{average}")
            elsif !sendNewGrade && Time.now.hour == 20
                    bot.api.send_message(chat_id: Config::TELEGRAMACCOUNT, text: "Keine neuen Noten. \n Durchschnitt: #{average}")
            end
        end
    end
    
    
    def Helper.calculateAverage(posTabelle)
        puts "Calculating Average"
        allECTS = 0.0
        average = posTabelle.reduce(0) do |ave, row|
            eachGrade = row[3].gsub(",",".").to_f
            eachECTS = row[5].gsub(",",".").to_f
            if( eachGrade != 0.0 && row[0]!= "2000")
                allECTS += eachECTS
                puts "Calculating average for #{row[1]}: #{eachGrade}*#{eachECTS}"
                ave += eachGrade * eachECTS
            end
            ave
        end
        puts "New Average: #{average/allECTS}"
        average/allECTS
    end
end