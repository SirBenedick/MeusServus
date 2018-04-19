import requests
from datetime import datetime, timedelta
import json
from pprint import pprint
import telepot

config = json.load(open('private/config.json'))
BOT_TOKEN = config['telegram']['token']
VALID_USER = int(config['telegram']['account'])
UWAPI = config['uw']['apikey']
LOCATION = config['uw']['location']

bot = telepot.Bot(BOT_TOKEN)

URL_TEMPLATE = "http://api.wunderground.com/api/{}/forecast/q/{}.json".format(UWAPI,LOCATION)
r = requests.get(URL_TEMPLATE)
data = r.json()
mmRain = data['forecast']['simpleforecast']['forecastday'][0]['qpf_day']['mm']

if((mmRain == 0) or str(mmRain)=="None"):
    msg = "Rise and shine.\nIt aint gonna rain today."
    print(msg)
    bot.sendMessage(VALID_USER, msg)
else:
    msg ="DAMN Daniel, pack that raincoat: {} mm".format(mmRain)
    print(msg)
    bot.sendMessage(VALID_USER, msg)
