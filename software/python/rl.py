###
###	by Marinos Koutsomichalis (me@marinoskoutsomichalis.com)
###	Neapolis, 10.2016
###	part of Inhibition python code
###	this module implements reinforcement learning (agent-environment loop scenario)
###

#modules
from pythonosc import osc_message_builder
from pythonosc import udp_client
from pythonosc import dispatcher
from pythonosc import osc_server

from sys import exit

from inhibition_environment import Inhibition, Inhibition_Task
import sc_bridge as sc

from pybrain.rl.learners.valuebased import ActionValueTable
from pybrain.rl.agents import LearningAgent
from pybrain.rl.learners import Q, SARSA
from pybrain.rl.experiments import Experiment

# osc ports
listening_port = 5005;

# RL
env = Inhibition()
env.reset()
controller = ActionValueTable(16, 25)
controller.initialize(1.)
learner = Q()
agent = LearningAgent(controller, learner)
task = Inhibition_Task(env)
experiment = Experiment(task, agent)

def self_quit(unused_addr, args, message):
    sc.send("/quit_arrived","message received - quiting")
    global server
    server.shutdown
    exit("quiting")

def start(unused_addr, args, message):
    print("RL starting")
    while True:
        experiment.doInteractions(6) # make a number of interaction in-between learning
        agent.learn()
        agent.reset()
    
if __name__ == "__main__":
    # dispatch osc messages
    disp = dispatcher.Dispatcher()
    disp.map("/test", print) # dumb input message
    disp.map("/quit", self_quit, "ok")
    disp.map("/start", start, "ok")
    #disp.map("/iterate", self_quit, "ok")
    #disp.map("/reset", reset, "ok")
    
    server = osc_server.ThreadingOSCUDPServer( ("127.0.0.1", listening_port), disp)
    print("Serving on {}".format(server.server_address))
    #server.serve_forever()
    while True:
        experiment.doInteractions(6) # make a number of interaction in-between learning
        agent.learn()
        agent.reset()

    
  


