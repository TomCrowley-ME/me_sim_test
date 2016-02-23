#! /usr/bin/env python3


#############################################################################################
###                                                                                       ###
### gen_itos_config.py                                                                    ###
###                                                                                       ###
### Generates ITOS rec/page config files from the MoonEx command & telemetry dictionary   ###
###                                                                                       ###
#############################################################################################


import sys, argparse, os, subprocess
from pytos import RecGen
from pytos import PageGen
from pytos import ProcGen
from pytos import CtrlSourceGen
from philutil import PhilConfig
from cntutil import CNTUtil



def main(argv=None):
    """ ITOS rec file generation entry point.

    Here we parse the command line arguments for input/output paths and runtime flags.
    """
    # parse command line arguments
    vehicle, phil, sim, verbose, listphils, listvehicles, commandconsole = parse_args()
    single_pil = False
    source = "schooner"
    console_type = "command/telemetry" if commandconsole else "telemetry"


    try:
        # store the path to fligh software repo
        bender_path = os.path.expandvars("$BENDER_PATH")

        # get the bender/clamps repo revision used to generate the configuration files
        hgrev = subprocess.check_output(['hg', 'id', bender_path]).decode("utf-8").strip()

        # initialize modules
        pc = PhilConfig()
        cnt = CNTUtil(cnt_path=bender_path+"/clamps/moonex_cnt_dictionary.json")
        rec_gen  = RecGen("rec/autogen")
        page_gen = PageGen("pages/autogen", verbose=verbose)
        proc_gen = ProcGen("procs/autogen")
        csrc_gen = CtrlSourceGen(".")


        # show the space system vehicle list and exit
        if listvehicles:
            cnt.discover_all_space_systems(cnt.get_root())
            cnt.dump_space_systems()
            if not listphils:
                sys.exit(0)

        # show the p/hil config options and exit
        if listphils:
            pc.dump_config()
            sys.exit(0)

        # always generate the SIM configuration for single PILs
        if pc.get_config(phil, "type") == "pil":
            sim = True
            single_pil = True


        print ("\nAutogenerating ITOS configuration for " + console_type + " console:")

        # generate REC files
        rec_gen.generate_vehicle_recs(vehicle, tlmsource=source)
        if sim:
            source = source if single_pil else "highseas"
            rec_gen.generate_vehicle_recs(vehicle + "-SIM", tlmsource=source, single_pil=single_pil, export_system="hs")


        # generate page files
        page_gen.generate_vehicle_pages(vehicle)
        if sim:
            page_gen.generate_vehicle_pages(vehicle + "-SIM", namespace="hs")


        # generate command graphs (only for HILs)
        rec_gen.generate_command_graph(phil, command_console=commandconsole)
        if sim and not single_pil:
            rec_gen.generate_command_graph(phil, sim=sim, export_system="hs", command_console=commandconsole)


        # generate the ctrlsource.dat file
        csrc_gen.generate(phil, single_pil=single_pil, sim=sim, sim_namespace="hs")


        # generate the startup/generic procs
        proc_gen.generate_setup_environment_proc(single_pil=single_pil, sim=sim, command_console=commandconsole)
        proc_gen.generate_attach_tlm_sources_proc(phil, single_pil=single_pil, sim=sim, sim_namespace="hs")
        proc_gen.generate_pipe_event_logs_proc(phil, single_pil=single_pil, sim=sim)
        proc_gen.generate_archiver_procs(phil, single_pil=single_pil, sim=sim)
        if commandconsole:
            proc_gen.generate_init_cmd_graphs_proc(phil, single_pil=single_pil, sim=sim, sim_namespace="hs")


        # display the generated record statistics
        rec_gen.dump_record_statistics(fsw_repo_name="bender/clamps", fsw_repo_rev=hgrev)
        print ("Autogen complete! Run makeodb to build the ITOS operational database\n")


    except Exception as e:
        print ("Failed to generate ITOS configuration: " + str(e))




def parse_args():
    """
    Parse the command line arguments
    """
    parser = argparse.ArgumentParser(description='Generate ITOS rec/page files from the MoonEx C&T dictionary')
    parser.add_argument("vehicle", nargs="?", help="Name of the space system vehicle to generate recs/pages for.")
    parser.add_argument("phil", nargs="?", help="Symbolic name of the P/HIL processor hosting the software, used to generate command graph and telemetry ctrlsource files (see section names in moonex_phils.ini).")
    parser.add_argument('-s', '--sim', help='Generate configuration for sim vehicle along with flight vehicle.', required=False, action="store_true")
    parser.add_argument('-v', '--verbose', help='Output verbose messages during config generation.', required=False, action="store_true")
    parser.add_argument('-m', '--list_vehicles', help='List the current MoonEx Space System vehicles and exit.', required=False, action="store_true")
    parser.add_argument('-l', '--list_phils', help='List the current MoonEx P/HIL configuration options and exit.', required=False, action="store_true")
    parser.add_argument('-c', '--command_console', help='Generate command graphs and their initialization procs (for command console operator only).', required=False, action="store_true")
    args = vars(parser.parse_args())


    # force either both positional arguments and/or the --listphils option
    if not args.get("vehicle") or not args.get("phil"):
        if not args.get("list_phils") and not args.get("list_vehicles"):
            parser.error(" MISSING POSITIONAL ARGUMENT:\n")

    return (args["vehicle"], args["phil"], args["sim"], args["verbose"], args["list_phils"], args["list_vehicles"], args["command_console"])



if __name__ == "__main__":
    sys.exit(main())


