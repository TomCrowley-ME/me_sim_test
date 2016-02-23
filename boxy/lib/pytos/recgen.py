
import os, json, copy, collections
import pytos.util
from cntutil import CNTUtil
from philutil import PhilConfig



class RecGen(object):

    """The RecGen module converts the MoonEx C&T JSON dictionary into ITOS record files."""

    def __init__(self, rec_dir):
        """
        Initializes the RecGen module by parsing the given json file.
        """
        self.cnt = CNTUtil(cnt_path=os.path.expandvars("$BENDER_PATH/clamps/moonex_cnt_dictionary.json"))
        self.philconfig = PhilConfig()
        self.recdir = os.path.abspath(rec_dir)
        self.enums = dict()
        self.abs_cmd = list()
        self.abs_tlm = list()
        self.data_conversions = list()
        self.num_tlm_pkts = 0
        self.num_cmd_pkts = 0
        self.num_params = 0
        self.num_global_mnemonics = 0
        self.vehicles = list()



    def __del__(self):
        """
        Deinitialize the RecGen module, cleanup and dump enumerations to file.
        """
        self.__dump_enumerations_recfile()
        self.__dump_conversions_recfile()
        self.__generate_static_recfiles()



    def dump_record_statistics(self, fsw_repo_name=None, fsw_repo_rev=None):
        """
        """
        space = 18
        print ("  Record Statistics:")
        if fsw_repo_name is not None and fsw_repo_rev is not None:
            stat = fsw_repo_name + " rev"
            space = len(stat) + 3
            print ("    " + stat + ": " + str(fsw_repo_rev).rjust(space + len(fsw_repo_rev) - len(stat)))
        stat = "vehicles"
        vehicles = str(self.vehicles).replace("'", "")
        print ("    " + stat + ": " + str(vehicles).rjust(space + len(str(vehicles)) - len(stat)))
        stat = "command packets"
        print ("    " + stat + ": " + str(self.num_cmd_pkts).rjust(space + len(str(self.num_cmd_pkts)) - len(stat)))
        stat = "telemetry packets"
        print ("    " + stat + ": " + str(self.num_tlm_pkts).rjust(space + len(str(self.num_tlm_pkts)) - len(stat)))
        stat = "parameters"
        print ("    " + stat + ": " + str(self.num_params).rjust(space + len(str(self.num_params)) - len(stat)))
        stat = "global mnemonics"
        print ("    " + stat + ": " + str(self.num_global_mnemonics).rjust(space + len(str(self.num_global_mnemonics)) - len(stat)))



    def generate_vehicle_recs(self, vehicle, tlmsource="", single_pil=False, export_system=None):
        """
        Generates ITOS record files from the JSON document parsed by the module contstructor.
        single_pil -- temporary hack parameter
        """
        print ("  Populating REC files for " + vehicle)

        # create the output directory if it doesn't exist
        try:
            os.makedirs(self.recdir)
        except OSError as e:
            pass

        self.cnt.discover_space_system(self.cnt.get_root(), vehicle)
        if vehicle not in self.cnt.get_discovered_systems():
            raise Exception("vehicle \"" + vehicle + "\" not found in C&T dictionary")

        vname = str(vehicle).lower().replace("-", "")
        parameter_types = self.cnt.get_parameter_types(vehicle)
        common_sequence_containers = self.cnt.get_common_sequence_containers(vehicle)
        abstract_sequence_containers = self.cnt.get_abstract_sequence_containers(vehicle)
        telemetry_sequence_containers = self.cnt.get_telemetry_sequence_containers(vehicle)
        command_sequence_containers = self.cnt.get_command_sequence_containers(vehicle)
        host = self.cnt.get_host(vehicle)
        limits = self.cnt.get_telemetry_limits(vehicle)
        self.conversions = self.cnt.get_data_conversions(vehicle)


        if export_system is not None:
            print ("    generating import...")
            self.__generate_import_recfile(vname, import_system=export_system, num_limits=len(limits))

        print ("    generating telemetry...")
        self.__generate_telemetry_recs(vname, host, telemetry_sequence_containers, abstract_sequence_containers, parameter_types, tlmsource, single_pil=single_pil, export_system=export_system)

        print ("    generating commands...")
        self.__generate_command_recs(vname, host, command_sequence_containers, abstract_sequence_containers, parameter_types, single_pil=single_pil, export_system=export_system)

        print ("    generating prototypes...")
        self.__generate_prototype_recs(vname, host, abstract_sequence_containers, parameter_types, export_system=export_system)

        print ("    generating global mnemonics...")
        self.__generate_global_mnemonics(vehicle, namespace=export_system)

        print ("    generating telemetry limits...")
        self.__generate_limit_recs(vname, limits, export_system=export_system)

        print ("    generating expression conversions...")
        # add the vehicle conversions to the list of discovered data conversions.
        for c in self.conversions.values():
            self.data_conversions.append(c)

        # record space system/vehicle statistics
        self.vehicles.append(vehicle)




    def __generate_prototype_recs(self, vehicle, host, abstract_seq_containers, parameter_types, export_system):
        """
        Generate an ITOS prototypes rec file for a given vehicle.
        """
        # determine record indentation
        indent = "\t" if export_system is not None else ""

        with open(self.recdir + "/" + vehicle + "_types.rec", "w") as rec:

            # generate a simple file header
            self.__write_header(rec)

            # determine and define a new export system
            if export_system is not None:
                rec.write("export System " + export_system + "(types) {\n\n")

            # generate a prototype record for each abstract sequence container
            for sc in abstract_seq_containers.values():

                # safety check, only abstract sequence containers should be defined as prototypes
                if not sc.get("abstract"):
                    continue

                # ignore the ccsds sequence containers, ITOS already knows what these are
                if "ccsds" in sc.get("name"):
                    continue

                # ignore abstract seq containers that define a base
                if "base" in sc:
                    continue

                rec.write(indent + "prototype Structure " + sc.get("name") + " {\n")

                # create a record for each parameter in the sequence container
                for p in sc.get("parameters"):
                    mnemonic_stmt = export_system + "." if export_system is not None else ""
                    self.__write_param_record(rec, "types", sc, p, abstract_seq_containers, parameter_types, host, indent)
                rec.write(indent + "}\n\n")

            # close the exported system definition if necessary
            if export_system is not None:
                rec.write("}\n")



    def __generate_telemetry_recs(self, vehicle, host, seq_containers, abstract_seq_containers, parameter_types, tlmsource, single_pil=False, export_system=None):
        """
        Generate an ITOS telemetry rec file.
        """
        # determine record indentation
        indent = "\t" if export_system is not None else ""

        with open(self.recdir + "/" + vehicle + "_telemetry.rec", "w") as rec:

            # generate a simple file header
            self.__write_header(rec)

            # determine and define a new export system
            if export_system is not None:
                rec.write("export System " + export_system + "(tlm) {\n\n")

            # define the telemetry source
            if not single_pil:
                rec.write(indent + "StandardTelemetrySource " + tlmsource + "{}\n\n")

            # generate a telemetry record for each sequence container
            for sc in seq_containers.values():

                # ignore abstract telemetry sequence containers
                if sc.get("abstract"):
                    continue

                # expand out the base containers to discover inherited parameters
                params, restrictions = self.cnt.expand_base_container(sc, abstract_seq_containers, list(), dict())

                # begin the telemetry packet record definition
                rec.write(indent + "CFETelemetryPacket " + sc.get("name") + " {\n")
                rec.write(indent + "\tsource=" + tlmsource + "\n")
                rec.write(indent + "\tapplyWhen={\n")
                rec.write(indent + "\t\tFieldInRange{field=applicationId range=" + self.cnt.get_apid(restriction_list=restrictions) + "}\n")
                rec.write(indent + "\t}\n")

                # create a record for each parameter in the sequence container
                for p in params:
                    if p.get("type") in abstract_seq_containers:
                        self.abs_tlm.append(p.get("type"))

                    mnemonic_stmt = export_system + "." if export_system is not None else ""
                    self.__write_param_record(rec, "tlm", sc, p, abstract_seq_containers, parameter_types, host, indent)
                rec.write(indent + "}\n\n")

                # record telemetry packet statistics
                self.num_tlm_pkts += 1

            # close the exported system definition if necessary
            if export_system is not None:
                rec.write("}\n")




    def __generate_command_recs(self, vehicle, host, seq_containers, abstract_seq_containers, parameter_types, single_pil=False, export_system=None):
        """
        Generate an ITOS command rec file.
        """
        # determine record indentation
        indent = "\t" if export_system is not None else ""

        with open(self.recdir + "/" + vehicle + "_commands.rec", "w") as rec:

            # generate a simple file header
            self.__write_header(rec)

            # determine and define a new export system
            if export_system is not None:
                rec.write("export System " + export_system + "(cmd) {\n\n")

            # generate a command record for each sequence container
            for sc in seq_containers.values():

                # ignore abstract command containers
                if sc.get("abstract"):
                    continue

                # expand out the base containers to discover inherited parameters
                params, restrictions = self.cnt.expand_base_container(sc, abstract_seq_containers, list(), dict())

                # begin the command packet record definition
                dest = export_system + "CmdDest" if export_system is not None and not single_pil else "CmdDest"
                rec.write(indent + "CFECommandPacket " + sc.get("name") + " {\n")
                rec.write(indent + "\tdestination=" + dest + "\n")

                # define the command criticality
                if "criticality" in sc:
                    rec.write(indent + "\tcriticality=\"" + sc.get("criticality") + "\"\n")

                # define the ccsds apid and command code
                rec.write(indent + "\tapplicationId{ range=" + self.cnt.get_apid(restriction_list=restrictions) + " }\n")
                rec.write(indent + "\tcmdCode{ range=" + self.cnt.get_cmdcode(restriction_list=restrictions) + " }\n")

                # create a record for each parameter in the sequence container
                for p in params:
                    if p.get("type") in abstract_seq_containers:
                        self.abs_cmd.append(p.get("type"))
                    mnemonic_stmt = export_system + "." if export_system is not None else ""
                    self.__write_param_record(rec, "cmd", sc, p, abstract_seq_containers, parameter_types, host, indent)
                rec.write(indent + "}\n\n")

                # record command packet statistics
                self.num_cmd_pkts += 1

            # close the exported system definition if necessary
            if export_system is not None:
                rec.write("}\n")




    def __generate_import_recfile(self, vehicle, import_system, num_limits=0):
        """
        Tell ITOS about the system with a unique namespace.
        """
        # determine if a limits recfile import is necessary
        limits = ", limits" if num_limits > 0 else ""

        with open(self.recdir + "/" + vehicle + ".rec", "w") as rec:
            self.__write_header(rec)
            rec.write("import System " + import_system + "(types, tlm, cmd" + limits + ")\n")




    def __write_param_record(self, rec, rec_class, sc, p, abstract_seq_containers, parameter_types, host, indent):
        """
        """
        rectype = ""
        enumeration = ""
        string_length = ""
        genmnemonic = ""
        clock = ""
        units = ""

        # ignore the CCSDS parameters ITOS defines natively
        if "ccsds" in p.get("type"):
            return

        # define the parameter limits
        limit = " limit=" + p.get("limit") + " " if "limit" in p else ""

        # define the parameter conversion
        conversion = " conversion=" + p.get("conversion") + " " if "conversion" in p else ""

        # define the raw parameter units
        if "units" in p:
            units = " units=\"" +  p.get("units") + "\" "

        # override the raw units with the conversion units if defined
        if "conversion" in p:
            units = " units=\"" + self.conversions.get(p.get("conversion")).get("conversion_units") + "\" "

        # use the command parameter mnemonic if this is a command parameter
        name = p.get("mnemonic") if "cmd" in rec_class and "mnemonic" in p else p.get("name")

        # don't generate mnemonics for byte alignment parameters.. unless it's in a command packet
        if "pad" in name.lower() or "spare" in name.lower() and "cmd" not in rec_class:
            genmnemonic = " generateMnemonic=\"no\" "

        # use the parameter type name directly as the record type if it is an abstract container (prototype structure)
        if p.get("type") in abstract_seq_containers.keys():
            rectype = p.get("type")

        # otherwise generate a primitive ITOS record type from the primitive data type
        else:
            ptype = parameter_types[p.get("type")]
            rectype, gbl_rectype = pytos.util.get_record_type(ptype, byteorder=self.cnt.get_byte_order(p, host=host), host=host)

            if "length_in_characters" in ptype and "TIME" not in rectype:
                string_length = " lengthInCharacters=" + str(ptype.get("length_in_characters")) + " "

            # define the time encoded clock source
            if "TIME" in rectype:
                clock = " clock=cfe_time "

            # generate the appropriate enumeration
            if "enumeration_list" in ptype:
                if rec_class == "tlm":
                    self.__add_enumeration(ptype, cmd=False, tlm=True)
                    enumeration = " conversion=" + ptype.get("name").upper() + "_DSC "
                elif rec_class == "cmd":
                    self.__add_enumeration(ptype, cmd=True, tlm=False)
                    enumeration = " enumeration=" + ptype.get("name").upper() + "_ENUM "
                elif rec_class == "types":
                    if sc.get("name") in self.abs_tlm:
                        self.__add_enumeration(ptype, cmd=False, tlm=True)
                        enumeration = " conversion=" + ptype.get("name").upper() + "_DSC "
                    if sc.get("name") in self.abs_cmd:
                        self.__add_enumeration(ptype, cmd=True, tlm=False)
                        enumeration = " enumeration=" + ptype.get("name").upper() + "_ENUM "

        dimensions = self.__get_rec_dimensions(p)
        rec.write(indent+"\t" + rectype  + " " + name + dimensions + " {" + genmnemonic + enumeration + string_length + clock + limit + conversion + units + "}\n")

        # record parameter statistics
        ndimensions = 0
        if "dimensions" in p:
            for d in p.get("dimensions"):
                ndimensions += d.get("len")
        else:
            ndimensions = 1
        self.num_params += ndimensions




    def __generate_global_mnemonics(self, vehicle, namespace=None):
        """
        Go through all the sequence containers and find/create unuqie global mnemonics for each parameter.
        """
        global_mnemonics = dict()
        tlm_sc = self.cnt.get_telemetry_sequence_containers(vehicle)
        abstract_sc = self.cnt.get_abstract_sequence_containers(vehicle)
        param_types = self.cnt.get_parameter_types(vehicle)

        for sc in tlm_sc.values():
            if sc.get("abstract") is True:
                continue

            if sc.get("name") not in global_mnemonics:
                global_mnemonics[sc.get("name")] = dict()
                global_mnemonics[sc.get("name")]["vehicle"] = vehicle
                global_mnemonics[sc.get("name")]["namespace"] = namespace
                global_mnemonics[sc.get("name")]["description"] = sc.get("description")
                global_mnemonics[sc.get("name")]["paramtypes"] = param_types
                global_mnemonics[sc.get("name")]["max_mnem_len"] = 0
                global_mnemonics[sc.get("name")]["parameters"] = collections.OrderedDict()

            # determine the base global mnemonic prefix
            gbl_mnem = sc.get("base_mnemonic") + "_" if "base_mnemonic" in sc else ""

            # expand out the base containers to discover inherited parameters
            params, restrictions = self.cnt.expand_base_container(sc, abstract_sc, list(), dict())

            for p in params:

                # ignore the inherited CCSDS header fields
                if "ccsds" in p.get("type"):
                    continue

                mnemonic_stmt = namespace + "." if namespace is not None else ""
                mnemonic_stmt += sc.get("name")
                pytos.util.dereference_leaf_mnemonic(global_mnemonics, sc.get("name"), p, abstract_sc, mnemonic_stmt, gbl_mnem)

        # write out the recfile's global mnemonics
        self.__dump_global_mnemonics(vehicle, global_mnemonics)





    def __dump_global_mnemonics(self, vehicle, mnemonics, prefix=""):
        """
        Output a recfile for each vehicle that contains all the global mnemonics defined by the C&T dictionary.
        """
        vname = str(vehicle).lower().replace("-", "")
        prefix = "SIM_" if "sim" in vehicle.lower() else ""

        with open(self.recdir + "/" + vname + "_gbl.rec", "w") as recfile:

            self.__write_header(recfile)

            for sc in mnemonics:

                description = mnemonics.get(sc).get("description")
                mnem_len = mnemonics.get(sc).get("max_mnem_len")

                for p in mnemonics.get(sc).get("parameters"):

                    for gbl in mnemonics.get(sc).get("parameters").get(p):

                        for i, recmap in enumerate(mnemonics.get(sc).get("parameters").get(p).get(gbl)):
                            param = recmap.get("param")
                            long_mnemonic = recmap.get("record")
                            ptype = mnemonics.get(sc).get("paramtypes")[param.get("type")]
                            rectype, gbl_rectype = pytos.util.get_record_type(ptype, byteorder=self.cnt.get_byte_order(p))
                            conversion = " conversion=" + ptype.get("name").upper() + "_DSC " if ptype.get("base_type") == "enumeration" else ""

                            vector_index = ""
                            if len(mnemonics.get(sc).get("parameters").get(p).get(gbl)) > 1:
                                vector_index = "_" + str(i)

                            if len(gbl) > 0:
                                recfile.write(gbl_rectype + " " + prefix + gbl + vector_index  + " { sourceFields={" + long_mnemonic + "}" + conversion + " }\n")

                                # record global mnemonic statistics
                                self.num_global_mnemonics += 1




    def __generate_limit_recs(self, vehicle, limits, export_system=None):
        """
        """
        # don't generate empty recfiles
        if len(limits) == 0:
            return

        # determine record indentation
        indent = "\t" if export_system is not None else ""

        with open(self.recdir + "/" + vehicle + "_limits.rec", "w") as rec:

            # generate a simple file header
            self.__write_header(rec)

            # determine and define a new export system
            if export_system is not None:
                rec.write("export System " + export_system + "(limits) {\n\n")

            # generate a limits record for each C&T limit definition
            for l in limits.values():

                rec.write(indent + "Limit " + l.get("name") + "{\n")
                rec.write(indent + "\tredLow=" + str(l.get("critical_low")) + "\n")
                rec.write(indent + "\tyellowLow=" + str(l.get("dangerous_low")) + "\n")
                rec.write(indent + "\tyellowHigh=" + str(l.get("dangerous_high")) + "\n")
                rec.write(indent + "\tredHigh=" + str(l.get("critical_high")) + "\n")
                rec.write(indent + "}\n\n")

            # close the exported system definition if necessary
            if export_system is not None:
                rec.write("}\n")




    def __add_enumeration(self, param_type, cmd=False, tlm=False):
        """
        """
        enum = copy.deepcopy(param_type)


        if enum.get("name") not in self.enums.keys():
            enum["cmd"] = False
            enum["tlm"] = False
            self.enums[enum.get("name")] = enum

        if tlm:
            self.enums[enum.get("name")]["tlm"] = True

        if cmd:
            self.enums[enum.get("name")]["cmd"] = True






    def __dump_enumerations_recfile(self):
        """
        """
        with open(self.recdir + "/enumerations.rec", "w") as rec:
            self.__write_header(rec)

            for e in self.enums.values():

                # generate a command enumeration
                if e.get("cmd") is True:
                    rec.write("Enumeration " + e.get("name").upper() + "_ENUM {\n")
                    for v in e.get("enumeration_list"):
                        rec.write("\tEnumerationValue " + v.get("label").upper() + " {value=" + str(v.get("value")) + "}\n")
                    rec.write("}\n\n")

                # generate a discrete conversion
                if e.get("tlm"):
                    rec.write("DiscreteConversion " + e.get("name").upper() + "_DSC {\n")
                    for v in e.get("enumeration_list"):

                        # determine display colors for the discrete conversion
                        bgcolor = "black" if "bgcolor" not in v else v.get("bgcolor")
                        fgcolor = "green" if "fgcolor" not in v else v.get("fgcolor")
                        rec.write("\tDsc " + v.get("label").upper() + " { range=" + str(v.get("value")) + " bgColor=" + bgcolor + " fgColor=" + fgcolor + " }\n")

                    rec.write("}\n\n")




    def __dump_conversions_recfile(self):
        """
        """
        with open(self.recdir + "/conversions.rec", "w") as rec:
            self.__write_header(rec)

            for c in self.data_conversions:

                # generate a documentation comment
                self.__add_comment(rec, c.get("description"), next_record=False)
                if "expression_comment" in c:
                    self.__add_comment(rec, c.get("expression_comment"), next_record=False)

                # generate an ExpressionConversion record
                rec.write("ExpressionConversion " + c.get("name") + "{\n")
                rec.write("\texpression=\"" + c.get("conversion_expression") + "\"\n")
                rec.write("}\n\n")



    def __get_rec_dimensions(self, param):
        """
        """
        dim_string = ""
        if "dimensions" in param:
            for d in reversed(param.get("dimensions")):
                dim_string = dim_string + "[" + str(d.get("len")) + "]"

        return dim_string





    def __add_comment(self, recfile, comment, next_record=True):
        """ Adds a comment to the specified rec file.

        next_record indicates whether the comment refers to the next or previous record listed in the file.
        """
        direction = " "

        if next_record:
            direction = "--> "

        recfile.write("/**" + direction + comment + " **/\n")




    def __write_header(self, recfile):
        """
        Writes a comment to the recfile letting users know the file was autogenerated
        """
        self.__add_comment(recfile, "DO NOT EDIT: autogenerated from the Moon Express C&T dictionary", next_record=False)
        recfile.write("\n")




    def __generate_static_recfiles(self):
        """
        Generates statically defined rec files that would be a little tricky to autogenerate from the JSON C&T dictionary.
        """
        with open(self.recdir + "/prototypes.rec", "w") as rec:
            self.__write_header(rec)
            rec.write("prototype CCSDSTelemetryPacket CFETelemetryPacket {\n")
            rec.write("\ttimeout=\"5\"\n")
            rec.write("\ttimeStamp=timestamp\n")
            rec.write("\ttype             { range=1 }\n")
            rec.write("\tsecondary        { range=1 }\n")
            rec.write("\tTIME42 timestamp { clock=cfe_tlm_time }\n")
            rec.write("}\n\n")
            rec.write("prototype CCSDSCommandPacket CFECommandPacket {\n")
            rec.write("\tsecondary   { range=1 }\n")
            rec.write("\tU12 cmdReserved { lengthInBits=1, range=0, generateMnemonic=\"no\" }\n")
            rec.write("\tU12 cmdCode { lengthInBits=7 }\n")
            rec.write("\tU12 cmdChecksum { lengthInBits=8, range=0}\n")
            rec.write("}\n")

        with open(self.recdir + "/clocks.rec", "w") as rec:
            self.__write_header(rec)
            rec.write("Clock cfe_time {\n")
            rec.write("\tepoch = \"2000-001-12:00:00.000\"\n")
            rec.write("\tsubsecondsPerSecond = 1000000\n")
            rec.write("}\n\n")
            rec.write("Clock cfe_tlm_time {\n")
            rec.write("\tepoch = \"2000-001-12:00:00.000\"\n")
            rec.write("\tsubsecondsPerSecond = 0xFFFF\n")
            rec.write("}\n")



    def generate_command_graph(self, phil, sim=False, export_system="", command_console=False):
        """
        """
        host_option = "simHostname" if sim else "hostname"
        addr_option = "simIPAddress" if sim else "IPAddress"

        host = self.philconfig.get_config(phil, host_option)
        ipaddress = self.philconfig.get_config(phil, addr_option) if command_console else "0.0.0.0"
        port = self.philconfig.get_config(phil, "commandPort") if command_console else "0000"
        graphtype = "" if command_console else "dummy "

        print ("  Populating " + graphtype + "command graph rec file for " + host)

        with open(self.recdir + "/" + host+"_cmd_graph.rec", "w") as rec:
            rec.write("CommandDestination " + export_system + "CmdDest {\n")
            rec.write("\tport=" + export_system + "CmdGraph.dyn.input\n")
            rec.write("}\n\n")

            # define the command graph and its component connections
            rec.write("Graph " + export_system + "CmdGraph {\n")
            rec.write("\tconnections={\n")
            rec.write("\t\tPortConnection { p1=dyn.output p2=stolEcho.input }\n")
            rec.write("\t\tPortConnection { p1=stolEcho.output p2=hilSwitch.input }\n")
            rec.write("\t\tPortConnection { p1=hilSwitch.deadEnd p2=deadEnd.input }\n")
            rec.write("\t\tPortConnection { p1=hilSwitch." + host + " p2=" + host + ".input }\n")
            rec.write("\t}\n\n")

            # define the graph components
            rec.write("\titos.graph.GenerateDynamicFieldsComponent.Type dyn{}\n")
            rec.write("\titos.graph.EchoComponent.Type stolEcho{}\n")
            rec.write("\titos.graph.DeadEndComponent.Type deadEnd{}\n")

            rec.write("\titos.graph.SwitchComponent.Type hilSwitch {\n")
            rec.write("\t\tconfiguration{\n")
            rec.write("\t\t\tactive_port { initialValue=\"deadEnd\"}\n")
            rec.write("\t\t\toutput_port_name[0] { initialValue=\"deadEnd\"}\n")
            rec.write("\t\t\toutput_port_name[1] { initialValue=\"" + host + "\"}\n")
            rec.write("\t\t}\n")
            rec.write("\t\tGraphNodePort deadEnd {}\n")
            rec.write("\t\tGraphNodePort " + host + " {}\n")
            rec.write("\t}\n")

            rec.write("\titos.graph.UDPSocketComponent.Type " + host + " {\n")
            rec.write("\t\tconfiguration{\n")
            rec.write("\t\t\tassociate_on_start { initialValue=0 }\n")
            rec.write("\t\t\tforeign_host { initialValue=\"" + ipaddress + "\"}\n")
            rec.write("\t\t\tforeign_port { initialValue=\"" + port + "\"}\n")
            rec.write("\t\t}\n")
            rec.write("\t}\n")
            rec.write("}\n\n")

            rec.write("Alias set_" + host + " {source=" + export_system + "CmdGraph.hilSwitch.set_active_port}\n\n")


