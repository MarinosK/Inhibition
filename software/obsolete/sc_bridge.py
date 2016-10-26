###
###	by Marinos Koutsomichalis (me@marinoskoutsomichalis.com)
###	Neapolis, 10.2016
###	part of Inhibition python code
###	this module implements osc communication with supercollider 
###

from pythonosc import osc_message_builder
from pythonosc import udp_client

sclang_port = 57120;
client = udp_client.UDPClient("127.0.0.1", sclang_port)

def send(tag, message): 
    msg = osc_message_builder.OscMessageBuilder(address = tag)
    msg.add_arg(message)
    msg = msg.build()
    client.send(msg)
