'''
Created on Jun 19, 2014

@author: tklaus
'''
import re
from parameter_library.dependency_graph import DependencyGraph

# match variable names within MATLAB expressions
VARIABLE_REGEX = re.compile("[a-zA-Z][a-zA-Z0-9_\.]*") 

class MatlabInit(object):

    def __init__(self, parameter_table_dict, parameter_dict, global_params, scenario_name):
        self.parameter_table_dict = parameter_table_dict
        self.global_params = global_params
        self.scenario_name = scenario_name
        
        self.parameter_dict = {}
        for parameter in parameter_dict:
            p = parameter.replace("SCENARIO_NAME", self.scenario_name)
            v = str(parameter_dict[parameter]).replace("SCENARIO_NAME", self.scenario_name)
            self.parameter_dict[p] = v
            print("parameter_dict: {} = {}".format(p,v))

        self.parameter_table_dict = {}
        for parameter in parameter_table_dict:
            p = parameter.replace("SCENARIO_NAME", self.scenario_name)
            v = str(parameter_table_dict[parameter]).replace("SCENARIO_NAME", self.scenario_name)
            self.parameter_table_dict[p] = v
            print("parameter_table_dict: {} = {}".format(p,v))

    def generate(self):
        #print('num parameters = {}'.format(len(self.table_parameters)))

        dependency_graph = DependencyGraph()        
        root_node = dependency_graph.add_node("#root")
        unresolved = []
        
        for parameter_name in self.parameter_table_dict:
            #print('parameter = {}'.format(parameter_name))

            param_node = dependency_graph.add_node(parameter_name)
            root_node.add_dependency(param_node)

            self.build_dependency_graph(parameter_name, dependency_graph, unresolved)
            
        matlab_init_script = ''

        gbl_dependency_graph = DependencyGraph()        
        root_node = gbl_dependency_graph.add_node("#root")

        if self.global_params:
            matlab_init_script += 'global gbl_param;\n'
            
            for parameter_name in self.global_params:
                #print('parameter = {}'.format(parameter_name))
    
                param_node = gbl_dependency_graph.add_node(parameter_name)
                root_node.add_dependency(param_node)
    
                self.build_dependency_graph(parameter_name, gbl_dependency_graph, unresolved)
                
            nodes = gbl_dependency_graph.get_nodes_in_dependency_order()
            for node in nodes:
                parameter_name = node.name
                #print('NODE parameter = {}'.format(parameter_name))
                if parameter_name != '#root':
                    matlab_init_script += "{} = {};\n".format(parameter_name, self.global_params[parameter_name])

        matlab_init_script += '\n\n'

        print('main dependency graph:')
        dependency_graph.dump()
        
        nodes = dependency_graph.get_nodes_in_dependency_order()
        for node in nodes:
            parameter_name = node.name
            if parameter_name != '#root':
                matlab_init_script += "{} = {};\n".format(parameter_name, self.get_expression(parameter_name))

                
        matlab_init_script += '\n'

        unresolved = set(unresolved)
        print("unresolved names: {}".format(unresolved))    
        
        matlab_init_script += "\n\n% Unresolved symbols: {}\n".format(unresolved)
        
        return matlab_init_script
    
    def build_dependency_graph(self, parameter_name, dependency_graph, unresolved, depth=0):
        print("parameter_name: {}".format(parameter_name))
        parameter_node = dependency_graph.find_node(parameter_name)
        if not parameter_node:
            dependency_graph.add_node(parameter_name)

        value_expression = self.get_expression(parameter_name)
        print("  value_expression: {}".format(value_expression))
                                
        dependencies = VARIABLE_REGEX.findall(str(value_expression))
        
        for dependency in dependencies:
            if dependency in self.parameter_dict: #is a real var, not a MATLAB builtin
                print('  dependency = {}'.format(dependency))
                dependency_node = dependency_graph.find_node(dependency)
                if not dependency_node:
                    dependency_node = dependency_graph.add_node(dependency)
                parameter_node.add_dependency(dependency_node)
                if depth < 20:
                    self.build_dependency_graph(dependency, dependency_graph, unresolved, depth+1)
                else:
                    raise ValueError("Recursion error determining dependencies for {}".format(parameter_name))
            else:
                unresolved.append(dependency)
                
    def get_expression(self, parameter_name):
        value_expression = ''
                    
        if parameter_name in self.parameter_table_dict:
            value_expression = str(self.parameter_table_dict[parameter_name])
        else:
            value_expression = str(self.parameter_dict[parameter_name])

        value_expression = value_expression.replace("SCENARIO_NAME", self.scenario_name)
        
        #print("value_expression = {}".format(value_expression))

        return value_expression
        
        