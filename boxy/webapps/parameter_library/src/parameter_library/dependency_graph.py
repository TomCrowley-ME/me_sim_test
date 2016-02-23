'''
Created on Jun 27, 2014

@author: tklaus
'''

class DependencyNode:
    def __init__(self, name):
        self.name = name
        self.dependencies = []

    def add_dependency(self, node):
        self.dependencies.append(node)
        
    def __str__(self):
        s = '{} -> ['.format(self.name)
        for dependency in self.dependencies:
            s += '{},'.format(dependency.name)        
        s += ']'
        return s        

class DependencyGraph:
    def __init__(self):
        self.root_node = None
        self.nodes_by_name = {}

    def add_node(self, name):
        new_node = DependencyNode(name)
        self.nodes_by_name[name] = new_node
        if not self.root_node:
            self.root_node = new_node # arbitrary entry point for the graph
        return new_node
                    
    def find_node(self, name):
        return self.nodes_by_name.get(name)
    
    def get_nodes_in_dependency_order(self):
        resolved = []
        seen = []
        self.resolve_dependencies(self.root_node, resolved, seen)
        return resolved
    
    def resolve_dependencies(self, node, resolved, seen):
        #print('node.name = {}'.format(node.name))
        seen.append(node)
        for dependency in node.dependencies:
            if dependency not in resolved:
                if dependency in seen:
                    raise Exception('Circular reference detected: {} -> {}'.format(node.name, dependency.name))
                self.resolve_dependencies(dependency, resolved, seen)
        resolved.append(node)

    def dump(self):
        seen = []
        self.dump_one(self.root_node, seen)
        
    def dump_one(self, node, seen, indent=''):
        #if node.name not in seen:
        seen.append(node.name)
        print("{}{}".format(indent, node.name))
        for kid in node.dependencies:
            self.dump_one(kid, seen, indent + ' ')
        
        
        
        
        