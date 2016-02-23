import os
os.environ["BENDER_PATH"] = "/home/mercurial/bender"
os.environ["BOXY_PATH"] = "/home/mercurial/boxy"
os.environ["APP_IS_RUNNING_ON_SERVER"] = "True"

import sys
sys.path.append('/home/mercurial/boxy/webapps/cnt_tool/src/')
sys.path.append('/home/mercurial/boxy/lib')

from cnt_tool import cnt_tool
application = cnt_tool.app