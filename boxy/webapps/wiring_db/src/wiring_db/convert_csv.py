import csv
import sys
import json, os


def convert(csv_filename, fieldnames):
    print ("Opening CSV file: ",csv_filename)
    f=open(csv_filename, 'r')
    csv_reader = csv.DictReader(f,fieldnames)
    json_filename = csv_filename.split(".")[0]+".json"
    
    print ("Saving JSON to file: ",json_filename)
    jsonf = open(json_filename,'w') 
    data = json.dumps([r for r in csv_reader])
    jsonf.write(data) 
    f.close()
    jsonf.close()

    jsonf = open(json_filename, 'r')
    json_dict = json.load(jsonf)
    jsonf.close()

    # #add id_num to each item
    # count = 0
    # for item in json_dict:
    #     item["id_num"] = str(count)
    #     count += 1

    jsonf = open(json_filename,'w') 
    dumped_json_dict = json.dumps(json_dict)
    jsonf.write(dumped_json_dict) 
    jsonf.close()

# csvfile = os.path.expandvars('$BOXY_PATH/webapps/wiring_db/src/CAB_Connectors_all.csv')
# CAB_column_names = [
#                 "Connector Name",
#                 "Connector Package Name",
#                 "Harness Name",
#                 "Pin #",
#                 "Card signal",
#                 "Pin swap",
#                 "ERC Type",
#                 "Net Name",
#                 "System Type",
#                 "Comment/Notes",
#             ]
 
# convert(csvfile, CAB_column_names)

cab_external_columns =  [
                        "id_num",
                        "Board Type",
                        "Signal Name",
                        "Connector",
                        "Pin #"
                        ]

hifi_hil_columns =      [
                        "id_num",
                        "Board Type",
                        "Signal Name",
                        "FPGA #",
                        "FPGA Pin #",
                        "FPGA Page",
                        "FPGA Address",
                        "Net Name"
                        ]

cab_control_columns =   [
                        "id_num",
                        "Board Type",
                        "Signal Name",
                        "FPGA #",
                        "FPGA Pin #",
                        "FPGA Page",
                        "FPGA Address",
                        "Net Name"
                        ]           

fpga_edu_v1_coulmns =   [
                        "id_num",
                        "Board Type",
                        "Signal Name",
                        "FPGA #",
                        "FPGA Pin #",
                        "FPGA Page",
                        "FPGA Address",
                        "Net Name"
                        ]

logic_sim_v1_coulmns =  [
                        "id_num",
                        "Board Type",
                        "Signal Name",
                        "INCU Feedback Pin",
                        "MCU Pin Functions"
                        ]                   

flight_software_coulmns=[
                        "id_num",
                        "Board Type",
                        "Signal Name",
                        "FSW Handle"
                        ]


csvfile1 = os.path.expandvars('$BOXY_PATH/webapps/wiring_db/src/test1.csv')
convert(csvfile1, cab_external_columns)
csvfile2 = os.path.expandvars('$BOXY_PATH/webapps/wiring_db/src/test2.csv')
convert(csvfile2, hifi_hil_columns)
csvfile3 = os.path.expandvars('$BOXY_PATH/webapps/wiring_db/src/test3.csv')
convert(csvfile3, cab_control_columns)
csvfile4 = os.path.expandvars('$BOXY_PATH/webapps/wiring_db/src/test4.csv')
convert(csvfile4, fpga_edu_v1_coulmns)
csvfile5 = os.path.expandvars('$BOXY_PATH/webapps/wiring_db/src/test5.csv')
convert(csvfile5, logic_sim_v1_coulmns)
csvfile6 = os.path.expandvars('$BOXY_PATH/webapps/wiring_db/src/test6.csv')
convert(csvfile6, flight_software_coulmns)



