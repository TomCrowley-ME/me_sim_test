'''
Created on Aug 7, 2014

@author: tklaus
'''
from collections import OrderedDict
import collections
from sets import Set

from parameter_library.matlab_init import MatlabInit
from parameter_library.utils import table_names_for_scenario, \
    retrieve_parameter_dict


class Scenario(object):

    def __init__(self, scenario_name, mongo, env, parameter_dict):
        self.scenario_name = scenario_name
        self.mongo = mongo
        self.env = env
        self.parameter_dict = parameter_dict
    
    def get_name(self):
        return self.scenario_name
    
    def export_single_table(self, table_name):
        print("table_name = {}".format(table_name))
        print("scenario_name = {}".format(self.scenario_name))

        parameter_table_parameters = self.mongo.db.parameter_tables.find({'app_name' : table_name}).sort([("parameter_name",1)])

        parameter_table_dict = collections.OrderedDict()
        for p in parameter_table_parameters:
            parameter_name = p["parameter_name"]
            parameter_value = p["value"]
            if not parameter_value:
                parameter_value = self.parameter_dict[parameter_name]
            parameter_table_dict[parameter_name] = parameter_value

        global_params = self.mongo.db.parameters.find({"tunable_for":'GLOBAL'})
        global_params_dict = collections.OrderedDict()
        for p in global_params:
            parameter_name = p["name"]
            parameter_value = p["default_value"]
            global_params_dict[parameter_name] = parameter_value

        matlab_init_script = MatlabInit(parameter_table_dict, self.parameter_dict, global_params_dict, self.scenario_name)
        matlab_script_code = matlab_init_script.generate()
        #print('matlab_script_code = {}'.format(matlab_script_code))
    
        return matlab_script_code
    
    def export_all_tables(self):

        table_names = table_names_for_scenario(self.scenario_name, self.mongo)
        matlab_scripts = dict()
        
        for table_name in table_names:
            matlab_scripts[table_name] = self.export_single_table(table_name)
            
        return matlab_scripts



    