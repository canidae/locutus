#!/usr/bin/perl
use strict;
use warnings;

use lib '../include';
use Locutus;

my $page = 'file';
my $vars = {
	message  => "Hello world"
};

Locutus::process_template($page, $vars);
