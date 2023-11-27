""" Tidbyt app to show parking spaces in Cambridge UK Car Parks """

load("render.star", "render")
load("http.star","http")

def render_fixed(n):
    text_num = "%d" % n
    pad = ""
    if len(text_num)==2:
        pad = " "
    elif len(text_num)==1:
        pad = "  "
    return(pad + text_num)

def render_row(capacity,free,name):
    """ Render row with spaces in green, or red if less than 10% free

    Args:
        capacity: total spaces
        free: free spaces
        name: text
    """
    space_colour = "#0F0" if free>(capacity//10) else "F00"
    return render.Row(children = [
        render.Text(render_fixed(free), color=space_colour, font = "CG-pixel-4x5-mono"),
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
 