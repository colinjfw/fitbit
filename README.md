# Fitbit Sleep Cycle Analyzer
I built this project to create a sleep cycle analyzer from my Fitbit data. I am very interested in the change in sleep patterns across people, and I think there is a lot you can tell from someone's sleep. Fitbit unfortunately does not calculate sleep cycles, but they do give second level heart rate data and accelerometer data for a person's sleep. This app combines this data and then applies an algorithm that I built to analyze a person's sleep. I hope to continue working on this project and promote it once I finalize the algorithm to help people understand their sleep cycles better.

This project depends on the gem at https://github.com/ColDog/oauth2-fitbit-rails

View the project at: http://fitbit-colin.herokuapp.com/ (note you need a fitbit to do anything with it!)

## Screenshot
![screenshot](https://colin-w-info-uploads.s3.amazonaws.com/images/1436801431_shot-fitbit.png)

## Overview
The Fitbit API was the major challenge to this project. I could not find a suitable Oauth2 gem or a suitable gem to hook into the Fitbit API. As a result, I ended up building my own client gem linked above. I did not want it attached to the project for both reusability and testing purposes. It ended up being a good exercise.

The project is very simply in layout. I have a home controller, a user controller and a controller to handle the Oauth callbacks. The user simply signs in with Fitbit, where I use the ID they send to create a user in the database. It is basically a one page app, the user signs in and is then directed to the users controller, where they can select a date to view their sleep patterns. The difficulty in this project came down to analyzing the data in a quick and efficient manner.

The App gets your sleep data from Fitbit which includes high level information from the accelerometer, giving you a basic idea of how restless you were. It then gets makes a call to the heart rate endpoint based on the length of your sleep and gets the second level heart rate data. Finally, it takes these two separate JSON strings, and builds them into one two dimensional array, including the sleep stages (my own algorithm), moving averages, overall average, volatility and resting heart rate.

To get all the data I need to build a chart like in the picture above, I need to make at least three different API calls, sometimes four depending on the date. One of the trickier parts was figuring out the date of the sleep, and getting the exact series for the heart rate that was needed, since the measurements for the accelerometer and the heart rate come in different series, this meant I had to develop a data structure to quickly search through heart rate data and find the corresponding time for the accelerometer, and then place both of those in the same, new, data structure. Everything is saved to a big Postgres array. It takes around 100ms to actually save the data, but once it is saved there is no reason to need to modify the data unless the algorithm changes.

My own sleep cycle algorithm is not yet finished. I'm really enjoying the intellectual challenge in taking this on, however. Not being a professional sleep scientist, it's obviously a challenge to interpret the data. That being said, to just get a high level overview of where your approximate sleep stage was, I think, is possible to do without to much complication from the heart rate and accelerometer data. Stay tuned for more updates on this though!

## The Gem
I ended up building my own Gem based on Faraday to hook into the Fitbit API, and provide the Oauth2 client. It ended up being much more simple than using a high level strategy, I think the problem with the current gems available is that you still have to roll your own token refreshing system and handle errors in case a token does sit for too long. In the end you end up rebuilding whatever you started with. That being said, I would like to work on extracting out the logic in the gem to generalize it for any api. I think it's useful going with a Rails version as well, I haven't seen this yet on GitHub, and it allows me to simply call update on the initialized User object to update tokens.
