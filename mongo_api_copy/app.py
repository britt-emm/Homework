from datetime import datetime
from flask import Flask, render_template, request, redirect
from flask_pymongo import PyMongo
import os
import datetime

app=Flask(__name__)

#setup mongo connection
app.config["MONGO_URI"] = "mongodb://localhost:27017/shows_db"
mongo = PyMongo(app)

#connect to collection
tv_shows = mongo.db.tv_shows

#READ
@app.route("/")
def index():
    #find all items and save to variable
    all_shows = list(tv_shows.find())
    print(all_shows)

    return render_template("index.html",data=all_shows)

#CREATE
@app.route("/add", methods=['POST','GET'])
def create():
    if request.method == "POST":
        data = request.form

        post_data = {'name':data['show_name'],
            'seasons':data['seasons'],
            'duration':data['duration'],
            'year':data['start_year'],
            'date added': datetime.datetime.utcnow()}
        
        tv_shows.insert_one(post_data)

        return '<p> Data Added </p>'
    else:
        return render_template('add_record.html')


#DELETE
@app.route("/delete", methods=['POST', 'GET'])
def delete():
    if request.method == "POST":
        # data in a dictionary
        data = request.form
        
        tv_shows.delete_one({'name':data['show_name']})

        return '<p> Data deleted </p>'
    else:
        return render_template('delete_record.html')

#UPDATE
@app.route("/update", methods=["POST", "GET"])
def update():
    if request.method == 'POST':
        #data in a dictionary
        data = request.form
        update_show = {"name" :data['namefind']}

        post_data = { '$set': {'name': data['show_name'],
            'seasons':data['seasons'],
            'duration':data['duration'],
            'year':data['start_year']}}
        
        tv_shows.update_one(update_show, post_data)

        return '<p>Data updated </p>'
    else:
        return render_template('update_record.html')


if __name__ == "__main__":
    app.run(debug=True)