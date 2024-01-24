# print Cambridge car park spaces
import requests
import datetime

#constants
API_BASE = "https://smartcambridge.org/api/v1/parking/"
API_TOKEN = 'cb9e13991b6d3716b2a47fda106ad8d87bacff94'
PARK = "car_park"
RIDE = "park_and_ride"

# fetch list of parking ids
response  = requests.get(API_BASE,headers={ 'Authorization': f'Token {API_TOKEN}'})
if response.status_code != 200:
    print("API error %d" % response.status_code)
else:
    park_list = response.json()["parking_list"]
    count = { PARK: 0, RIDE: 0 }

    for park in park_list:
        count[park["parking_type"]] += 1

    for parking_type in [PARK, RIDE]:
        date = ""
        print('big' if count[parking_type]<5 else 'small')
        for park in park_list:
            if park['parking_type'] == parking_type:
                api_latest = f'{API_BASE}/latest/{park["parking_id"]}/'

                response = requests.get(api_latest,headers={ 'Authorization': f'Token {API_TOKEN}'})
                data = response.json()

                new_date = data['date']
                if new_date!= date:
                    date = new_date
                    print_date = datetime.datetime.fromisoformat(date)
                    print(print_date.strftime('%d %b %Y %H:%M'))

                free = data["spaces_free"]
                capacity = data["spaces_capacity"]

                print(f'{park["parking_name"]} {free} spaces, ({(capacity-free)/capacity:.0%} full)')
