#!/usr/bin/perl

#$Id$

# quick dirty testing for Lyrics::Fetcher::LyricWiki
#
# TODO: turn this into a proper test script with Test::Simple / Test::More.
# Since some of the testing logic is reasonbly complex, it was easier to do
# it manually rather than ending up with long-winded ok() and like() tests,
# but that's not the Right Way to do it.

use strict;
use warnings;

use lib '../lib/';
require Lyrics::Fetcher::LyricWiki;


# we have a set of tests, some of which should work, some of which should
# fail.  Each test is a hashref, with the following keys:
#   title   => the song title
#   artist  => the artist
#   lookfor => qr/..../  - the lyrics returned must match this regexp
#   fail    => 1  (optional - if true, then this request should fail)
#   error   => '....'  - if fail is used, then eror gives the error
#               message that we expect to see upon failure
my @tests = (

    {
        title   => 'Cast No Shadow',
        artist  => 'Oasis',
        lookfor => qr/As he faced the sun he cast no shadow/,
    },
    {
        title   => 'What Sarah Said',
        artist  => 'Death Cab For Cutie',
        lookfor => qr/every plan is a tiny prayer to father time/,
    },
    {
        title   => 'Heavy Fuel',
        artist  => 'Dire Straits',
        lookfor => qr/Last time I was sober, man I felt bad/i,
    },
    {
        title   => 'Turn Up The Sun',
        artist  => 'Oasis',
        lookfor => qr/Come on, Turn up the sun/i,
    },
    {
        title   => 'High Speed Train',
        artist  => 'REM',
        lookfor => qr/jump on a high speed train/i,
    },
    {
        title   => 'Bohemian Like You',
        artist  => 'Dandy Warhols',
        lookfor => qr/feeling so bohemian like you/i,
    },
    {
        title   => 'Next Contestant',
        artist  => 'Nickelback',
        lookfor => qr/Is that your hand on my girlfriend/,
    },
    {
        title   => 'This Song Does Not Exist',
        artist  => 'Nobody In Particular',
        fail    => 1,
        error   => 'Lyrics not found',
    },
);

my $testnum = 0;
print "1.." . scalar @tests . "\n";
TEST: for my $test (@tests) {
    #printf "%s by %s\n", @$test{ qw(title artist) };
    $testnum++;
    
    my $lyrics = Lyrics::Fetcher::LyricWiki->fetch(@$test{ qw(artist title) });
    if ($test->{fail} && ($lyrics || $Lyrics::Fetcher::Error eq 'OK')) {
        print "not ok $testnum - test should fail, but didn't\n";
        next TEST;
    }
    
    
    if (!$test->{fail} && (!$lyrics || $Lyrics::Fetcher::Error ne 'OK')) {
        # it failed, when it's not supposed to
        print "not ok $testnum - failed ($Lyrics::Fetcher::Error)\n";
        next TEST;
    }
    
    if ($test->{fail}) {
        # this is a test which we expect to fail:
        if ($lyrics || $Lyrics::Fetcher::Error eq 'OK') {
            print "not ok $testnum - should have failed, but didn't\n";
            next TEST;
        }
        
        if ($test->{error} && $Lyrics::Fetcher::Error ne $test->{error}) {
            print "not ok $testnum - should have failed with $test->{error} "
                ."but it failed with $Lyrics::Fetcher::Error instead\n";
            next TEST;
        } else {
            # it failed with the error we expected it to fail with:
            print "ok $testnum\n";
            next TEST;
        }
    }
    
   # finally, did we get back some lyrics that look like what we wanted to see?
    if ($lyrics !~ $test->{lookfor}) {
        print "not ok $testnum lyrics didn't match expected pattern\n";
        next TEST;
    }
    
    print "ok $testnum\n";

}
