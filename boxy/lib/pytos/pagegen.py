
import os, json, copy, itertools, collections
from cntutil import CNTUtil
import pytos.util


class PageGen(object):

    """The PageGen module converts the MoonEx C&T JSON dictionary into ITOS page files."""

    def __init__(self, page_dir, master_page_name="autogen", verbose=False):
        """
        """
        self.cnt = CNTUtil(cnt_path=os.path.expandvars("$BENDER_PATH/clamps/moonex_cnt_dictionary.json"))
        self.pagedir = os.path.abspath(page_dir)
        self.enums = list()
        self.masterpage = master_page_name
        self.master_buttons = collections.OrderedDict()
        self.pages = collections.OrderedDict()
        self.color_stmt = "color ( banner (cyan, default) button (white, white) )\n\n"
        self.vehicle = ""
        self.verbose = verbose



    def __del__(self):
        """
        """
        # create the output directory if it doesn't exist
        try:
            os.makedirs(self.pagedir)
        except OSError as e:
            pass

        self.__dump_master_page()
        self.__dump_vehicle_pages()




    def generate_vehicle_pages(self, vehicle, namespace=None):
        """
        """
        self.cnt.discover_space_system(self.cnt.get_root(), vehicle)
        if vehicle not in self.cnt.get_discovered_systems():
            raise Exception("vehicle \"" + vehicle + "\" not found in C&T dictionary")

        print ("  Populating PAGE files for " + vehicle)
        vname = str(vehicle).lower().replace("-", "")
        tlm_sc = self.cnt.get_telemetry_sequence_containers(vehicle)
        abstract_sc = self.cnt.get_abstract_sequence_containers(vehicle)
        param_types = self.cnt.get_parameter_types(vehicle)

        for sc in tlm_sc.values():
            if sc.get("abstract") is True:
                continue
            if self.verbose:
                print ("    generating page " + sc.get("name") + "...")
            self.__add_master_page_button(vname, sc.get("name"))
            self.__add_mnemonic_statements(vname, vname + "_" + sc.get("name"), sc, abstract_sc, param_types, namespace=namespace)




    def __dump_master_page(self):
        """
        """
        with open(self.pagedir + "/" + self.masterpage + ".page", "w") as master:
            master.write("page " + self.masterpage + "\n\n")
            master.write(self.color_stmt)
            master.write("banner (1, 1, \"Telemetry Packet Pages\")\n\n")

            xpos = 1
            ypos = 4
            for veh in self.master_buttons.keys():
                master.write("banner (3, " + str(xpos) +  ", \"" + veh.upper() + "\")\n\n")
                for pkt in sorted(self.master_buttons.get(veh)):
                    if "CFE_EVS_Packet_t" in pkt:
                        continue
                    master.write("button " + veh + "_" + pkt + "_button (" + str(ypos) + ", " + str(xpos) + ", \"" + pkt + "\", \"page " + veh + "_" + pkt + "\")\n")
                    ypos += 1
                    if ypos > 33:
                        ypos = 4
                        xpos += 30
                ypos = 4
                xpos += 30



    def __dump_vehicle_pages(self):
        """
        """
        for p in self.pages.keys():

            # generate sequential prints for event messages
            if "CFE_EVS_Packet_t" in p:
                self.__dump_event_seqprint(p)
                continue

            with open(self.pagedir + "/" + p + ".page", "w") as page:

                vehicle = self.pages.get(p).get("vehicle")
                param_types = self.pages.get(p).get("paramtypes")
                description = self.pages.get(p).get("description")
                mnem_len = self.pages.get(p).get("max_mnem_len")
                namespace = ""
                if self.pages.get(p).get("namespace") is not None:
                    namespace = self.pages.get(p).get("namespace") + "."

                # write out the page header
                page.write("page " + p + "\n\n")
                page.write(self.color_stmt)
                page.write("banner (1, 1, \"" + vehicle.upper() + " " + p.replace(vehicle + "_", "") + ": " + description + "\")\n\n")

                # add the CCSDS packet timestamp as the first mnemonic
                page.write("GBL_GMTOFF (+, 1, \"GMT::       :v%22T:\")\n")
                page.write(namespace + p.replace(vehicle + "_", "") + ".timestamp (+, 1, \"Timestamp:: :v%22T:\")\n")

                # determine the global mnemonic prefix
                prefix = "SIM_" if "sim" in vehicle.lower() else ""

                xpos = 1
                ypos = 5
                for paramname in self.pages.get(p).get("parameters"):

                    for gbl in self.pages.get(p).get("parameters").get(paramname):

                        for i, recmap in enumerate(self.pages.get(p).get("parameters").get(paramname).get(gbl)):
                            param = recmap.get("param")
                            mnemonic = gbl if len(gbl) > 0 else recmap.get("record")

                            # add the vehicle prefix to global mnemonics
                            if len(gbl) > 0:
                                mnemonic = prefix + mnemonic

                            vector_index = ""
                            if len(self.pages.get(p).get("parameters").get(paramname).get(gbl)) > 1 and len(gbl) > 0:
                                vector_index = "_" + str(i)

                            mnemonic = mnemonic + vector_index

                            display_mnemonic = mnemonic.split('.')[-1]

                            page.write(mnemonic + " (" + str(ypos) + ", " + str(xpos) + ", " + self.__get_format_string(38, param, param_types, display_mnemonic) + ")\n")
                            ypos += 1
                            if ypos > 44:
                                ypos = 5
                                xpos += 50




    def __dump_event_seqprint(self, pagename):
        """
        Generates sequential print with formatting specific to viewing cFE events in ITOS event window.
        Uses CFE_EVS_Packet_t global mnemonics.
        """
        vehicle = self.pages.get(pagename).get("vehicle")
        namespace = self.pages.get(pagename).get("namespace")
        param_types = self.pages.get(pagename).get("paramtypes")
        prefix = ""

        if "sim" in vehicle:
            sprt = "sim_event_log"
            prefix = "SIM_"
        else:
            sprt = "event_log"

        with open(self.pagedir + "/" + sprt + ".sprt", "w") as sp:

            # write out the sequential print header
            sp.write("seqprt " + sprt + "\n\n")

            # write out the timestamp mnemonic
            ns = ""
            if namespace is not None:
                ns = namespace + "."
            sp.write(ns + pagename.replace(vehicle + "_", "") +  ".timestamp (1, \":value%D:\")\n")

            # note: clean this up later
            params = self.pages.get(pagename).get("parameters")
            for p, v in params.items():
                for g in v:
                    thing = params.get(p).get(g)
                    for x in thing:
                        param = x.get("param")

                    if "name" in g.lower():
                        sp.write(prefix+g + " (+2, \"" + vehicle.upper() + ":: :value%-" + str(param_types.get(param.get("type")).get("length_in_characters")) + "s:\")\n")
                    elif "eventid" in g.lower():
                        sp.write(prefix+g + " (+, \"" + ":value%3d:\")\n")
                    elif "eventtype" in g.lower():
                        sp.write(prefix+g + " (+7, \"" + ":value%-8s:\")\n")
                    elif g.lower() == "evs_event":
                        sp.write(prefix+g + " (+2, \"" + ":value%-" + str(param_types.get(param.get("type")).get("length_in_characters")) + "s:\")\n")




    def __add_mnemonic_statements(self, vehicle, pagename, sc, abstract_seq_containers, param_types, namespace=None):
        """
        """
        # generate a page entry if the pagename does not exist in the collection of pages
        if pagename not in self.pages:
            self.pages[pagename] = dict()
            self.pages[pagename]["vehicle"] = vehicle
            self.pages[pagename]["namespace"] = namespace
            self.pages[pagename]["description"] = sc.get("description")
            self.pages[pagename]["paramtypes"] = param_types
            self.pages[pagename]["max_mnem_len"] = 0
            self.pages[pagename]["parameters"] = collections.OrderedDict()

        # expand out the base containers to discover inherited parameters
        params, restrictions = self.cnt.expand_base_container(sc, abstract_seq_containers, list(), dict())

        # determine the base global mnemonic prefix
        gbl_mnem = sc.get("base_mnemonic") + "_" if "base_mnemonic" in sc else ""

        for p in params:

            # ignore the inherited CCSDS header fields
            if "ccsds" in p.get("type"):
                continue

            mnemonic_stmt = "" if namespace is None else namespace + "."
            mnemonic_stmt += sc.get("name")
            pytos.util.dereference_leaf_mnemonic(self.pages, pagename, p, abstract_seq_containers, mnemonic_stmt, gbl_mnem)




    def __gen_mnemonic_statement(self, pagename, param, abstract_seq_containers, mnemonic_stmt):
        """
        """
        # ignore padding and spare byte definitions
        if "pad" in param.get("name").lower() or "spare" in param.get("name").lower():
            return

        # base case: dereference mnemonics until the parameter type is primitive
        if param.get("type") not in abstract_seq_containers:
            mnemonic_stmt += "." + param.get("name")
            derefs = pytos.util.get_array_index_permutations(param)

            # write out the non-array parameter to the page
            if len(derefs) == 0:
                self.__add_mnem_stmt(pagename, mnemonic_stmt, param)
                return

            # write out a mnemonic statement for each index permutation of the array parameter
            for d in derefs:
                index = ""
                for i in d:
                    index += "[" + str(i) + "]"
                self.__add_mnem_stmt(pagename, mnemonic_stmt + index, param)

            return

        # not a leaf parameter so continue dereferencing the structure
        mnemonic_stmt += "." + param.get("name")
        for subp in abstract_seq_containers.get(param.get("type")).get("parameters"):
            derefs = pytos.util.get_array_index_permutations(param)

            if len(derefs) > 0:
                for d in derefs:
                    index = ""
                    for i in d:
                        index += "[" + str(i) + "]"
                    self.__gen_mnemonic_statement(pagename, subp, abstract_seq_containers, mnemonic_stmt + index)
            else:
                self.__gen_mnemonic_statement(pagename, subp, abstract_seq_containers, mnemonic_stmt)




    def __add_mnem_stmt(self, pagename, mnem, param):
        """
        """
        # map the mnemonic entry for the page to its parameter definition
        self.pages.get(pagename).get("parameters")[mnem] = param

        # keep track of the longest mnemonic length to format even columns on the page
        if len(mnem) > self.pages.get(pagename).get("max_mnem_len"):
            self.pages.get(pagename)["max_mnem_len"] = len(mnem)




    def __get_format_string(self, mnem_len, param, param_types, display_mnemonic):
        """
        """
        mnem_format = "%-" + str(mnem_len) + "s"
        param_format = "\"" + (mnem_format % (display_mnemonic,)) + " "
        ptype = param_types.get(param.get("type"))

        # fallback to defalut display format
        display_format = ":v:"

        # display floating point values nicely
        if ptype.get("base_type") == "float":
            display_format = ":v%12.5f:"

        # display signed/unsigned integers nicely
        elif ptype.get("base_type") == "integer":
            display_format = ":v%10d:" if ptype.get("signed") else ":v%10u:"

        # display discrete conversions as strings
        elif ptype.get("base_type") == "enumeration":
            display_format = ":v%16s:"

        # display pointer parameter types in hex
        elif ptype.get("base_type") == "pointer":
            display_format = ":v%X:"

        param_format += display_format + "\""
        return param_format




    def __add_master_page_button(self, vehicle, page_name):
        """
        """
        if vehicle not in self.master_buttons:
            self.master_buttons[vehicle] = list()

        self.master_buttons[vehicle].append(page_name)


