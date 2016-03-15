#!/usr/bin/perl

package TestBase;

use strict;
#use warnings;
use diagnostics;

use Data::Dumper;
use Test::More;

use Selenium::Remote::Driver;
use Selenium::Remote::WebElement;
use Selenium::Remote::WDKeys;

use Exporter qw(import);
our @EXPORT_OK = qw(start stop browse type clickElement select count title find
                    countEquals countLessThan countLessThanEquals
                    countGreaterThan countGreaterThanEquals);

my $driver = undef;

##
# Start user choice browser.
#
# @param browserChoice Choice of browser to run the tests in.
#
sub start($;$)
{
    my ($browserChoice, $message) = @_;

    if ($browserChoice eq "Firefox") {
        $driver = Selenium::Remote::Driver->new();
    }

    my $ret = $driver->status;
    if (!defined($message)) {
        $message = "Started browser: " . $browserChoice;
    }

    ok(defined($ret), $message);
}

##
# Closes the browser.
#
sub stop(;$)
{
    my ($message) = @_;
    my $ret = $driver->quit;
    if (!defined($message)) {
        $message = "Closed browser.";
    }

    ok(!defined($ret), $message);
}

sub findElement($$)
{
    my ($locator, $locatorScheme) = @_;

    my $element;

    if ($locatorScheme eq "class") {
        $element = $driver->find_element_by_class($locator);
    }
    elsif ($locatorScheme eq "class_name") {
        $element = $driver->find_element_by_class_name($locator);
    }
    elsif ($locatorScheme eq "css") {
        $element = $driver->find_element_by_css($locator);
    }
    elsif ($locatorScheme eq "id") {
        $element = $driver->find_element_by_id($locator);
    }
    elsif ($locatorScheme eq "link") {
        $element = $driver->find_element_by_link($locator);
    }
    elsif ($locatorScheme eq "link_text") {
        $element = $driver->find_element_by_link_text($locator);
    }
    elsif ($locatorScheme eq "partial_link_text") {
        $element = $driver->find_element_by_partial_link_text($locator);
    }
    elsif ($locatorScheme eq "tag_name") {
        $element = $driver->find_element_by_tag_name($locator);
    }
    else {
        # Default method is xpath.
        $element = $driver->find_element_by_xpath($locator);
    }

    if (!defined($element)) {
        $element = undef;
    }

    return $element;
}

##
# Counts the number of elements in a table.
#
# @param
# @param
#
# @return -1 if the table does not exist.
# @return Number of rows in the table if it exists.
#
sub count($$)
{
    my ($locator, $locatorScheme) = @_;

    my $numberOfRows = -1;
    
    my @elements;

    my $element = findElement($locator, $locatorScheme);

    if (defined($element)) {
        @elements = $driver->find_child_elements($element, "tr", "tag_name");
        $numberOfRows = scalar(@elements);
    }

    return $numberOfRows;
}

##
# Clicks on the active element.
#
# @param locator locator string to locate the web element.
# @param locatorScheme class, css, id, link, link_text, partial_link_text,
#                      tag_name, name, xpath (default).
#
sub performClick($$)
{
    my ($locator, $locatorScheme) = @_;

    my $ret = 0;

    my $element = findElement($locator, $locatorScheme);

    if (defined($element)) {
        $element->click();
        $ret = 1;
    }

    return $ret;
}

##
# Clicks on the active element.
#
sub clickElement($$;$)
{
    my ($locator, $locatorScheme, $message) = @_;

    my $ret = performClick($locator, $locatorScheme);

    if (!defined($message)) {
        $message = "Clicked on element with " . $locatorScheme . ": " .
            $locator;
    }

    ok($ret, $message);
}

##
# Sends keyboard strokes to selected element.
#
# @param locator Locator string of the web element.
# @param locatorString Locator scheme of the web element - xpath by default.
# @param keyboardInput Keyboard input.
#
sub type($$$;$)
{
    my ($locator, $locatorScheme, $keyboardInput, $message) = @_;

    my $ret = performClick($locator, $locatorScheme);
    $driver->send_keys_to_active_element($keyboardInput);

    if (!defined($message)) {
        $message = "Wrote \"" . $keyboardInput . "\" on element with " .
            $locatorScheme . ": " . $locator;
    }

    ok($ret, $message);
}

##
# Selects something from the drop down menu.
#
# @param locator Locator string of the web element.
# @param locatorString Locator scheme of the web element - xpath by default.
# @param selection Choice from the drop down.
#
sub select($$$;$)
{
    my ($locator, $locatorScheme, $selection, $message) = @_;

    my $ret = performClick($locator, $locatorScheme);
    $driver->send_keys_to_active_element($selection);
    $driver->send_keys_to_active_element(KEYS->{'TAB'});

    if (!defined($message)) {
        $message = "Selected \"" . $selection . "\" option in element with " .
            $locatorScheme . ": " . $locator;
    }

    ok($ret, $message);
}

##
# Browse to a certain page.
#
# @param page URL of the page we need to browse to.
#
sub browse($;$)
{
    my ($page, $message) = @_;

    $driver->get($page);
    my $ret = $driver->status;
    if (!defined($message)) {
        $message = "Browsed to page: ${page}";
    }

    ok($ret, $message);
}

##
# Compare number of rows in the table against an expected value.
#
# @param locator
# @param locatorScheme
#
sub countEquals($$$)
{
    my ($locator, $locatorScheme, $expected) = @_;

    my $count = count($locator, $locatorScheme);
    is($count, $expected, "Row count as expected.");
}

##
# Validates count of table rows to be less than the expected value.
#
# @param
# @param
# @param
#
sub countLessThan($$$)
{
    my ($locator, $locatorScheme, $expected) = @_;

    my $count = count($locator, $locatorScheme);
    ok($count < $expected, "Row count is less than expected(" . $expected .
        ").");
}

##
# Validates count of table rows to be greater than the expected value.
#
# @param
# @param
# @param
#
sub countGreaterThan($$$)
{
    my ($locator, $locatorScheme, $expected) = @_;

    my $count = count($locator, $locatorScheme);
    ok($count > $expected, "Row count is more than expected (" . $expected .
        ").");
}

##
# Validates count of table rows to be less than or equal to the expected value.
#
# @param
# @param
# @param
#
sub countLessThanEquals($$$)
{
    my ($locator, $locatorScheme, $expected) = @_;

    my $count = count($locator, $locatorScheme);
    ok($count <= $expected, "Row count is less than expected(" . $expected .
        ").");
}

##
# Validates count of table rows to be greater than or equal to the expected
# value.
#
# @param
# @param
# @param
#
sub countGreaterThanEquals($$$)
{
    my ($locator, $locatorScheme, $expected) = @_;

    my $count = count($locator, $locatorScheme);
    ok($count >= $expected, "Row count is more than expected (" . $expected .
        ").");
}

##
# Finds whether or not a particular element is present.
#
# @param locator
# @param locatorScheme
#
sub find($$)
{
    my ($locator, $locatorScheme) = @_;

    my $element = findElement($locator, $locatorScheme);

    if (defined($element)) {
        pass("Web element found.");
    }
    else {
        fail("Web element not found.");
    }
}

##
# Get title of the page.
#
# @param
#
sub title($)
{
    my ($expected) = @_;

    my $title = $driver->get_title();
    is($title, $expected, "Page title matches expected (" . $expected . ")");
}

##
# Checks whether an element is displayed.
#
# @param
# @param
#
sub isDisplayed($$)
{
    my ($locator, $locatorScheme) = @_;

    my $element = findElement($locator, $locatorScheme);
    if (!defined($element) || $element == 0) {
        fail("Failed to find element.");
    }
    else {
        ok($element->is_displayed(), "Element is displayed");
    }
}

##
# Checks whether an element is enabled.
#
# @param
# @param
#
sub isEnabled($$)
{
    my ($locator, $locatorScheme) = @_;

    my $element = findElement($locator, $locatorScheme);
    if (!defined($element) || $element == 0) {
        fail("Failed to find element.");
    }
    else {
        ok($element->is_enabled(), "Element is enabled.");
    }
}

##
# Checks whether an element is selected.
#
# @param
# @param
#
sub isSelected($$)
{
    my ($locator, $locatorScheme) = @_;

    my $element = findElement($locator, $locatorScheme);
    if (!defined($element) || $element == 0) {
        fail("Failed to find element.");
    }
    else {
        ok($element->is_selected(), "Element is selected.");
    }
}

##
# Checks the text of a web element.
#
# @param
# @param
# @param
#
sub checkText($$$)
{
    my ($locator, $locatorScheme, $text) = @_;
        my $element = findElement($locator, $locatorScheme);
    if (!defined($element) || $element == 0) {
        fail("Failed to find element.");
    }
    else {
        ok($element->get_text() eq $text, "Element has text: ${text}");
    }
}

##
# Checks whether an element is present.
#
# @param
# @param
#
sub valid($$)
{
    my ($locator, $locatorScheme) = @_;

    my $element = findElement($locator, $locatorScheme);
}

1;
