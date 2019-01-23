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
        posTabelle
    end

    def Helper.sendNewGrades(posTabelle, token)
        puts "Neue Noten Senden, falls neue da"
        file_name = "oldGrads.txt"
        oldGrades = File.read(file_name).split("-")

        sendNewGrade = false
        posTabelle.each do |row| 
            if(row[3] != "" && !(oldGrades.include? row[0]))
                Telegram::Bot::Client.run(token) do |bot|
                    bot.api.send_message(chat_id: 69127513, text: "#{row}")
                end
                oldGrades.push(row[0])
                sendNewGrade = true
            end
        end
        newOut = oldGrades.join("-")
        File.write(file_name, newOut)
        
        average = Helper.calculateAverage(posTabelle)
        if sendNewGrade
            Telegram::Bot::Client.run(token) do |bot|
                bot.api.send_message(chat_id: 69127513, text: "Neuer Durchschnitt: #{average}")
            end
        elsif !sendNewGrade && Time.now.hour == 20
            Telegram::Bot::Client.run(token) do |bot|
                bot.api.send_message(chat_id: 69127513, text: "Keine neuen Noten. \n Durchschnitt: #{average}")
            end
        end
    end
    
    
    def Helper.calculateAverage(posTabelle)
        ##berechne Durchschnitt
        tempECTS = 0.0
        average = 0.0
        average = posTabelle.reduce(average) do |ave, row|
            if( row[3]!= "" && row[0]!= "2000")
                tempECTS += row[5].to_f
                puts "#{row[3]}*#{row[5]}"
                ave += row[3].to_f * row[5].to_f
                puts "new ave: #{ave}"
                ave
            end
            ave
        end
        average/tempECTS
    end
end