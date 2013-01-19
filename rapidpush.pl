#!/usr/bin/perl -w
# RapidPush
#
# Copyright (c) 2010, Zachary West
# All rights reserved.
# Rafactoring to RapidPush: Christian Ackermann
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of Zachary West nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY Zachary West ''AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL Zachary West BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# RapidPush IS NOT RELATED TO PROWL OR ZACHARY WEST OR NOTIFY MY ANDROID. SEPARATE PROJECTS WITH A SIMILAR API.
#
# This requires running RapidPush on your device.
# See the RapidPush website <http://rapidpush.net> for additional information.
#
# Depends on:
#	libjson   (ubuntu: sudo apt-get install libjson-perl)
#	ssl 	  (ubuntu: sudo apt-get install libcrypt-ssleay-perl)
#	UserAgent (ubuntu: sudo apt-get install liblwp-useragent-determined-perl)
#	Strptime  (ubuntu: sudo apt-get install libdatetime-format-strptime-perl)
#

use strict;
use LWP::UserAgent;
use Getopt::Long;
use Pod::Usage;
use JSON;
use DateTime::Format::Strptime;
use HTTP::Date;
# Grab our options.
my %options = ();
GetOptions(\%options, 'apikey=s',
		  'category=s', 'title=s', 'message=s', 'group=s', 'schedule_at=s',
		  'priority:i') or pod2usage(2);

$options{'category'} ||= "RP-Perl";
$options{'group'} ||= "";
$options{'title'} ||= "New event";
$options{'schedule_at'} ||= "";
$options{'priority'} ||= 2;

pod2usage(-message => "$0: Message is required") if (!exists($options{'message'}));
pod2usage(-message => "$0: The apikey is required") if (!exists($options{'apikey'}));
pod2usage(-message => "$0: Priority must be between 0 and 6 (0=debug, 1=notice, 2=normal, 3=warning, 4=alert, 5=critical, 6=emergency)") if ($options{'priority'} < 0 || $options{'priority'} > 6);


# Generate our HTTP request.
my $browser = LWP::UserAgent->new;
my $url = 'https://rapidpush.net/api';
my $schedule = "";
if (!($options{'schedule_at'} eq "")) {
	$schedule = POSIX::strftime("%Y-%m-%d %H:%M:00", gmtime(str2time($options{'schedule_at'})))
}

if ($schedule eq "1970-01-01 00:00:00") {
	$schedule = "";
}

my $response = $browser->post( $url, [ 
	'apikey' => $options{'apikey'},
	'command' => 'notify',
	'header_errors' => '1',
	'data' => to_json({
		title => $options{'title'},
		message => $options{'message'},
		category => $options{'category'},
		group => $options{'group'},
		schedule_at => $schedule,
		priority => $options{'priority'},
	}),
]);

if ($response->is_success) {
	print "Notification successfully send.\n";
} 
else {
	if ($response->code == 405) {
                print "Invalid parameter\n";
	}
        elsif ($response->code == 407) {
                print "Could not insert notification, internal error\n";
	}
        elsif ($response->code == 408) {
                print "Invalid API-Key.\n";
	}
        elsif ($response->code == 409) {
                print "Invalid command\n";
	}
	elsif ($response->code == 410) {
                print "API rate limit exceeded\n";
	}
        else {
                print "Unknown error while sending RapidPush notification\n";
	}
}

__END__

=head1 NAME 

RapidPush - Send push notifications

=head1 SYNOPSIS

rapidpush.pl [options] notification_data

 Options:
   -apikey=...        the RapidPush API key.

 Notification data:
   -message=...       The text of the notification.
   -category=...      The category (optional).
   -title=...         The title (optional).
   -group=...         The device group (optional).
   -priority=...      The priority, a number between 0 and 6 (optional).
   -schedule_at=...    The schedule time, given in Y-m-d H:i:00 (2013-01-10 23:05:00) will notify at the given time and date (optional).

=head1 DESCRIPTION

This tool will send the provided notification over the RapidPush API-Service to your devices.

=head1 HELP

If you have additional questions, don't hesitate to visit <http://rapidpush.net>.

=cut
