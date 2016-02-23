'''
Created on Jun 19, 2014

@author: tklaus
'''
import unittest
from parameter_library.matlab_init import MatlabInit
import sys

class Test(unittest.TestCase):

    def testGenerate(self):
        print("\nTEST={}\n".format(sys._getframe().f_code.co_name))
        
        # kfl_quat_init
        parameter_table_dict = {
                        "kfl_ini_rotx" : "ini_rotx + ( kfl_star_tracker_err * pi/180 )",
                        "kfl_ini_roty" : "ini_roty + ( kfl_star_tracker_err * pi/180 )",
                        "kfl_ini_rotz" : "ini_rotz + ( kfl_star_tracker_err * pi/180 )" 
                        }
            

        parameter_dict = {
                          "kfl_ini_rotx" : "ini_rotx + ( kfl_star_tracker_err * pi/180 )",
                          "kfl_ini_roty" : "ini_roty + ( kfl_star_tracker_err * pi/180 )",
                          "kfl_ini_rotz" : "ini_rotz + ( kfl_star_tracker_err * pi/180 )",
                          "ini_rotx" : "scn1.ini_rotx",
                          "ini_roty" : "scn1.ini_roty",
                          "ini_rotz" : "scn1.ini_rotz",
                          "scn1.ini_rotx" : "40*pi/180",
                          "scn1.ini_roty" : "40*pi/180",
                          "scn1.ini_rotz" : "150*pi/180",
                          "kfl_star_tracker_err" : "(sqrt(2*kfl_star_tracker_transverse_noise^2 + kfl_star_tracker_boresight_noise^2)/3600) / 3",
                          "kfl_star_tracker_transverse_noise" : "[ 9 ]",
                          "kfl_star_tracker_boresight_noise" : "kfl_star_tracker_transverse_noise * 10",
                          }

        matlab_init = MatlabInit(parameter_table_dict, parameter_dict)
        
        script = matlab_init.generate()
        
        print("script = \n{}".format(script))
        

if __name__ == "__main__":
    #import sys;sys.argv = ['', 'Test.testGenerate']
    unittest.main()