#! /usr/bin/env python3

'''
Created on Oct 8, 2014

@author: pgray
'''

######################################################
################# initial setup ######################
######################################################

from flask import Flask, redirect, render_template, request
from flask_pymongo import PyMongo
from bson.json_util import dumps
from datetime import datetime

from jinja2 import Environment, PackageLoader

import json, subprocess, os, copy

app = Flask(__name__)
app.config['MONGO_DBNAME'] = 'procedures'
mongo = PyMongo(app)

env = Environment(loader=PackageLoader('procs_app', 'templates'))

######################################################
################# functions and db work ##############
######################################################

test_proc_list = []
test_proc_list.append({'ID': 'HIL-SW-TC-0001', 'summary' : 'verify hardware config', 'actions' : ['compare wiring harness to diagram', 'next action', 'third action'], 'expected_results' : 
	'hardware config matches desired test config'})
test_proc_list.append({'ID': 'HIL-SW-TC-0002', 'summary' : 'charge battery', 'actions' : ['use solar panel power inputs to supply current for charging batteries'], 'expected_results' : 
	'verify expected currents on systems display', 'discrepancies' : 'SW-925'})
test_proc_list.append({'ID': 'HIL-SW-TC-0003', 'summary' : 'power up vehicle', 'actions' : ['use e-stop radio to activate power system on vehicle'], 'expected_results' : 'verify FTP load'})

######################################################
################# web app routes #####################
######################################################

@app.route('/', methods=['GET'])
def main():
	if request.method == "GET":

		tests_list = []
		query_criteria = {"finished" : "true"}
		current_tests = mongo.db.test_source.find(query_criteria)
		for test in current_tests:
			tests_list.append(test)
		return render_template('procs_main.html', tests_list=tests_list)
	else:
		pass

@app.route('/test_page/<test_num>/', methods=['GET','POST'])
def test_page(test_num):
	if request.method == "GET":

		tests_list = []		
		query_criteria = {"finished" : "true"}
		current_tests = mongo.db.test_source.find(query_criteria)
		for test in current_tests:
			tests_list.append(test)
		
		query_criteria = {}
		query_criteria["test_num"] = test_num
		test_for_current_page = mongo.db.test_source.find_one_or_404(query_criteria)

		current_test_runs_list = []
		query_criteria = {}
		query_criteria["test_num"] = test_num
		query_criteria["finished"] = "true"
		current_test_runs = mongo.db.test_runs.find(query_criteria)
		for run in current_test_runs:
			current_test_runs_list.append(run)

		current_test_procs_list = []
		query_criteria = {}
		query_criteria["test_num"] = test_num
		current_test_procs = mongo.db.proc_source_db.find(query_criteria)
		for proc in current_test_procs:
			current_test_procs_list.append(proc)

		return render_template('test_page.html', tests_list=tests_list, current_test_runs_list=current_test_runs_list, test_num=test_num, 
			test_for_current_page=test_for_current_page, current_test_procs_list=current_test_procs_list)
	if request.method == "POST":

		query_criteria = {}
		query_criteria["test_num"] = test_num
		next_run_num = mongo.db.test_runs.find(query_criteria).count()

		mongo.db.test_runs.insert(
				{
					"run_num" : str(next_run_num),
					"test_num" : str(test_num),
					"time_created" : datetime.now(),
					"finished" : "false"
				})
		return redirect('/run_test/' + test_num + '/' + str(next_run_num) + '/' + '0')

@app.route('/view_test/<test_num>/<run_num>/<proc_num>', methods=['GET'])
def view_test(test_num, run_num, proc_num):
	if request.method == "GET":
		submit = request.args.get('submit')

		tests_list = []		
		query_criteria = {"finished" : "true"}
		current_tests = mongo.db.test_source.find(query_criteria)
		for test in current_tests:
			tests_list.append(test)

		query_criteria = {}
		query_criteria["test_num"] = str(test_num)
		requested_test = mongo.db.test_source.find_one_or_404(query_criteria)

		query_criteria = {}
		query_criteria["proc_num"] = proc_num
		query_criteria["test_name"] = requested_test["test_name"]
		requested_proc_source = mongo.db.proc_source_db.find_one_or_404(query_criteria)

		
		query_criteria = {}
		query_criteria["test_name"] = requested_test["test_name"]
		current_test_proc_sources = mongo.db.proc_source_db.find(query_criteria)
		procs_list = []
		for proc in current_test_proc_sources:
			procs_list.append(proc)

		query_criteria = {}
		query_criteria["proc_num"] = proc_num
		query_criteria["test_num"] = test_num
		query_criteria["run_num"] = run_num
		requested_proc_record = mongo.db.recorded_tests.find_one_or_404(query_criteria)

		query_criteria = {}
		query_criteria["test_num"] = test_num
		query_criteria["run_num"] = run_num
		all_current_test_procs = mongo.db.recorded_tests.find(query_criteria)
		last_proc = True
		for proc in all_current_test_procs:
			if proc['proc_num'] > proc_num:
				last_proc = False

		return render_template('view_test.html', requested_proc_source=requested_proc_source, requested_proc_record=requested_proc_record, 
			requested_test=requested_test, tests_list=tests_list, last_proc=last_proc, procs_list=procs_list)



@app.route('/run_test/<test_num>/<run_num>/<proc_num>', methods=['GET','POST'])
def run_test(test_num, run_num, proc_num):
	if request.method == "GET":

		tests_list = []
		query_criteria = {"finished" : "true"}
		current_tests = mongo.db.test_source.find(query_criteria)
		for test in current_tests:
			tests_list.append(test)

		query_criteria = {}
		query_criteria["test_num"] = str(test_num)
		requested_test = mongo.db.test_source.find_one_or_404(query_criteria)

		query_criteria = {}
		query_criteria["proc_num"] = proc_num
		query_criteria["test_name"] = requested_test["test_name"]
		requested_proc = mongo.db.proc_source_db.find_one_or_404(query_criteria)
		
		query_criteria = {}
		query_criteria["test_name"] = requested_test["test_name"]
		proc_count_for_test = mongo.db.proc_source_db.find(query_criteria).count()

		current_test_procs_list = []
		query_criteria = {}
		query_criteria["test_num"] = test_num
		current_test_procs = mongo.db.proc_source_db.find(query_criteria)
		for proc in current_test_procs:
			current_test_procs_list.append(proc)

		final_proc = False
		if proc_count_for_test == int(proc_num) + 1:
			final_proc = True

		return render_template('procs_main.html', tests_list=tests_list, requested_proc=requested_proc, requested_test=requested_test, final_proc=final_proc, 
			run_num=run_num, current_test_procs_list=current_test_procs_list)
	elif request.method == "POST":

		actions = request.form.getlist('actions')
		discrepancies = request.form['discrepancies']
		notes = request.form['notes']
		red_lines = request.form['red_lines']
		submit = request.form['submit']

		mongo.db.recorded_tests.insert(
				{
					"run_num" : str(run_num),
					"test_num" : str(test_num),
					"proc_num" : str(proc_num),
					"time_created" : datetime.now(),
					"actions" : actions,
					"discrepancies" : discrepancies,
					"notes" : notes,
					"red_lines" : red_lines
				})
		if submit == "Confirm and Finish Test":
			query_criteria = {}
			query_criteria["test_num"] = test_num
			query_criteria["run_num"] = run_num
			current_test = mongo.db.test_runs.find_one_or_404(query_criteria)
			current_test["finished"] = "true"

			mongo.db.test_runs.update(
				{
					"test_num" : test_num,
					"run_num" : run_num
				},
				{
					"run_num" : current_test["run_num"],
					"test_num" : current_test["test_num"],
					"time_created" : current_test["time_created"],
					"finished" : current_test["finished"]
				})

			return redirect('/test_page/' + str(test_num))
		else:
			return redirect('/run_test/' + test_num + '/' + run_num + '/' + str(int(proc_num)+1))
	else:
		pass

@app.route('/create_new_test', methods=['POST'])
def create_new_test():
	if request.method == "POST":
		submitted_test_name = request.form['submitted_test_name']
		description = request.form['description']

		test_list_count = mongo.db.test_source.find().count()
		mongo.db.test_source.insert(
			{
				"test_num" : str(test_list_count),
				"time_created" : datetime.now(),
				"test_name" : submitted_test_name,
				"description" : description,
				"finished" : "false"
			})
		return redirect('/create_procs/' + str(test_list_count) + '/0')

@app.route('/create_procs/', methods=['GET', 'POST'])
def initial_create_new_procs():
	if request.method == "GET":

		tests_list = []
		query_criteria = {"finished" : "true"}
		current_tests = mongo.db.test_source.find(query_criteria)
		for test in current_tests:
			tests_list.append(test)

		new_test = True

		return render_template('create_procs.html', new_test=new_test, tests_list=tests_list)

@app.route('/create_procs/<test_num>/<proc_num>', methods=['GET', 'POST'])
def create_new_procs(test_num, proc_num):
	if request.method == "GET":

		tests_list = []
		query_criteria = {"finished" : "true"}
		current_tests = mongo.db.test_source.find(query_criteria)
		for test in current_tests:
			tests_list.append(test)

		proc_list = []

		query_criteria = {}
		query_criteria["test_num"] = str(test_num)
		current_test = mongo.db.test_source.find_one_or_404(query_criteria)

		query_criteria = {}
		query_criteria["test_name"] = current_test['test_name']
		current_test_procs = mongo.db.proc_source_db.find(query_criteria)
		for proc in current_test_procs:
			proc_list.append(proc)
		
		adding_proc = True

		return render_template('create_procs.html', proc_list=proc_list, adding_proc=adding_proc, current_test=current_test, proc_num=proc_num, tests_list=tests_list)

	elif request.method == "POST":
		ID = request.form['ID']
		summary = request.form['summary']
		actions = request.form['actions']
		expected_results = request.form['expected_results']
		submit = request.form['submit']

		query_criteria = {}
		query_criteria["test_num"] = str(test_num)
		current_test = mongo.db.test_source.find_one_or_404(query_criteria)
		
		actions_list = []
		if actions:
			actions_list = actions.split(', ')
		#create proc document and submit to the DB
		mongo.db.proc_source_db.update(
			{
				"proc_num" : proc_num, 
				"test_num" : test_num
			},
			{
				"time_created" : datetime.now(),
				"test_name": current_test['test_name'],
				"test_num": test_num,
				"proc_num" : proc_num,
				"ID" : ID,
				"summary" : summary,
				"actions" : actions_list,
				"expected_results" : expected_results
			}, 
			upsert=True)

		if submit == "Next":
			return redirect('/create_procs/' + test_num + '/' + str(int(proc_num)+1))
		elif submit == "Done with Test":
			query_criteria = {}
			query_criteria["test_num"] = str(test_num)
			current_test = mongo.db.test_source.find_one_or_404(query_criteria)

			current_test["finished"] = "true"

			mongo.db.test_source.update(
				{
					"test_num" : test_num
				},
				{
					"_id" : current_test["_id"],
					"test_num" : current_test["test_num"],
					"time_created" : current_test["time_created"],
					"test_name" : current_test["test_name"],
					"description" : current_test["description"],
					"finished" : current_test["finished"]
				})
			return redirect('/')


    
if __name__ == '__main__':
    app.config["SECRET_KEY"] = b'T\xabe\x96O:\xfah\x89\x06\xbf\xa7\x07\xa2u\xb0\x08\xfaj\xc3\x05\xbc\xef<'
    app.run(port=int("3500"), debug=True)
    

