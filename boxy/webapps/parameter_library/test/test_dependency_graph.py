'''
Created on Jun 27, 2014

@author: tklaus
'''
import unittest
from parameter_library.dependency_graph import DependencyGraph


class TestDependencyGraph(unittest.TestCase):
 
    def testResolve(self):
        graph = DependencyGraph()
        
        root = graph.add_node("#root")
        kfl_ini_rotx = graph.add_node("kfl_ini_rotx")
        kfl_ini_roty = graph.add_node("kfl_ini_roty")
        kfl_ini_rotz = graph.add_node("kfl_ini_rotz")
        ini_rotx = graph.add_node("ini_rotx")
        ini_roty = graph.add_node("ini_roty")
        ini_rotz = graph.add_node("ini_rotz")
        scn1_ini_rotx = graph.add_node("scn1.ini_rotx")
        scn1_ini_roty = graph.add_node("scn1.ini_roty")
        scn1_ini_rotz = graph.add_node("scn1.ini_rotz")
        kfl_star_tracker_err = graph.add_node("kfl_star_tracker_err")
        kfl_star_tracker_transverse_noise = graph.add_node("kfl_star_tracker_transverse_noise")
        kfl_star_tracker_boresight_noise = graph.add_node("kfl_star_tracker_boresight_noise")

        root.add_dependency(kfl_ini_rotx)
        root.add_dependency(kfl_ini_roty)
        root.add_dependency(kfl_ini_rotz)        
        kfl_ini_rotx.add_dependency(ini_rotx)
        kfl_ini_rotx.add_dependency(kfl_star_tracker_err)
        kfl_ini_roty.add_dependency(ini_roty)
        kfl_ini_roty.add_dependency(kfl_star_tracker_err)
        kfl_ini_rotz.add_dependency(ini_rotz)
        kfl_ini_rotz.add_dependency(kfl_star_tracker_err)
        ini_rotx.add_dependency(scn1_ini_rotx)
        ini_roty.add_dependency(scn1_ini_roty)
        ini_rotz.add_dependency(scn1_ini_rotz)
        kfl_star_tracker_err.add_dependency(kfl_star_tracker_transverse_noise)
        kfl_star_tracker_err.add_dependency(kfl_star_tracker_boresight_noise)
        kfl_star_tracker_boresight_noise.add_dependency(kfl_star_tracker_transverse_noise)
         
        nodes = graph.get_nodes_in_dependency_order()
        
        for node in nodes:
            print('node = {}'.format(node))
            
if __name__ == "__main__":
    #import sys;sys.argv = ['', 'Test.testName']
    unittest.main()