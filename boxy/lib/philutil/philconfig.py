import configparser, collections, os


class PhilConfig(object):

    """A utility class providing an API to the MoonEx PIL/HIL vehicle host configuration file"""

    def __init__(self, ini_path=None):
        """
        """
        self.config = configparser.ConfigParser()

        try:
            # load the INI configuration file
            if ini_path is not None:
                self.config.read(ini_path)
            else:
                self.config.read(os.path.expandvars("$PYTHONPATH/philutil/resources/moonex_phils.ini"))

        except Exception as e:
            raise Exception ("Error parsing p/hil INI configuration file: " + str(e))



    def get_config(self, section, config):
        """
        Returns the specified property configuration of the given INI section.
        """
        try:
            return self.config.get(section, config)

        except Exception as e:
            raise Exception ("Failed to look up configuration property \"" + config + "\" for P/HIL \"" + section + "\": " + str(e))



    def has_config(self, section, config):
        """
        Returns the specified property configuration of the given INI section.
        """
        try:
            return self.config.has_option(section, config)

        except Exception as e:
            raise Exception ("Failed to look up configuration property \"" + config + "\" for P/HIL \"" + section + "\": " + str(e))



    def dump_config(self):
        """
        Dump the P/HIL configuration sections.
        """
        print ("\n=== MoonEx P/HIL Configurations ===")
        for c in self.config:
            if c == "DEFAULT":
                continue
            print ("  " + c + ": " + str(self.config.get(c, "type")).rjust(13 - len(c)) + " (" + self.config.get(c, "ipaddress") + ")")

        print ("")
