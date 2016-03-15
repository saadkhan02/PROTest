#!/usr/bin/perl

use strict;
use diagnostics;
use warnings;

use TestBase;
use Test::More;
use Data::Dumper;

plan tests => 9;

# Sample test - Logs into a website.

# This helps us to start a browser session. Needless to say, without this
# all other steps fall on their faces.
TestBase::start("Firefox");
# For documentation of TestBase functions, please browse TestBase.pl.
# Browse to main page.
TestBase::browse("");
# Click on the login button to get focus.
TestBase::clickElement("/html/body/nav/div/div[2]/ul/li[7]/a", "xpath");
# Type username.
TestBase::type("email", "id", "");
# Type password.
TestBase::type("password", "id", "");
# Click on the login button.
TestBase::clickElement("/html/body/nav/div/div[2]/ul/li[7]/ul/li[1]/div/form".
    "/div[4]/button", "xpath");
# Check whether the header is displayed after login.
TestBase::checkText("/html/body/div/div/h2", "xpath", "User Home Page");
# Check whether the welcome message is displayed
TestBase::checkText("/html/body/div/div/form", "xpath", "Welcome User");
# Close the browser and aggregate the tests.
TestBase::stop();
