#! /usr/bin/env python3


################################################################
###                                                          ###
### validate_cnt_dictionary.py                               ###
###                                                          ###
### Validates the MoonEx C&T JSON schema and then validates  ###
### the MoonEx C&T dictioanry against the schema.            ###
###                                                          ###
################################################################


import sys, os, argparse, json
from cntutil import Validator



def main(argv=None):
    """ Validator main entry point """

    parse_args()

    schemafile = os.path.expandvars("$BENDER_PATH/clamps/moonex_cnt_schema.json")
    cntfile = os.path.expandvars("$BENDER_PATH/clamps/moonex_cnt_dictionary.json")
    schema = None
    cnt = None
    cnt_validator = Validator()

    with open (schemafile) as s, open (cntfile) as d:

        try:
            schema = json.load(s)
            cnt = json.load(d)
            errors = cnt_validator.validate(cnt, schema)
            print ("Schema:\tVALID")

            if len(errors.keys()) == 0:
                print ("C&T:\tVALID")
                cnt_validator.dump_statistics()
                sys.exit()

            print ("--- ERRORS ---")
            for i, e in enumerate(errors.keys()):
                print (str(i) + ") " + errors.get(e) + ": " + e)


        except Exception as e:
            print ("INVALID: " + str(e))
            sys.exit(1)



def parse_args():
    """
    Parse the command line arguments
    """
    parser = argparse.ArgumentParser(description="Validates the MoonEx JSON C&T dictionary against the JSON Space Data System schema")
    args = vars(parser.parse_args())

    return ()


if __name__ == "__main__":
    sys.exit(main())

