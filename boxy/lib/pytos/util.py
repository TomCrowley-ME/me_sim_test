import itertools, collections, math


def dereference_leaf_mnemonic(mnem_map, scname, param, abstract_seq_containers, mnemonic_stmt, gbl_mnem):
    """
    Recursively dereference nested parameters and map the traversal to each leaf parameter.
    """
    # ignore padding and spare byte definitions
    if "pad" in param.get("name").lower() or "spare" in param.get("name").lower():
        return

    if "mnemonic" in param:
        gbl_mnem += param.get("mnemonic")

    # base case: dereference mnemonic records until the parameter type is primitive
    if param.get("type") not in abstract_seq_containers:
        mnemonic_stmt += "." + param.get("name")
        derefs = get_array_index_permutations(param)

        # map the non-array parameter
        if len(derefs) == 0:
            __map_mnemonic(mnem_map, scname, mnemonic_stmt, gbl_mnem, param)
            return

        # map a mnemonic for each index permutation of the array parameter
        for d in derefs:
            index = ""
            for i in d:
                index += "[" + str(i) + "]"
            __map_mnemonic(mnem_map, scname, mnemonic_stmt + index, gbl_mnem, param)
        return

    # not a leaf parameter so continue dereferencing the structure
    mnemonic_stmt += "." + param.get("name")
    for subp in abstract_seq_containers.get(param.get("type")).get("parameters"):
        derefs = get_array_index_permutations(param)

        if len(derefs) > 0:
            for d in derefs:
                index = ""
                for i in d:
                    index += "[" + str(i) + "]"
                dereference_leaf_mnemonic(mnem_map, scname, subp, abstract_seq_containers, mnemonic_stmt + index, gbl_mnem)
        else:
            dereference_leaf_mnemonic(mnem_map, scname, subp, abstract_seq_containers, mnemonic_stmt, gbl_mnem)




def __map_mnemonic(mnem_map, scname, mnemonic_rec, gbl_mnemonic, param):
    """
    Map the dereferenced mnemonic record to its parameter and originating sequence container.
    This map is initialized and iterated over by rec/page generation to dump out global mnemonics.
    """
    # create a new mapping for first parameter instance
    if param.get("name") not in mnem_map.get(scname).get("parameters"):
        mnem_map.get(scname).get("parameters")[param.get("name")] = collections.OrderedDict()

    # create a new list mapping for first global mnemnoic instance
    if gbl_mnemonic not in mnem_map.get(scname).get("parameters").get(param.get("name")):
        mnem_map.get(scname).get("parameters").get(param.get("name"))[gbl_mnemonic] = list()

    # map the mnemonic record to its parameter definition and global mnemonic
    gbl_map = dict()
    gbl_map["param"] = param
    gbl_map["record"] = mnemonic_rec
    mnem_map.get(scname).get("parameters").get(param.get("name")).get(gbl_mnemonic).append(gbl_map)

    # keep track of the longest mnemonic length to format even columns on the page
    length = len(gbl_mnemonic) if len(gbl_mnemonic) > 0 else len(mnemonic_rec)
    if length > mnem_map.get(scname).get("max_mnem_len"):
        mnem_map.get(scname)["max_mnem_len"] = len(mnemonic_rec)




def get_array_index_permutations(param):
    """
    Generate a list of all possible ways to index into the array parameter.
    """
    indices = list()

    try:
        for d in reversed(param.get("dimensions")):
            i = list()
            for x in range(0, d.get("len")):
                i.append(x)
            indices.append(i)

        array_dereferences = list(itertools.product(*indices))
        return array_dereferences

    except TypeError:
        return list()





def get_record_type(paramtype, byteorder, host=None):
    """
    Returns a tuple containing two strings:
      (primitive ITOS data type string for the given parameter type, global mnemonic type for the given paramter type).
    """
    nbytes = 0
    base = paramtype.get("base_type")
    ptype = "U"


    if base == "string":
        if paramtype.get("name") == "TIME44":
            time = "RTIME44" if byteorder == "little_endian" else "TIME44"
            return (time, "D")
        return ("S1", "S")

    if base == "enumeration" or base == "integer" or base == "boolean":
        if paramtype.get("signed"):
            ptype = "I"

    if base == "float":
        ptype = "F"

    # if no host is specified, we only care about the record type (not size or byte order)
    if host is None:
        return (ptype, ptype)

    # determine the number of bytes in the data type
    if base == "pointer":
        nbytes = math.ceil(int(host.get("bits")) / 8)
    else:
        nbytes = math.ceil(int(paramtype.get("size_in_bits")) / 8)

    # generate the byte list
    bytelist = ""
    for n in range(0, nbytes):
        bytelist = bytelist + str(n+1)

    # swap the byte list if necessary
    if byteorder == "little_endian":
        bytelist = bytelist[::-1]

    return (str(ptype + bytelist), ptype)


