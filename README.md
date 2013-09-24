# RapidPush perl plugin
This perl script is used to send notifications to your android devices using the RapidPush-Service.

# What is RapidPush?
RapidPush is an easy-to-use push notification service.
You can receive notifications from third-party applications like nagios, github or flexget directly to your smartphone.
With our simple API you can also implement RapidPush to your own software.

# Dependencies
This perl plugin depends on:
- libjson-perl
- libdatetime-format-strptime-perl

On Ubuntu/Debian write:
sudo apt-get install libjson-perl libdatetime-format-strptime-perl

# How to use
Make sure that you have an account on [RapidPush](http://rapidpush.net) and got an API-Key which you can create within your user interface.
Also make sure **rapidpush.pl** has executeable permission.
After you checked this just execute the file by **./rapidpush.pl**.
You will find all needed informations what parameter an be used.
