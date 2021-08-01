#!/usr/bin/env python

#import necessary libraries
# pip install flask 
#export FLASK_APP=nobel-flask-app
#flask run
from flask import Flask, json, render_template, request, jsonify

import os

#create instance of Flask app
app = Flask(__name__)

#decorator
@app.route('/', methods=['GET'])
def home():
    return """<h1>Nobel Prize API HW</h1><p>This site is a prototype API for accessing Nobel Prize information.</p>
    <h2>How to use this API</h2>
    <p>To display all of the Nobel Prize info: please add '/v1/prizes/all' to the end of the original URL</p>
    <p>To display all of the Nobel Prize info for a certain year: please add '/v1/prizes/?year=YEAR' to the end of the original URL</p>
    <p>To add information to the API</p>
    <p>This is a basic web or REST API. APIs are important because they let two applications talk to each other, while providing a layer of security
    for both applications by limiting what they access. Other types of APIs include Open APIs and Internal APIs.</p>"""

# a route to return all of the nobel prize data in the file
@app.route('/v1/prizes/all', methods=['GET'])
def nobel_all():
    json_url = os.path.join(app.static_folder,"","nobel.json")
    data_json = json.load(open(json_url))
    #use jsonify to make sure the data is returned in a json format
    return jsonify(data_json)

# a route to return nobel prize data by year
@app.route('/v1/prizes', methods=['GET'])
def nobel_year():
    json_url = os.path.join(app.static_folder,"","nobel.json")
    data_json = json.load(open(json_url))
    # Check if a year was provided as part of the URL.
    # If year is provided, assign it to a variable.
    # If no year is provided, display an error in the browser.
    if 'year' in request.args:
        year = request.args['year']
    else:
        return "Error: No year field provided. Please specify a year."

    # Create an empty list for our results
    results = []

    # Loop through the data and match results that fit the requested ID.
    # IDs are unique, but other fields might return many results

    for x in data_json["prizes"]:
        if x["year"] == year:
            results.append(x)

    # Use the jsonify function from Flask to convert our list of
    # Python dictionaries to the JSON format.
    return jsonify(results)

# a route for adding nobel prize data
@app.route('/v1/prizes/new', methods=['POST', 'GET'])
def nobel_new():
    if request.method == 'POST':
        data = request.form
        with open('./static/nobel.json', 'r+') as file:
            file_data = json.load(file)
            file_data['prizes'].append(data)
            # Sets file's current position at offset.
            file.seek(0)
            # convert back to json.
            json.dump(file_data, file, indent = 4)
        return redirect(url_for('user', usr =data))
    else:
        return render_template('add-new.html')

@app.route('/<usr>')
def user(usr):
    return f"<h1>{usr}</h1>"

if __name__ == "__main__":
    app.run(debug=True)