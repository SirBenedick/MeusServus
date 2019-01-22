from lxml import html
import requests
from pprint import pprint
from parsel import Selector
from bs4 import BeautifulSoup
import re
import telepot
import json

config = json.load(open('private/config.json'))
BOT_TOKEN = config['telegram']['token']
VALID_USERS = config['telegram']['account']
bot = telepot.Bot(BOT_TOKEN)

url = "https://www.stw-ma.de/Essen+_+Trinken/Menüpläne/Hochschule+Mannheim.html"
r = requests.get(url)
soup = BeautifulSoup(r.content, 'lxml')

##Menüs
table = soup.find_all("table",attrs={"class": "t1 persistent"})
table += soup.find_all("table",attrs={"class": "t2 persistent"})
menuTableAll = Selector(text=u"""{}""".format(table)).xpath('//tr')
menuList = []
for menu in menuTableAll:
    temp = []
    name = menu.xpath('td[1]/b/text()').extract()

    ingredients = []
    ingredients.append(menu.xpath('td[2]/b/text()').extract_first())
    mealAll = menu.xpath('td[2]/p/span')
    for meal in mealAll:
        ingredient = meal.xpath('text()').extract_first().replace(u'\xa0', u'')
        #print(ingredient)
        ingredients.append(ingredient)
    price = menu.xpath('td[4]/i/text()').extract()
    temp.append(name)
    temp.append(ingredients)
    temp.append(price)
    menuList.append(temp)
#pprint(menuList)
##cleaning list
for i in menuList:
    str = i[1][0]
    str = re.sub(r"[\\ntr ]","",str).strip()
    i[1][0] = str
    #print(str)
#pprint(likes
##output
for menu in menuList:
    name = menu[0][0]
    menuIngriedients = " ".join(menu[1])
    price = menu[2][0]
    msg = """*{}*:\n{}\n*Preis*: {} """.format(name, menuIngriedients, price)
    print(msg)
    for user in VALID_USERS:
        bot.sendMessage(user, msg, parse_mode= 'Markdown')
