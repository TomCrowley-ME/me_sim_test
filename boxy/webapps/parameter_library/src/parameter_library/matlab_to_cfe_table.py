'''
Generate a MATLAB script that converts a set of MATLAB workspace
variables (tunable parameters for a single Simulink model)
to a cFE table file (*.tbl) that can be uploaded to a HIL
or vehicle for state initialization.

Created on Jun 19, 2014

@author: tklaus
'''


class MatlabCfeTable(object):

    def __init__(self, table_parameters):
        self.table_parameters = table_parameters
        
