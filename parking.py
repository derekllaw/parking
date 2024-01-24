# print Cambridge car park spaces
import requests
import datetime

api_base = 'https://smartcambridge.org/api/v1/parking/'
api_token = 'cb9e13991b6d3716b2a47fda106ad8d87bacff94'

# fetch list of parking ids
response  = requests.get(api_base,headers={ 'Authorization': f'Token {api_token}'})
park_list = response.json()['parking_list']

for parking_type in ['car_park', 'park_and_ride']:
    date = ""
    for park in park_list:
        if park['parking_type'] == parking_type:
            api_latest = f'{api_base}/latest/{park["parking_id"]}/'

            response = requests.get(api_latest,headers={ 'Authorization': f'Token {api_token}'})
            data = response.json()

            new_date = data['date']
            if new_date!= date:
                date = new_date
                print_date = datetime.datetime.fromisoformat(date)
                print(print_date.strftime('%d %b %Y %H:%M'))

            free = data["spaces_free"]
            capacity = data["spaces_capacity"]

            print(f'{park["parking_name"]} {free} spaces, ({(capacity-free)/capacity:.0%} full)')
