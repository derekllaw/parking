""" Tidbyt app to show parking spaces in Cambridge UK Car Parks """

load("render.star", "render")
load("http.star","http")

def render_countdown(count_from,count_to):
    """ Render animated countdown

    Args:
        count_from: capacity
        count_to: spaces

    Returns:
        render sequence
    """
    print("%d %d" % (count_from,count_to))
    countdown = []
    count = int(count_from)
    step = 100
    for _x in range(100):
        countdown.append(render.Text("%d " % count, color="#0F0", font = "CG-pixel-4x5-mono"))
        if count>(count_to + step):
            count -= step
        else:
            step = step//10
        if step>0:
            print("%d %d" % (count,step))
    return render.Sequence(children=countdown)

def render_row(capacity,free,name):
    return render.Row(children = [
        render_countdown(capacity,free),
        render.Marquee(child=render.Text(name,font = "CG-pixel-4x5-mono"),width=len(name)*4)
    ])

def main():
    """ Entry point

    Returns:
        render root
    """
    api_base = 'https://smartcambridge.org/api/v1/parking/'
    api_token = 'Token cb9e13991b6d3716b2a47fda106ad8d87bacff94'

    headers = {'Authorization': api_token}

    # fetch list of parking ids
    response  = http.get(api_base,headers=headers)
    park_list = response.json()['parking_list']

    # Collect output rows
    columns = []

    for parking_type in ['car_park']:#, 'park_and_ride']:
        date = ""
        for park in park_list:
            if park['parking_type'] == parking_type:
                api_latest = '{}/latest/{}/'.format(api_base,park["parking_id"])

                response = http.get(api_latest,headers=headers)
                data = response.json()

                new_date = data['date']
                if new_date!= date:
                    date = new_date
                    #print_date = datetime.datetime.fromisoformat(date)
                    #output_text += print_date.strftime('%d %b %Y %H:%M') + '\n'

                columns.append(render_row(data["spaces_capacity"],data["spaces_free"],park["parking_name"]))
                

    return render.Root(
        child = render.Column(columns,expanded=True,main_align='space_around'),
        show_full_animation = True
    )
 