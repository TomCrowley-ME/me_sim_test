'''
Created on Aug 7, 2014

@author: tklaus
'''
from sets import Set
from collections import OrderedDict

def table_names_for_scenario(scenario_name, mongo):
    scenario_tables = mongo.db.parameter_tables.find({'scenario_name':scenario_name})
    table_names = Set()

    for table in scenario_tables:
        table_names.add(table["app_name"])
        
    return table_names

def retrieve_parameter_dict(mongo):
    all_params = mongo.db.parameters.find().sort([("name",1)])
    param_dict = OrderedDict()

    for param in all_params:
        param_name = param["name"]
        param_value = param["default_value"]
        param_dict[param_name] = param_value
        if str(param_value).endswith(";"):
            print("Extraneous semi-colon: name = {}".format(param["name"]))

    return param_dict

