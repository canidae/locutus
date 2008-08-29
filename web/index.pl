#!/usr/bin/perl
use strict;
use warnings;
use Template;

my $file = 'main.tmpl';
my $vars = {
	message  => "Hello world"
};

print "Content-type: text/html\n\n";

my $template = Template->new({
		INCLUDE_PATH => '../templates'
	});

$template->process($file, $vars) || die "Template process failed: ", $template->error(), "\n";
