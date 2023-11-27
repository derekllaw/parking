""" Tidbyt app to show parking spaces in Cambridge UK Car Parks """

load("render.star", "render")
load("http.star","http")

# constants
API_BASE = "https://smartcambridge.org/api/v1/parking/"
SCREEN_WIDTH = 64
PARK = "car_park"
RIDE = "park_and_ride"

# global variable
font = "5x8"

def render_fixed(n):
    """ Render number in at least 3 characters

    Args:
        n: number

    Returns:
        padded string
    """
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
    free_colour = "#0F0" if free>(capacity//10) else "F00"
    free_text = render_fixed(free)
    return render.Row(children = [
        render.Text(free_text, color=free_colour, font=font),
        render.Marquee(child=render.Text(name,font=font),width = (SCREEN_WIDTH - len(free_text)*5))
    ])

def main():
    """ Entry point

    Returns:
        render root
    """
    api_token = 'Token cb9e13991b6d3716b2a47fda106ad8d87bacff94'
    headers = {'Authorization': api_token}

    # fetch list of parking ids
    response  = http.get(API_BASE,headers=headers)
    park_list = response.json()['parking_list']

    # Collect output rows
    rows = []

    for parking_type in [PARK]:#, RIDE]:
        for park in park_list:
            if park['parking_type'] == parking_type:
                api_latest = '{}/latest/{}/'.format(API_BASE,park["parking_id"])

                response = http.get(api_latest,headers=headers)
                data = response.json()

                rows.append(render_row(data["spaces_capacity"],data["spaces_free"],park["parking_name"].title()))
                

    return render.Root(
        child = render.Column(rows,expanded=True,main_align='space_around'),
        show_full_animation = True
    )
 