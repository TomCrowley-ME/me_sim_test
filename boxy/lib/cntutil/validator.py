import json, jsonschema, collections
from prettytable import PrettyTable
from cntutil import CNTUtil


class Validator(object):

    """ A module providing robust validation of the MoonEx C&T dictionary """

    def __init__(self):
        self.cnt = None
        self.errors = dict()



    def validate(self, cnt, schema):
        """
        Validates the given schema as a valid JSON v4 schema, checks that the given
        C&T dictionary is a valid instance of the schema, and validates the properties
        and references of the space_system with the given name. This is necessary for
        conventions that aren't explicitly enforced by the schema.

        For example:

          - parameters must reference a paramter_type in the system's scope
          - base container references must exist as abstract sequence containers in the system's scope
          - restriction criteria must reference parameters that are defined through inheritence
          - parameter mnemonics must be unique
          - parameters must reference a limit or conversion that exists in the system scope

        Returns: a dictionary mapping error messages to the name of the system scope in which the error exists.
        Raises: Exception type in the case that the schema/cnt are invalid.
        """
        try:

            jsonschema.validate(cnt, schema)
            self.cnt = CNTUtil(cnt_dict=cnt)
            self.cnt.discover_all_space_systems(self.cnt.get_root())

            for s in self.cnt.get_discovered_systems():
                self.__validate_parameter_type_references(s)
                self.__validate_base_container_references(s)
                self.__validate_telemetry_limits_references(s)
                self.__validate_data_conversion_references(s)
                #self.__validate_global_mnemonics(s)

            return self.errors


        except jsonschema.SchemaError as se:
            raise Exception ("Schema: INVALID -- " + str(se))

        except jsonschema.ValidationError as ve:
            raise Exception ("C&T Dictionary: INVALID -- " + str(ve))




    def get_discovered_systems(self):
        """
        Return the systems discovered by the validator module
        """
        return self.cnt.get_discovered_systems()




    def __validate_telemetry_limits_references(self, system):
        """
        Validate that each telemetry parameter limit references a limits object that is actually defined.
        """
        limits = self.cnt.get_telemetry_limits(system)
        tlm = self.cnt.get_telemetry_sequence_containers(system)

        for sc in tlm.values():
            for p in sc.get("parameters"):
                if "limits" not in p:
                    continue
                if p.get("limits") not in limits.keys():
                    msg = "telemetry limits \"" + p.get("limits") + "\" referenced by " + sc.get("name") + "." + p.get("name") + " does not exist"
                    self.errors[msg] = system




    def __validate_data_conversion_references(self, system):
        """
        Validates that each parameter conversion field references a data conversion object (by name) that is actually defined.
        """
        conversions = self.cnt.get_data_conversions(system)
        pkts = self.cnt.get_telemetry_sequence_containers(system)
        pkts.update(self.cnt.get_command_sequence_containers(system))
        pkts.update(self.cnt.get_common_sequence_containers(system))

        for sc in pkts.values():
            for p in sc.get("parameters"):
                if "conversion" not in p:
                    continue
                if p.get("conversion") not in conversions.keys():
                    msg = "data conversion \"" + p.get("conversion") + "\" referenced by " + sc.get("name") + "." + p.get("name") + " does not exist"
                    self.errors[msg] = system




    def __validate_global_mnemonics(self, system):

        """
        Run through every abstract/common/telemetry parameter and checks each defined mnemonic is unique.
        This is a temporary validation, as dereferenced leaf mnemonics could make duplicate mnemonics uniuqe.
        NOTE: Command parameter mnemonics aren't required to be unique.
        """
        gbl_mnemnoics = dict()
        seq_containers = self.cnt.get_telemetry_sequence_containers(system)
        seq_containers.update(self.cnt.get_common_sequence_containers(system))
        seq_containers.update(self.cnt.get_abstract_sequence_containers(system))

        for sc in seq_containers.values():
            if "parameters" not in sc:
                continue
            for p in sc.get("parameters"):
                if "mnemonic" in p:
                    if p.get("mnemonic") in gbl_mnemnoics.keys():
                        msg = "duplicate mnemonic \"" + p.get("mnemonic") + "\" referenced by " + sc.get("name") + "." + p.get("name")
                        self.errors[msg] = system
                    gbl_mnemnoics[p.get("mnemonic")] = p




    def __validate_base_container_references(self, system):
        """
        Validates that base references exist as abstract sequence containers.
        Validates that restriction criterias reference parameters existing in the base inheritence tree.
        """
        seq_containers = self.cnt.get_common_sequence_containers(system)
        seq_containers.update(self.cnt.get_telemetry_sequence_containers(system))
        seq_containers.update(self.cnt.get_command_sequence_containers(system))
        abs_containers = self.cnt.get_abstract_sequence_containers(system)

        # first verify that each referenced base container is an abstract sequence container in the system's scope
        for sc in seq_containers.values():
            if "base" not in sc:
                continue
            base = sc.get("base")

            # check that the base container reference is an abstract sequence container
            if base.get("container_ref") not in abs_containers:
                msg = "base container reference \"" + base.get("container_ref") + "\" does not exist in abstract sequence containers -- referenced by sequence container " + sc.get("name")
                if msg not in self.errors:
                    self.errors[msg] = system


        # verify that each referenced parameter restriction criteria is a parameter in an inherited base container
        for sc in seq_containers.values():
            if "base" not in sc:
                continue
            base = sc.get("base")

            # ignore the restriction criteria in bogus continer refs
            if base.get("container_ref") not in abs_containers.keys():
                continue

            if "restriction_criteria" not in base:
                continue

            # check that the restriction criteria references parameters that actually exist in the inherited base container(s)
            params = self.__find_inherited_base_params(abs_containers.get(base.get("container_ref")), abs_containers, dict())
            for rc in base.get("restriction_criteria"):
                if rc.get("parameter_ref") not in params:
                    msg = "parameter \"" + rc.get("parameter_ref") + "\" does not exist in sequence container " + base.get("container_ref") + " -- parameter referenced in base by sequence container " + sc.get("name")
                    if msg not in self.errors:
                        self.errors[msg] = system




    def __find_inherited_base_params(self, base_container, abs_seq_containers, params):
        """
        Recursively populates a listing of parameters inherited by the specified base container.
        """
        for p in base_container.get("parameters"):
            params[p.get("name")] = p

        # base case: base_container does not inherit any other containers
        if "base" not in base_container:
            return params

        base = base_container.get("base")
        abs_base = abs_seq_containers.get(base.get("container_ref"))
        return self.__find_inherited_base_params(abs_base, abs_seq_containers, params)




    def __validate_parameter_type_references(self, system):
        """
        Checks that all parameter types referenced by the system exist as
        parameter types or abstract sequence containers in the system's scope.
        """
        paramtypes = self.cnt.get_parameter_types(system)
        abs_seq_containers = self.cnt.get_abstract_sequence_containers(system)
        seq_containers = self.cnt.get_telemetry_sequence_containers(system)
        seq_containers.update(self.cnt.get_command_sequence_containers(system))
        seq_containers.update(self.cnt.get_common_sequence_containers(system))

        self.__validate_sequence_container_parameter_type_references(system, seq_containers, paramtypes, abs_seq_containers)




    def __validate_sequence_container_parameter_type_references(self, system, sequence_containers, parameter_types, abstract_sequence_containers):
        """
        Helper function to validate parameter type references.
        """
        for sc in sequence_containers.values():

            if "parameters" not in sc:
                continue

            for p in sc.get("parameters"):

                # check for the parameter type reference in list of inherited paramter_types
                if p.get("type") in parameter_types:
                    continue

                # check for the parameter type reference in list of inherited abstract sequence containers
                elif p.get("type") in abstract_sequence_containers.keys():
                    continue

                # check for the parameter type reference in dictionary of in-scope abstract sequence containers
                elif p.get("type") in sequence_containers.keys():
                    msg = "parameter type \"" + p.get("type") + "\" is not abstract but is referenced by parameter \"" + p.get("name") + "\" in sequence container \"" + sc.get("name") + "\""
                    if msg not in self.errors:
                        self.errors[msg] = system

                # parameter type reference is not in system scope
                else:
                    msg = "parameter type \"" + p.get("type") + "\" does not exist -- referenced by parameter \"" + p.get("name") + "\" in sequence container \"" + sc.get("name") + "\""
                    if msg not in self.errors:
                        self.errors[msg] = system




    def dump_statistics(self):
        """
        Print out a table of C&T statistics for each discovered space system
        """
        table = PrettyTable(["system", "commands", "telemetry", "parameter types", "limits", "conversions", "constants"])
        table.align["system"] = "l"

        for s in self.cnt.get_discovered_systems():
            row = [s]
            for i in self.cnt.get_cnt_statistics(s):
                row.append(str(i))
            table.add_row(row)

        print (table)
