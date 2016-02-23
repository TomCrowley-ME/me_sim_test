import os
os.environ["BENDER_PATH"] = "/home/mercurial/bender"
os.environ["BOXY_PATH"] = "/home/mercurial/boxy"
os.environ["APP_IS_RUNNING_ON_SERVER"] = "True"

import sys
sys.path.append('/home/mercurial/boxy/webapps/procs_app/src/')

from procs_app import procs_app
application = procs_app.app