
import os
from philutil import PhilConfig


class CtrlSourceGen(object):

    """The CtrlSourceGen module generates the ITOS ctrlsource.dat file."""

    def __init__(self, itos_dir_path):
        """
        Initializes the CtrlSourceGen module by parsing the MoonEx phil INI configuration file.
        """
        self.philconfig = PhilConfig()
        self.itos_dir = os.path.abspath(itos_dir_path)



    def generate(self, phil, single_pil=False, sim=False, sim_namespace=None):
        """
        """
        fsw_tlm_sourcename = "schooner"
        sim_tlm_sourcename = "highseas"
        multicat_prefix = "239.1.0."
        mission = "worlddomination"
        static_params = "aos 1113 0 68 0 n/a .end n/a n/a junk:4 crc .end"

        msg = "  Populating ctrlsource.dat for " + phil.lower()
        msg = msg + "/" + self.philconfig.get_config(phil, "simHostname") if sim and not single_pil else msg
        print (msg)

        with open(self.itos_dir + "/ctrlsource.dat", "w") as f:

            # define the sourcename for FSW
            f.write("source:" + fsw_tlm_sourcename + " ")

            # define the name for FSW
            f.write(self.philconfig.get_config(phil, "hostname") + " ")

            # define the telemetry datatype
            f.write(self.philconfig.get_config(phil, "telemetryFormat") + " ")

            # define the telemetry source address
            f.write("udp ")
            f.write(multicat_prefix + self.philconfig.get_config(phil, "IPAddress").split(".")[-1::][0] + " ")
            f.write(self.philconfig.get_config(phil, "telemetryPort") + " ")

            # define the mission name
            f.write(mission + " ")

            # define the ctrlsource parameters (static for MoonEx at this time)
            f.write(static_params + "\n")


            # only generate the sim ctrlsource entry for HILs
            if sim and not single_pil:

                # define the sourcename for SIM
                f.write("source:" + sim_namespace + "." + sim_tlm_sourcename + " ")

                # define the name for SIM
                f.write(self.philconfig.get_config(phil, "simHostname") + " ")

                # define the telemetry datatype
                f.write(self.philconfig.get_config(phil, "telemetryFormat") + " ")

                # define the telemetry source address
                f.write("udp ")
                f.write(multicat_prefix + self.philconfig.get_config(phil, "simIPAddress").split(".")[-1::][0] + " ")
                f.write(self.philconfig.get_config(phil, "telemetryPort") + " ")

                # define the mission name
                f.write(mission + " ")

                # define the ctrlsource parameters (static for MoonEx at this time)
                f.write(static_params + "\n")


