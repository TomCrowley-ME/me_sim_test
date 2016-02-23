import json, collections
from copy import deepcopy


class CNTUtil(object):

    """A utility class providing an API to the MoonEx C&T JSON dictionary"""

    def __init__(self, cnt_path=None, cnt_dict=None):
        """
        """
        self.discovered_systems = collections.OrderedDict()

        if cnt_path is not None:
            with open(cnt_path) as c:
                try:
                    # load the json dictionary and grab the top-level space_system
                    self.root = json.load(c)

                except Exception as e:
                    raise Exception ("Error parsing JSON document: " + str(e))

        elif cnt_dict is not None:
            self.root = cnt_dict

        else:
            raise Exception ("ERROR: C&T dictionary not provided as file path or object")




    def discover_all_space_systems(self, root_space_system):
        """
        Recursively traverse the system tree and populate each system's inherited properties.
        """
        self.discover_space_system(self.root, root_space_system.get("space_system").get("name"))

        # check for leaf as recursive base case
        if "sub_systems" not in root_space_system.get("space_system"):
            return

        # recursively discover subsystems
        for ss in root_space_system.get("space_system").get("sub_systems"):
            self.discover_all_space_systems(ss)




    def discover_space_system(self, root_space_system, system_name):
        """
        Perfrom a breadth-first search of the space system tree and generate an inheritence mapping of the given system.
        """
        # create a queue of tree paths and enqueue the root node
        queue = list()
        queue.append([root_space_system])

        # explore the tree until the queue is empty
        while queue:
            path = queue.pop(0)
            node = path[-1]

            # when the node is found, populate its properties from the discovered path
            if node.get("space_system").get("name") == system_name:
                self.__populate_inherited_properties(system_name, path)
                return

            # ignore dead-end leaves
            if "sub_systems" not in node.get("space_system"):
                continue

            # explore each adjecent node and keep track of the traversal path
            for adjacent in node.get("space_system").get("sub_systems"):
                new_path = list(path)
                new_path.append(adjacent)
                queue.append(new_path)




    def __populate_inherited_properties(self, system_name, system_path):
        """
        Map all the properties inherited by the given system through the given system tree path.
        """
        cmn = collections.OrderedDict()
        tlm = collections.OrderedDict()
        cmd = collections.OrderedDict()
        abstract_scs = collections.OrderedDict()
        paramtypes = collections.OrderedDict()
        limits = collections.OrderedDict()
        conversions = collections.OrderedDict()
        constants = collections.OrderedDict()
        description = system_path[-1].get("space_system").get("description")
        host = None

        # populate the list with parent sequence containers
        for p in system_path:
            system = p.get("space_system")

            # find all inherited common data
            if "common_data" in system:
                # save each parameter type
                if "parameter_types" in system.get("common_data"):
                    for t in system.get("common_data").get("parameter_types"):
                        paramtypes[t.get("name")] = t
                # save each common sequence container
                if "sequence_containers" in system.get("common_data"):
                    for c in system.get("common_data").get("sequence_containers"):
                        cmn[c.get("name")] = c
                        if c.get("abstract") is True:
                            abstract_scs[c.get("name")] = c
                # save each data conversion
                if "conversions" in system.get("common_data"):
                    for c in system.get("common_data").get("conversions"):
                        conversions[c.get("name")] = c
                # save each constant definition
                if "constants" in system.get("common_data"):
                    for c in system.get("common_data").get("constants"):
                        constants[c.get("name")] = c

            # find all inherited telemetry data
            if "telemetry_data" in system:
                # save each telemetry sequence container
                if "sequence_containers" in system.get("telemetry_data"):
                    for c in system.get("telemetry_data").get("sequence_containers"):
                        tlm[c.get("name")] = c
                        if c.get("abstract") is True:
                            abstract_scs[c.get("name")] = c
                # save each telemetry limit definition
                if "limits" in system.get("telemetry_data"):
                    for l in system.get("telemetry_data").get("limits"):
                        limits[l.get("name")] = l

            # find all inherited command data
            if "command_data" in system:
                # save each command sequence container
                if "sequence_containers" in system.get("command_data"):
                    for c in system.get("command_data").get("sequence_containers"):
                        cmd[c.get("name")] = c
                        if c.get("abstract") is True:
                            abstract_scs[c.get("name")] = c

            # find the leaf-most parent host description
            if "host" in system:
                host = system.get("host")


        # add the space system to the discovery list
        self.discovered_systems[system_name] = collections.OrderedDict()
        self.discovered_systems[system_name]["description"] = description
        self.discovered_systems[system_name]["parameter_types"] = paramtypes
        self.discovered_systems[system_name]["limits"] = limits
        self.discovered_systems[system_name]["conversions"] = conversions
        self.discovered_systems[system_name]["constants"] = constants
        self.discovered_systems[system_name]["host"] = host
        self.discovered_systems[system_name]["sequence_containers"] = collections.OrderedDict()
        self.discovered_systems[system_name]["sequence_containers"]["abstract"] = abstract_scs
        self.discovered_systems[system_name]["sequence_containers"]["common"] = cmn
        self.discovered_systems[system_name]["sequence_containers"]["telemetry"] = tlm
        self.discovered_systems[system_name]["sequence_containers"]["command"] = cmd





    def get_root(self):
        """
        Returns a new reference to the raw C&T dictionary root system.
        """
        return deepcopy(self.root)



    def get_discovered_systems(self):
        """
        Returns a list of discovered space system names.
        """
        return self.discovered_systems.keys()



    def get_host(self, space_system_name):
        """
        Returns the host JSON document of the given system as a dictionary.
        """
        try:
            return deepcopy(self.discovered_systems.get(space_system_name).get("host"))

        except KeyError as e:
            raise Exception ("Failed to find host definition for " + space_system_name + ": " + str(e))



    def get_parameter_types(self, space_system_name):
        """
        Returns a dictionary mapping each of the given system's parameter type names to their raw JSON definitions.
        """
        try:
            return deepcopy(self.discovered_systems.get(space_system_name).get("parameter_types"))

        except KeyError as e:
            raise Exception ("Failed to find parameter types for " + space_system_name + ": " + str(e))



    def get_telemetry_limits(self, space_system_name):
        """
        Returns a dictionary mapping each of the given system's telemetry limit names to their raw JSON definitions.
        """
        try:
            return deepcopy(self.discovered_systems.get(space_system_name).get("limits"))

        except KeyError as e:
            raise Exception ("Failed to find telemetry limits for " + space_system_name + ": " + str(e))



    def get_data_conversions(self, space_system_name):
        """
        Returns a dictionary mapping each of the given system's data conversion names to their raw JSON definitions.
        """
        try:
            return deepcopy(self.discovered_systems.get(space_system_name).get("conversions"))

        except KeyError as e:
            raise Exception ("Failed to find data conversions for " + space_system_name + ": " + str(e))



    def get_constants(self, space_system_name):
        """
        Returns a dictionary mapping each of the given system's constant definition names to their raw JSON definitions.
        """
        try:
            return deepcopy(self.discovered_systems.get(space_system_name).get("constants"))

        except KeyError as e:
            raise Exception ("Failed to find constants for " + space_system_name + ": " + str(e))



    def get_abstract_sequence_containers(self, space_system_name):
        """
        Returns a dictionary mapping each of the given system's abstract sequence container names to their raw JSON definitions.
        """
        try:
            return deepcopy(self.discovered_systems.get(space_system_name).get("sequence_containers").get("abstract"))

        except KeyError as e:
            raise Exception ("Failed to find abstract sequence containers for " + space_system_name + ": " + str(e))



    def get_common_sequence_containers(self, space_system_name):
        """
        Returns a dictionary mapping each of the given system's common sequence container names to their raw JSON definitions.
        """
        try:
            return deepcopy(self.discovered_systems.get(space_system_name).get("sequence_containers").get("common"))

        except KeyError as e:
            raise Exception ("Failed to find common sequence containers for " + space_system_name + ": " + str(e))



    def get_telemetry_sequence_containers(self, space_system_name):
        """
        Returns a dictionary mapping each of the given system's telemetry sequence container names to their raw JSON definitions.
        """
        try:
            return deepcopy(self.discovered_systems.get(space_system_name).get("sequence_containers").get("telemetry"))

        except KeyError as e:
            raise Exception ("Failed to find telemetry sequence containers for " + space_system_name + ": " + str(e))



    def get_command_sequence_containers(self, space_system_name):
        """
        Returns a dictionary mapping each of the given system's command sequence container names to their raw JSON definitions.
        """
        try:
            return deepcopy(self.discovered_systems.get(space_system_name).get("sequence_containers").get("command"))

        except KeyError as e:
            raise Exception ("Failed to find command sequence containers for " + space_system_name + ": " + str(e))



    def get_cnt_statistics(self, space_system_name):
        """
        Returns a tuple of statistics for the given system's inherited data.
        Return tuple format:
            (# command containers, # telemetry containers, # parameter types, # limits, # conversions, # constants)
        """
        try:
            cmd = self.discovered_systems.get(space_system_name).get("sequence_containers").get("command")
            tlm = self.discovered_systems.get(space_system_name).get("sequence_containers").get("telemetry")
            ptypes = self.discovered_systems.get(space_system_name).get("parameter_types")
            limits = self.discovered_systems.get(space_system_name).get("limits")
            conversions = self.discovered_systems.get(space_system_name).get("conversions")
            constants = self.discovered_systems.get(space_system_name).get("constants")

            return (len(cmd), len(tlm), len(ptypes), len(limits), len(conversions), len(constants))

        except KeyError as e:
            raise Exception ("Failed to find C&T statistics for " + space_system_name + ": " + str(e))



    def get_apid(self, base=None, restriction_list=None):
        """
        Returns the apid of the given base JSON document as a hex string.
        """
        try:
            if base is not None:
                for p in base.get("restriction_criteria"):
                    if p.get("parameter_ref") == "apid":
                        return str(hex(p.get("value")))

            if restriction_list is not None:
                return str(hex(restriction_list.get("apid")))

        except Exception as e:
            raise Exception("failed to find apid restriction criteria in base container reference")



    def get_cmdcode(self, base=None, restriction_list=None):
        """
        Returns the command code of the given base JSON document as a hex string.
        """
        try:
            if base is not None:
                for p in base.get("restriction_criteria"):
                    if p.get("parameter_ref") == "cmd_function_code":
                        return str(hex(p.get("value")))

            if restriction_list is not None:
                return str(hex(restriction_list.get("cmd_function_code")))

        except Exception as e:
            raise Exception("failed to find command code restriction criteria in base container reference")



    def dump_space_systems(self):
        """
        Prints out a list of discovered space_systems and their descriptions.
        """
        try:
            print ("\n=== Space Systems / Vehicles ===")
            for s in self.discovered_systems:
                description = self.discovered_systems.get(s).get("description")
                print ("  " + s + ": " + str(description).rjust((15 + len(description)) - len(s)))
            print ("\n")

        except Exception as e:
            raise Exception("failed to dump the discoverd space_system list")



    def expand_base_container(self, sc, abstract_seq_containers, parameters, restrictions):
        """
        """
        try:
            # track the parameters found in each base
            for p in reversed(sc.get("parameters")):
                parameters.append(p)

            # recursive base case: no base defined by sequence container
            if "base" not in sc:
                parameters.reverse()
                return (parameters, restrictions)

            # save each parameter restriction criteria
            if "restriction_criteria" in sc.get("base"):
                for c in sc.get("base").get("restriction_criteria"):
                    restrictions[c.get("parameter_ref")] = c.get("value")

            # recursively expand the base sequence containers
            return self.expand_base_container(abstract_seq_containers.get(sc.get("base").get("container_ref")), abstract_seq_containers, parameters, restrictions)

        except Exception as e:
            raise Exception("CNTUtil - error expanding base sequence container \"" + sc.get("name") + "\": " + str(e))




    def get_byte_order(self, param, host=None):
        """
        Returns the byte order of the given parameter.
        If host is not specified and the given parameter does not define the byte order directly, big endian is returned as default.
        """
        byteorder = "big_endian"

        try:
            # overwrite byteorder defined by the host processor
            byteorder = byteorder if host is None else host.get("byte_order")

            # overwrite byteorder if defined by the parameter
            byteorder = byteorder if "byte_order" not in param else param.get("byte_order")

            return byteorder

        except Exception as e:
            raise Exception("CNTUtil - get_byte_order on parameter \"" + param.get("name") + "\": " + str(e))



