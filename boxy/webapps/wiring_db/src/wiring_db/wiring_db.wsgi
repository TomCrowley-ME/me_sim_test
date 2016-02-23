import os
os.environ["BENDER_PATH"] = "/home/mercurial/bender"
os.environ["BOXY_PATH"] = "/home/mercurial/boxy"
os.environ["APP_IS_RUNNING_ON_SERVER"] = "True"

import sys
sys.path.append('/home/mercurial/boxy/webapps/wiring_db/src/')

from wiring_db import wiring_db
application = wiring_db.app