#! /usr/bin/env python3

'''
Created on Jun ,26 2014

@author: pgray
'''

from flask import Flask, redirect, render_template, request
from collections import OrderedDict
import os, json, copy, sys
from cntutil import Validator

app = Flask(__name__)

is_running_on_server = False
if os.path.expandvars('$APP_IS_RUNNING_ON_SERVER') == 'True':
    is_running_on_server = True

##############################################################
### classes for representing dictionary and schema objects ###
##############################################################

class cnt_dict():
    def __init__(self, name, description, the_json, subless_json, common_data=None, telemetry_data=None, command_data=None, sub_systems=None, parent=None):
        self.name = name
        self.description = description
        self.the_json = the_json
        self.subless_json = subless_json
        self.common_data = common_data
        self.telemetry_data = telemetry_data
        self.command_data = command_data
        self.sub_systems = sub_systems
        self.parent = parent

class cnt_schema():
    def __init__(self, the_json, subless_json, properties, definitions):
        self.the_json = the_json
        self.subless_json = subless_json
        self.properties = properties
        self.definitions = definitions

####################################################
### functions for use on the actual webapp pages ###
####################################################

def build_space_system(initial_dict_of_json):
    dict_of_json = initial_dict_of_json["space_system"]

    #create dictionary object and check for KeyErrors
    try:
        dict_common_data = dict_of_json["common_data"]
    except KeyError:
        dict_common_data = None
    try:
        dict_telemetry_data = dict_of_json["telemetry_data"]
    except KeyError:
        dict_telemetry_data = None
    try:
        dict_command_data = dict_of_json["command_data"]
    except KeyError:
        dict_command_data = None
    try:
        dict_sub_systems = dict_of_json["sub_systems"]
    except KeyError:
        dict_sub_systems = None

    subless_dict_of_json = copy.deepcopy(initial_dict_of_json)
    subless_dict_of_json["space_system"].pop("sub_systems", None)

    dict_object = cnt_dict(dict_of_json["name"], dict_of_json["description"],
        initial_dict_of_json, subless_dict_of_json, dict_common_data,
        dict_telemetry_data, dict_command_data, dict_sub_systems)

    return dict_object

def build_dict_from_json(path_to_json_dict, json_string=None):
    if not json_string:
        json_string = open(path_to_json_dict, 'r')
        dict_of_json = json.loads(json_string.read(), object_pairs_hook=OrderedDict)
    else:
        dict_of_json = json.loads(json_string, object_pairs_hook=OrderedDict)
    return build_space_system(dict_of_json)

def build_schema_from_json(path_to_json_schema):
    json_string_of_schema = open(path_to_json_schema, 'r')
    dict_of_json_schema = json.loads(json_string_of_schema.read(), object_pairs_hook=OrderedDict)

    subless_dict_of_json_schema = copy.deepcopy(dict_of_json_schema)
    subless_dict_of_json_schema["properties"]["space_system"]["properties"].pop("sub_systems", None)

    schema_props = dict_of_json_schema["properties"]
    schema_definitions = dict_of_json_schema["definitions"]
    schema_object = cnt_schema(dict_of_json_schema, subless_dict_of_json_schema,
     schema_props, schema_definitions)

    return schema_object

def build_system_list_initial(dict_object):
    system_list = []
    system_list.append(dict_object)
    return build_system_list_recursive(dict_object, system_list)


def build_system_list_recursive(dict_object, system_list):
    for sub_sys in dict_object.sub_systems:
        system = build_space_system(sub_sys)
        system.parent = dict_object.name
        system_list.append(system)
        if system.sub_systems:
            system_list = system_list + build_system_list_recursive(system, [])
    return system_list


def build_tag_list(system_list):
    tag_list = []
    for system in system_list:
        if system.common_data:
            if "sequence_containers" in system.common_data:
                for sequence_container in system.common_data["sequence_containers"]:
                    try:
                        if sequence_container["tag"]:
                            if sequence_container["tag"] not in tag_list:
                                tag_list.append(sequence_container["tag"])
                    except:
                        pass

        if system.telemetry_data:
            if "sequence_containers" in system.telemetry_data:
                for sequence_container in system.telemetry_data["sequence_containers"]:
                    try:
                        if sequence_container["tag"]:
                            if sequence_container["tag"] not in tag_list:
                                tag_list.append(sequence_container["tag"])
                    except:
                        pass

        if system.command_data:
            if "sequence_containers" in system.command_data:
                for sequence_container in system.command_data["sequence_containers"]:
                    try:
                        if sequence_container["tag"]:
                            if sequence_container["tag"] not in tag_list:
                                tag_list.append(sequence_container["tag"])
                    except:
                        pass
    return tag_list



def get_sequence_container_list_from_tag(system_list, the_tag):
    sequence_container_tuple_list = []
    for system in system_list:
        if system.common_data:
            for sequence_container in system.common_data["sequence_containers"]:
                try:
                    if sequence_container["tag"]:
                        if sequence_container["tag"] == the_tag:
                            sequence_container_tuple_list.append((sequence_container, system.name))
                except:
                    pass
        if system.telemetry_data:
            for sequence_container in system.telemetry_data["sequence_containers"]:
                try:
                    if sequence_container["tag"]:
                        if sequence_container["tag"] == the_tag:
                            sequence_container_tuple_list.append((sequence_container, system.name))
                except:
                    pass
        if system.command_data:
            for sequence_container in system.command_data["sequence_containers"]:
                try:
                    if sequence_container["tag"]:
                        if sequence_container["tag"] == the_tag:
                            sequence_container_tuple_list.append((sequence_container, system.name))
                except:
                    pass
    return sequence_container_tuple_list

######### Functions for converting the python object back into JSON after it has been edited #########

def update_dict_with_edits(space_system_dict, changed_json_dict):
    name = changed_json_dict["space_system"]["name"]
    if "space_system" not in space_system_dict:
        return
    if name == space_system_dict["space_system"]["name"]:
        #because sub_systems are not included in the main json add them back in after
        #system edits are added in. This should not be a a problem because sub systems
        #cannot be edited in the current system except explicitly.
        try:
            sub_systems_holder = space_system_dict["space_system"]["sub_systems"]
            space_system_dict["space_system"] = changed_json_dict["space_system"]
            space_system_dict["space_system"]["sub_systems"] = sub_systems_holder
        except KeyError:
            space_system_dict["space_system"] = changed_json_dict["space_system"]

        return
    if "sub_systems" not in space_system_dict["space_system"]:
        return
    for d in space_system_dict["space_system"]["sub_systems"]:
        update_dict_with_edits(d, changed_json_dict)


def save_newly_edited_dict(json_system, path_to_json_dict):
    global the_dict_object
    global system_list
    global tag_list
    
    whole_json_string = json.dumps(OrderedDict(json_system), indent=4, separators=(',', ':'), sort_keys=True).replace(":", " : ")

    #todo do we need any particular encoding?
    main_file = open(path_to_json_dict, 'w', encoding='utf-8')
    main_file.write(whole_json_string)
    main_file.close()

    the_dict_object = build_dict_from_json(path_to_json_dict)

    system_list = build_system_list_initial(the_dict_object)
    tag_list = build_tag_list(system_list)


###########################################################
### creating initial global level variables and objects ###
###########################################################

path_to_json_dict = os.path.expandvars('$BENDER_PATH/clamps/moonex_cnt_dictionary.json')
path_to_json_schema = os.path.expandvars('$BENDER_PATH/clamps/moonex_cnt_schema.json')

the_dict_object = build_dict_from_json(path_to_json_dict)
the_schema_object = build_schema_from_json(path_to_json_schema)

system_list = build_system_list_initial(the_dict_object)
tag_list = build_tag_list(system_list)


############################################################
### the actual webpage routing system and pagewide logic ###
############################################################


@app.route('/', methods=['GET', 'POST'])
def home_page():
    if request.method == 'GET':
        the_tag = request.args.get('the_tag')
        s_c_list = []
        if the_tag:
            s_c_list = get_sequence_container_list_from_tag(system_list, the_tag)
        return render_template('main.html', dict_object=the_dict_object,
            system_list=system_list, tag_list=tag_list,
            s_c_list=s_c_list, the_tag=the_tag)

@app.route('/jsoneditor', methods=['GET'])
def json_editor():
    if request.method == 'POST':
        render_template('basicjs.html')
    else:
        global the_dict_object
        system_name = request.args.get('system_name')

        json_to_edit = None
        for system in system_list:
            if system.name == system_name:
                json_to_edit = system.subless_json

        validation_errors=None
        v = Validator()
        validation_errors = v.validate(the_dict_object.the_json, the_schema_object.the_json)

        return render_template('jsoneditor.html', json_to_edit=json.dumps(json_to_edit),
            json_schema=json.dumps(the_schema_object.subless_json), system_list=system_list, 
            system_name=system_name, validation_errors=validation_errors, is_running_on_server=is_running_on_server)

@app.route('/updatedict', methods=['GET', 'POST'])
def update_dict():
    if request.method == 'POST':
        changed_json_system = request.form.get('json_data', None)
        changed_dict_system = json.loads(changed_json_system, object_pairs_hook=OrderedDict)
        update_dict_with_edits(the_dict_object.the_json, changed_dict_system)

        #validate the schema with tool from cntutil
        v = Validator()
        validation_errors = v.validate(the_dict_object.the_json, the_schema_object.the_json)
        save_newly_edited_dict(the_dict_object.the_json, path_to_json_dict)

        if validation_errors:
            path = '/jsoneditor?system_name=' + changed_dict_system["space_system"]["name"]
            return redirect(path)
        else:
            return redirect('/')

@app.route('/printjson', methods=['GET'])
def print_json():
    if request.method == 'GET':
        printable_json = json.dumps(the_dict_object.the_json)
        return render_template('printjson.json', printable_json=printable_json)

#just for testing purposes currently
@app.route('/test', methods=['GET'])
def test():
    if request.method == 'GET':
        json_to_edit = the_dict_object.the_json

        return render_template('jsoneditor.html', json_to_edit=json.dumps(json_to_edit),
            json_schema=json.dumps(the_schema_object.the_json), system_name="WHOLE THING")


if __name__ == '__main__':
    app.config["SECRET_KEY"] = ")\xf1/T\xc1'\xe7\x8e)\x89\xdc\xf3\xdf4\xd5\x99\x89\xedd\xdd\x99\xec\xce&"
    app.run(port=int("4000"), debug=True)

