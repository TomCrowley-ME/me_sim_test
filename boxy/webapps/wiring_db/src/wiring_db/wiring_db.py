#! /usr/bin/env python3

'''
Created on Jun 3, 2014

@author: tklaus, pgray
'''

from flask import Flask, redirect, render_template, request
from flask_pymongo import PyMongo
from bson.json_util import dumps

from jinja2 import Environment, PackageLoader

import json, subprocess, os, copy

#from flask_pymongo import PyMongo

app = Flask(__name__)
app.config['MONGO_DBNAME'] = 'cab_interfaces'
mongo = PyMongo(app)

env = Environment(loader=PackageLoader('wiring_db', 'templates'))

json_file_path = os.path.expandvars('$BOXY_PATH/webapps/wiring_db/src/test_all.json')

is_running_on_server = False
if os.path.expandvars('$APP_IS_RUNNING_ON_SERVER') == 'True':
    is_running_on_server = True

column_names = 			[
		                "id_num",
		                "Connector Name",
		                "Connector Package Name",
		                "Harness Name",
		                "Pin #",
		                "Card signal",
		                "Pin swap",
		                "ERC Type",
		                "Net Name",
		                "System Type",
		                "Comment/Notes"
		                ]

cab_external_columns = 	[
						"id_num",
						"Board Type",
						"Signal Name",
						"Connector",
						"Pin #"
						]

hifi_hil_columns = 		[
						"id_num",
						"Board Type",
						"Signal Name",
						"FPGA #",
						"FPGA Pin #",
						"FPGA Page",
						"FPGA Address",
						"Net Name"
						]

cab_control_columns = 	[
						"id_num",
						"Board Type",
						"Signal Name",
						"FPGA #",
						"FPGA Pin #",
						"FPGA Page",
						"FPGA Address",
						"Net Name"
						]			

fpga_edu_v1_coulmns = 	[
                        "id_num",
                        "Board Type",
                        "Signal Name",
                        "Signal Type Enum",
                        "FPGA #",
                        "FPGA Pin #",
                        "FPGA Pad #",
                        "FPGA Page Address",
                        "Interface Connector",
                        "Interface Connector Pin",
                        "Net Name"
                        ]

logic_sim_v1_coulmns =  [
                        "id_num",
                        "Board Type",
                        "Signal Name",
                        "Signal Type Enum",
                        "Interface Connector",
                        "Interface Connector Pin",
                        "INCU Feedback Pin",
                        "MCU Pin Function",
                        "Logic Sim Board",
                        "Net Name"
                        ]					

flight_software_coulmns=[
						"id_num",
						"Board Type",
						"Signal Name",
						"FSW Handle"
						]

board_to_column = {
					"cab_external" : cab_external_columns,
					"hifi_hil" : hifi_hil_columns,
					"cab_control" : cab_control_columns,
					"fpga_edu_v1" : fpga_edu_v1_coulmns,
					"logic_sim_v1" : logic_sim_v1_coulmns,
					"flight_software" : flight_software_coulmns
					}

board_types = [
				"cab_external",
				"hifi_hil",
				"cab_control",
				"fpga_edu_v1",
				"logic_sim_v1",
				"flight_software",
				]

@app.route('/loaddb', methods=['POST'])
def load_db():
    if request.method == "POST":
        #drop current connections
        cab_connections = mongo.db.drop_collection(mongo.db.cab_connection)
        #load in the cab_connection collection
        cab_connector_json_file = open(json_file_path, 'r')
        cab_connector_dict_file = json.load(cab_connector_json_file)

        for connector in cab_connector_dict_file:
            mongo.db.cab_connection.insert(connector)

        return redirect('/')

@app.route('/dropdb', methods=['GET'])
def drop_db():
    if request.method == "GET":
        cab_connections = mongo.db.drop_collection(mongo.db.cab_connection)
        return redirect('/')

@app.route('/dropandloaddb', methods=['POST'])
def drop_and_load_db():
    if request.method == "POST":
        cab_connections = mongo.db.drop_collection(mongo.db.cab_connection)

        cab_connector_json_file = open(json_file_path, 'r')
        cab_connector_dict_file = json.load(cab_connector_json_file)

        for connector in cab_connector_dict_file:
            mongo.db.cab_connection.insert(connector)
        return redirect('/')

@app.route('/exportdb', methods=['POST'])
def export_db():
    if request.method == "POST":
        connections = mongo.db.cab_connection.find()

        cab_connector_json_file = open(json_file_path, 'w')
        connections_stable = list(connections)
        for dict_item in connections_stable:
            dict_item.pop("_id", None)
        dumped_dict = dumps(connections_stable, indent=4, separators=(',', ':'), sort_keys=True).replace(":", " : ")
        cab_connector_json_file.write(dumped_dict)
        cab_connector_json_file.close()
        return redirect('/')

@app.route('/savedb', methods=['POST'])
def save_db():
    if request.method == "POST":
        changed_json_connections = request.form.get('modified_row_data', None)
        if not changed_json_connections:
            pass

        else:
            row_items = changed_json_connections.split(',-split-,')
            row_items[-1] = row_items[-1][:-8]

            list_of_connections = []
            x = 0
            while x < len(row_items)-1:

                connection_item = []

                try:
                    num_to_iterate_through = len(board_to_column[row_items[x+1]])
                    iterated_through = 0
                    while iterated_through < (num_to_iterate_through):
                        connection_item.append(row_items[x])
                        x+=1
                        iterated_through+=1
                    list_of_connections.append(connection_item)
                except IndexError:
                    pass



            query_criteria = {}
            for updated_row in list_of_connections:
                updated_connector_to_post = {}
                print(updated_row[1])
                column_names = board_to_column[updated_row[1]]
                for x in range(0, len(board_to_column[updated_row[1]])):
                    updated_connector_to_post[column_names[x]] = updated_row[x]

                mongo.db.cab_connection.update({"id_num" : updated_connector_to_post["id_num"]}, updated_connector_to_post, upsert=True)

            #saving all the connections in the DB to the file
            #make sure that if you are taking off the id_num it is generated in the script
            connections = mongo.db.cab_connection.find()
            cab_connector_json_file = open("test.json", 'w')
            connections_stable = list(connections)
            for dict_item in connections_stable:
                dict_item.pop("_id", None)
            dumped_dict = dumps(connections_stable, indent=4, separators=(',', ':')).replace(":", " : ")
            cab_connector_json_file.write(dumped_dict)
            cab_connector_json_file.close()

        
        return redirect('/')



@app.route('/', methods=['POST', 'GET'])
def list_connectors_page():
    query_criteria = {}
    net_name_selected = None
    interface_connector_selected = None
    signal_name_selected = None
    
    if request.method == 'POST':    
        print("form = {}".format(request.form))
        net_name_selected = request.form["net_name_selected"]
        interface_connector_selected = request.form["interface_connector_selected"]
        signal_name_selected = request.form["signal_name_selected"]

        print("about to print things")
        print("card_signal_selected = {}".format(net_name_selected))
        print("card_signal_selected = {}".format(interface_connector_selected))
        
        if net_name_selected != 'ALL':
            query_criteria["Net Name"] = net_name_selected

        if interface_connector_selected != 'ALL':
            query_criteria["Interface Connector"] = interface_connector_selected

        if signal_name_selected != 'ALL':
            query_criteria["Signal Name"] = signal_name_selected

    print("query_criteria = {}".format(query_criteria))
    print("mongo.db = {}".format(mongo.db))

    connections = mongo.db.cab_connection.find(query_criteria)
    print("GOT THE CONNECTIONS")
    connections_iterable = list(copy.deepcopy(connections))

    max_id = 0
    for conn in connections_iterable:
        if int(conn["id_num"]) > max_id:
            max_id = int(conn["id_num"])
    count = 0
    table = []
    
    for connector in connections:
        #print('connector = {}'.format(connector))
        row = []
        for column_name in board_to_column[connector["Board Type"]]:
            #print('column_name = {}'.format(column_name))
            row.append(connector[column_name])
            #print("connector[{}] = {}".format(column_name, connector[column_name]))
            #print('row = {}'.format(row))
        table.append(row)
        count = count + 1


    print('num connections = {}'.format(count))
    #print('table = {}'.format(table))
    print (query_criteria)

    unique_net_names =  None
    unique_signal_names = None
    unique_interface_connectors = None

    if request.method == 'POST':
        unique_net_names =  connections.distinct('Net Name')
        unique_signal_names = connections.distinct('Signal Name')
        unique_interface_connectors = connections.distinct('Interface Connector')

    else: 
        unique_net_names =  mongo.db.cab_connection.distinct('Net Name')
        unique_signal_names = mongo.db.cab_connection.distinct('Signal Name')
        unique_interface_connectors = mongo.db.cab_connection.distinct('Interface Connector')

    
    return render_template('wiring_db.html', column_names=column_names, 
                           table=table,
                           unique_net_names=unique_net_names,
                           unique_interface_connectors=unique_interface_connectors,
                           unique_signal_names=unique_signal_names,
                           previous_net_name=net_name_selected,
                           previous_interface_connector=interface_connector_selected,
                           previous_signal_name=signal_name_selected,
                           board_to_column=board_to_column,
                           board_types=board_types,
                           max_id=max_id,
                           is_running_on_server=is_running_on_server,
                           )
    
if __name__ == '__main__':
    app.config["SECRET_KEY"] = ")\xf1/T\xc1'\xe7\x8e)\x89\xdc\xf3\xdf4\xd5\x99\x89\xedd\xdd\x99\xec\xce&"
#   app.run(host='0.0.0.0', debug=True)
    app.run(port=int("2500"), debug=True)
    

