#!/usr/bin/perl

use 5.020;
use warnings;

use IPC::Open3;

sub BIN { "/home/nyaapa/blang/src/blang" }


my $pid = open3(my $in, my $out, my $err, BIN);
$in->print("auto a = 42;");
close($in) or warn "Can't close cl stdin: $!";

print for <$out>;
waitpid($pid, 0);
my $child_exit_status = $? >> 8;
