'''
Created on Jun 3, 2014

@author: tklaus
'''

from flask import Flask, redirect, session
from flask_pymongo import PyMongo
from werkzeug.utils import secure_filename
from jinja2 import Environment, PackageLoader
from flask.globals import request
from parameter_library.matlab_init import MatlabInit
from collections import OrderedDict
import collections
import os.path
from flask.helpers import send_from_directory, make_response
import json
import sys
from sets import Set
from parameter_library.scenario import Scenario
from parameter_library.utils import table_names_for_scenario,\
    retrieve_parameter_dict
import tempfile
import zipfile

UPLOAD_FOLDER = '/tmp'
ALLOWED_EXTENSIONS = set(['json'])

app = Flask(__name__)
app.config['MONGO_DBNAME'] = 'parameter_library'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
mongo = PyMongo(app)

env = Environment(loader=PackageLoader('parameter_library', 'templates'))

parameter_columns = [
           {"display_name" : "Parameter Name",
            "db_name" : "name" },
           {"display_name" : "Description",
            "db_name" : "description" },
           {"display_name" : "Type",
            "db_name" : "type" },
           {"display_name" : "Number of Dimensions",
            "db_name" : "num_dims" },
           {"display_name" : "Tunable for (App)",
            "db_name" : "tunable_for" },
           {"display_name" : "Owned by (App)",
            "db_name" : "owned_by" },
           {"display_name" : "Default Value",
            "db_name" : "default_value" },
           ]

@app.route('/', methods=['GET'])
def home_page():
    return redirect("/parameters")


@app.route('/parameters', methods=['POST', 'GET'])
def parameters():
    query_criteria = collections.OrderedDict()

    if request.method == 'POST':
        update_session_filter(request.form)
        
    (parameter_name, app_selected, tunable_only) = get_session_filter()
            
    print("parameter_name = {}".format(parameter_name))
    print("app_selected = {}".format(app_selected))
    print("tunable_only = {}".format(tunable_only))

    if parameter_name:
        query_criteria["name"] = { '$regex': parameter_name, '$options' : 'i'}

    if app_selected != 'ALL':
        if tunable_only:
            query_criteria['tunable_for'] = app_selected
        else:
            query_criteria['$or'] = [{'tunable_for' : app_selected }, {'owned_by' : app_selected }]

    return render_parameters_page(query_criteria)

def get_session_filter():
    parameter_name = ''
    app_selected = ''
    tunable_only = ''

    # use filter settings from session, if set
    if "filter_name" in session:
        parameter_name = session["filter_name"]
    if "filter_app_selected" in session:
        app_selected = session["filter_app_selected"]
    if "filter_tunable_only" in session:
        tunable_only = session["filter_tunable_only"]

    return(parameter_name, app_selected, tunable_only)
    
def update_session_filter(form):
    print("form = {}".format(form))

    if "name" in form:
        session["filter_name"] = form["name"]
    if "app_selected" in form:
        session["filter_app_selected"] = form["app_selected"]
    if "tunable_only" in form:
        session["filter_tunable_only"] = 'checked'
        
def render_parameters_page(query_criteria):
    print("query_criteria = {}".format(query_criteria))

    print("mongo.db = {}".format(mongo.db))

    parameters = mongo.db.parameters.find(query_criteria).sort([("name", 1)])

    count = 0
    table = []

    display_column_names = []
    for column in parameter_columns:
        display_column_names.append(column["display_name"])

    for parameter in parameters:
        #print('parameter = {}'.format(parameter))
        row = []
        for column in parameter_columns:
            #print('parameter = {}'.format(parameter))
            #print('column = {}'.format(column))
            row.append(parameter[column["db_name"]])
            #print("parameter[{}] = {}".format(column_name, parameter[column_name]))
            #print('row = {}'.format(row))
        table.append(row)
        count = count + 1

    #print('num parameters = {}'.format(count))
    #print('table = {}'.format(table))

    app_names = unique_app_names()

    (filter_name, filter_selected_dict, filter_tunable_only) = get_filter_settings(app_names)

    template = env.get_template('parameter_library.html')
    return template.render(column_names=display_column_names,
                           table=table,
                           unique_app_names=app_names,
                           filter_name=filter_name,
                           filter_selected_dict=filter_selected_dict,
                           filter_tunable_only=filter_tunable_only)

def get_filter_settings(app_names):
    filter_name = ''
    filter_app_selected = 'ALL'
    filter_tunable_only = ''

    if "filter_name" in session:
        filter_name = session["filter_name"]

    if "filter_app_selected" in session:
        filter_app_selected = session["filter_app_selected"]

    filter_selected_dict = collections.OrderedDict()

    for app in app_names:
        if app == filter_app_selected:
            filter_selected_dict[app] = 'selected="selected"'
        else:
            filter_selected_dict[app] = ''

    if "filter_tunable_only" in session:
        filter_tunable_only = session["filter_tunable_only"]

    print("filter_name={}".format(filter_name))
    print("filter_app_selected={}".format(filter_app_selected))
    print("filter_tunable_only={}".format(filter_tunable_only))

    return (filter_name, filter_selected_dict, filter_tunable_only)

@app.route('/scenarios', methods=['GET'])
def scenarios():

    scenario_names = mongo.db.parameter_tables.distinct('scenario_name')

    print('scenario_names = {}'.format(scenario_names))

    return render_scenarios(scenario_names)

def render_scenarios(scenario_names):
    template = env.get_template('scenarios.html')
    return template.render(scenario_names=scenario_names)

@app.route('/scenario_tables', methods=['POST'])
def scenario_tables():
    if request.method == 'POST':
        print("method == POST")
        print("form = {}".format(request.form))
        scenario_name = request.form["scenario_name"]
        print("scenario_name = {}".format(scenario_name))

        table_names = table_names_for_scenario(scenario_name, mongo)
        return render_scenario_tables(scenario_name, table_names)

def render_scenario_tables(scenario_name, table_names):
    template = env.get_template('scenario_tables.html')
    return template.render(scenario_name=scenario_name,table_names=table_names)

@app.route('/edit_parameter_value', methods=['POST'])
def edit_parameter_value():

    print("edit_parameter_value: form = {}".format(request.form))

    parameter_table_name = request.form["parameter_table_name"]
    print("parameter_table_name = {}".format(parameter_table_name))
    parameter_table_param_name = request.form["parameter_table_param_name"]
    print("parameter_table_param_name = {}".format(parameter_table_param_name))
    value = request.form["value"]
    print("value = {}".format(value))

    mongo.db.parameter_tables.update({"table_name":parameter_table_name,
                                      "parameter_name":parameter_table_param_name},
                                     {"$set":{"value":value}})

    return render_edit_parameter_table(parameter_table_name)

def render_edit_parameter_table(parameter_table_name):
    parameter_table_parameters = mongo.db.parameter_tables.find({'table_name' : parameter_table_name})

    count = 0
    table = []

    for parameter in parameter_table_parameters:
        print('parameter = {}'.format(parameter))
        row = []
        row.append(parameter["parameter_name"])
        row.append(parameter["value"])
        table.append(row)
        count = count + 1

    print('num parameters = {}'.format(count))

    print('parameter_table_parameters = {}'.format(parameter_table_parameters))

    unique_app_names = mongo.db.parameters.distinct('tunable_for')

    template = env.get_template('edit_parameter_table.html')
    return template.render(table=table,
                           unique_app_names=unique_app_names,
                           parameter_table_name=parameter_table_name)

@app.route('/edit_parameter_table', methods=['POST'])
def edit_parameter_table():

    print("form = {}".format(request.form))
    
    scenario_name = request.form["scenario_name"]
    table_name = request.form["table_name"]

    print("scenario_name = {}".format(scenario_name))
    print("table_name = {}".format(table_name))

    table_parameters = mongo.db.parameter_tables.find({'scenario_name':scenario_name,'app_name' : table_name})

    count = 0
    table = []

    for parameter in table_parameters:
        print('parameter = {}'.format(parameter))
        row = []
        row.append(parameter["parameter_name"])
        row.append(parameter["value"])
        table.append(row)
        count = count + 1

    print('num parameters = {}'.format(count))

    print('parameter_table_parameters = {}'.format(table_parameters))

    template = env.get_template('edit_parameter_table.html')
    return template.render(scenario_name=scenario_name,table_name=table_name, table=table)

@app.route('/delete_parameter_table', methods=['POST'])
def delete_parameter_table():
    if request.method == 'POST':
        print("method == POST")
        print("form = {}".format(request.form))
        param_name = request.form["param_name"]
        print("param_name = {}".format(param_name))

        confirmation = request.form["confirmation"]
        if confirmation == 'yes':
            print("user confirmed delete, deleting {}".format(param_name))
            mongo_response = mongo.db.parameters.remove({"name" : param_name})
            print(mongo_response)
        else:
            print("user rejected delete, NOT deleting {}".format(param_name))

    return redirect("/parameter_tables")

@app.route('/export_table', methods=['POST'])
def export_parameter_table():
    if request.method == 'POST':
        print("method == POST")
        print("request = {}".format(request))
        print("form = {}".format(request.form))

        scenario_name = request.form["scenario_name"]

        template = env.get_template('export_scenario.html')
        return template.render(scenario_name=scenario_name)

@app.route('/do_export', methods=['POST'])
def do_export():

    if request.method == 'POST':
        print("method == POST")
        print("request = {}".format(request))
        print("form = {}".format(request.form))

        scenario_name = request.form["scenario_name"]
        table_name = ''
        if 'table_name' in request.form:
            table_name = request.form["table_name"]

        parameter_dict = retrieve_parameter_dict(mongo)
        scenario = Scenario(scenario_name, mongo, env, parameter_dict)
        
        if table_name:
            file_to_download = scenario.export_single_table(table_name)
            filename = "{}_init_{}.m".format(scenario_name, table_name)
        else: # multiple tables, create zip file
            file_to_download = make_zip(scenario)
            filename = "{}_init_ALL.zip".format(scenario_name)
            
        response = make_response(file_to_download)
        response.headers["Content-Disposition"] = "attachment; filename={}".format(filename)
        return response

def make_zip(scenario):
    zip_contents = ''
    with tempfile.NamedTemporaryFile() as temp:
        tables = scenario.export_all_tables()
        zip_file = zipfile.ZipFile(temp, mode="w")
        
        for table in tables:
            filename = "{}_init_{}.m".format(scenario.get_name(), table)
            file_to_download = tables[table]
            zip_file.writestr(filename, file_to_download)
        zip_file.close()
        temp.flush()
        temp.seek(0)
        zip_contents = temp.read()
        
    return zip_contents
         
@app.route('/add_edit_parameter', methods=['POST'])
def add_edit_parameter():

    print("method == POST")
    print("form = {}".format(request.form))

    action = request.form["action"]
    parameter = None

    if action == 'edit':
        param_name = request.form["param_name"]
        print("param_name = {}".format(param_name))
        parameter = mongo.db.parameters.find_one({"name":param_name})
    elif action == 'add':
        parameter = mongo.db.parameters.find_one({})
    else:
        template = env.get_template('display_error.html')
        return template.render(error_message="Unrecognized action:{}".format(action))

    print("parameter = {}".format(parameter))

    form = []
    for column in parameter_columns:
        row = []
        print("column.display_name = {}".format(column["display_name"]))
        print("column.db_name = {}".format(column["db_name"]))
        row.append(column["db_name"])
        row.append(column["display_name"])
        if action == 'edit':
            row.append(parameter[column["db_name"]])

        print("row = {}".format(row))

        form.append(row)

    template = env.get_template('edit_parameter.html')
    return template.render(form=form, action=action)

@app.route('/update_param', methods=['POST'])
def update_param():

    #print("method == POST")
    print("update_param: form = {}".format(request.form))

    fields = {}
    for column in parameter_columns:
        db_column_name = column["db_name"]
        fields[db_column_name] = request.form[db_column_name]

        print("update_param: db_column_name = {}".format(db_column_name))
        print("update_param: request.form[{}] = {}".format(db_column_name,request.form[db_column_name]))

    parameter_name = request.form["name"]
    action = request.form["action"]

    print("update_param: parameter_name = {}".format(parameter_name))
    print("update_param: fields = {}".format(fields))
    print("update_param: action = {}".format(action))

    if action == 'edit':
        mongo.db.parameters.update({"name":parameter_name}, {"$set":fields})
    elif action == 'add':
        existing_parameter = mongo.db.parameters.find_one({"name":parameter_name})
        if not existing_parameter:
            mongo.db.parameters.insert(fields)
        else:
            template = env.get_template('display_error.html')
            return template.render(error_message="Parameter already exists: {} (use back button to correct)".format(parameter_name))
    else:
        template = env.get_template('display_error.html')
        return template.render(error_message="Unrecognized action:{}".format(action))

    return redirect("/parameters#{}".format(parameter_name))

def retrieve_parameters_for_app(app_name):
        parameters = mongo.db.parameters.find({"tunable_for":app_name})
        print("parameters = {}".format(parameters))

        return parameters

@app.route('/add_scenario', methods=['POST'])
def add_scenario():
    if request.method == 'POST':
        print("method == POST")
        print("form = {}".format(request.form))
 
        scenario_name = request.form["scenario_name"]
        scenario_var_prefix = request.form["scenario_var_prefix"]
 
        print("scenario_name = {}".format(scenario_name))
        print("scenario_var_prefix = {}".format(scenario_var_prefix))

        if scenario_name == "" or scenario_var_prefix == "":
            template = env.get_template('display_error.html')
            return template.render(error_message="Scenario Name ({}) and SCENARIO var prefix ({}) must be specified".format(scenario_name, scenario_var_prefix))
        
        app_names = unique_app_names()
        
        for app_name in app_names:
            if app_name != "GLOBAL":
                parameters = retrieve_parameters_for_app(app_name)
    
                for parameter in parameters:
                    mongo.db.parameter_tables.insert({"app_name":app_name,
                                                      "scenario_name":scenario_name,
                                                      "parameter_name":parameter["name"],
                                                      "value":parameter["default_value"]})
        
        return redirect("/scenarios")

@app.route('/confirm_delete', methods=['POST'])
def confirm_delete():
    if request.method == 'POST':
        print("method == POST")
        print("form = {}".format(request.form))

        to_be_deleted_name = request.form["to_be_deleted_name"]
        to_be_deleted_type = request.form["to_be_deleted_type"]

        print("to_be_deleted_name = {}".format(to_be_deleted_name))
        print("to_be_deleted_type = {}".format(to_be_deleted_type))

    template = env.get_template('confirm_delete.html')
    return template.render(to_be_deleted_name=to_be_deleted_name, to_be_deleted_type=to_be_deleted_type)

@app.route('/do_delete', methods=['POST', 'GET'])
def do_delete():
    if request.method == 'POST':
        print("method == POST")
        print("form = {}".format(request.form))

        to_be_deleted_name = request.form["to_be_deleted_name"]
        to_be_deleted_type = request.form["to_be_deleted_type"]
        redirect_dest = ''

        print("to_be_deleted_name = {}".format(to_be_deleted_name))
        print("to_be_deleted_type = {}".format(to_be_deleted_type))

        confirmation = request.form["confirmation"]
        if confirmation == 'yes':
            print("user confirmed delete, deleting {} ({})".format(to_be_deleted_name, to_be_deleted_type))

            if to_be_deleted_type == 'Parameter':
                mongo_response = mongo.db.parameters.remove({"name" : to_be_deleted_name})
                redirect_dest = '/parameters'
            elif to_be_deleted_type == 'Scenario':
                mongo_response = mongo.db.parameter_tables.remove({"scenario_name" : to_be_deleted_name})
                redirect_dest = '/scenarios'
            else:
                return "ERROR: unrecognized type = {}".format(to_be_deleted_type)

            print(mongo_response)
        else:
            print("user rejected delete, NOT deleting {} ({})".format(to_be_deleted_name, to_be_deleted_type))

    return redirect(redirect_dest)

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS

@app.route('/uploads/<filename>')
def uploaded_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'],
                               filename)

@app.route('/import_json_form', methods=['POST'])
def import_json_form():

    template = env.get_template('import_json.html')
    return template.render()

@app.route('/import_json', methods=['POST'])
def import_json():
    if request.method == 'POST':
        print("method == POST")
        print("request = {}".format(request))
        print("form = {}".format(request.form))

        flask_file = request.files['json_file']
        if flask_file and allowed_file(flask_file.filename):
            filename = secure_filename(flask_file.filename)
            json_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            flask_file.save(json_path)

            print("json_path = {}".format(json_path))
            print("file = {}".format(flask_file))

            # do import
            with open(json_path, 'r') as json_file:
                json_objects = json.load(json_file)
                for json_object in json_objects:
                    name = json_object["name"]
                    if "_id" in json_object:
                        del json_object["_id"]
                    mongo.db.parameters.update({'name':name}, json_object, upsert=True)
                    print("inserted name = {}".format(name))

    return redirect("/parameters")

def unique_app_names():
    unique_names = []
    app_names = mongo.db.parameters.distinct('tunable_for')

    for app_name in app_names:
        trimmed_app_name = app_name.strip()
        if trimmed_app_name: # skip blanks
            split_names = trimmed_app_name.split(',')
            for name in split_names:
                trimmed_name = name.strip()
                if trimmed_name not in unique_names:
                    unique_names.append(trimmed_name)

    return unique_names

if __name__ == '__main__':
    app.config["SECRET_KEY"] = ")\xf1/T\xc1'\xe7\x8e)\x89\xdc\xf3\xdf4\xd5\x99\x89\xedd\xdd\x99\xec\xce&"

    if len(sys.argv) > 1 and sys.argv[1] == 'local':
        print("Listening on 127.0.0.1 ONLY (Test/Dev)")
        app.run(debug=True)
    else:
        print("Listening for remote connections")
        app.run(host='0.0.0.0', debug=True)


