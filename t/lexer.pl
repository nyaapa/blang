#!/usr/bin/perl

use 5.026;
use warnings;
use feature qw(signatures);
no warnings qw(experimental::signatures);

use Test::More;
use Cwd qw/abs_path/;
use YAML::XS;
use File::Slurp;
use IPC::Open3;
use List::Util qw/max/;

use Data::Dumper;

(my $ABS = abs_path($0)) =~ s@/[^/]+$@@;
my $BIN = "$ABS/../src/blangc";
my $LEXER = "$ABS/../src/lexer.hpp";
my $TOKENS = lexer_tokens();

foreach my $fixture ( <$ABS/lexer/*.yml> ) {
	(my $relative = $fixture) =~ s@\Q$ABS/\E@@;
	pass($relative);
	if ( my $ymls = eval { [Load(scalar(read_file($fixture)))] } ) {
		foreach my $yml ( @$ymls ) {
			unless ( $yml ) {
				warn "Some empty test in $fixture";
				next;
			}

			if ( my $flat_res = eval { lex_code($yml->{in}) } ) {
				subtest $yml->{name} => sub {
					my @res = split /\n/, $flat_res;
					for (my $i = 0; $i < max(scalar(@res), scalar(@{$yml->{out}})); ++$i) {
						$res[$i] =~ s@^(\d+)=(.*)@($TOKENS->[$1] // "unknown $1") . "=" . eval($2)@me;
						my $expected = uc($yml->{out}[$i][0]) . "=" . ($yml->{out}[$i][1] // 0);
						is($res[$i], $expected, (substr($res[$i], 0, 15) . (length($res[$i]) > 15 ? "..." : "")));
					}
				}
			} else {
				fail("Failed to lex $yml->{in}: $@");
			}
		}
	} else {
		fail("Can't parse $fixture: $@");
	}

}

done_testing();

sub lex_code($input) {
	my $pid = open3(my $in, my $out, my $err, $BIN)
		or die "Can't run blangc: $!";

	$in->print($input)
		or die "Can't feed $input: $!";

	close($in)
		or warn "Can't close cl stdin: $!";

	my $result = join "", <$out>;
	waitpid($pid, 0);

	my $child_exit_status = $? >> 8;
	$child_exit_status
		and die "Bad exitcode from lexer: $child_exit_status"; 

	return $result;
}

sub lexer_tokens() {
	my @data = read_file($LEXER)
		or die "Can't read $LEXER: $!";

	my @result = ();

	my $inside = 0;
	for (my $i = 0; $i < @data; ++$i) {
		if ($inside) {
			last if $data[$i] =~ /}/;
			my $cleaned = $data[$i];
			$cleaned =~ s@//.*$@@;
			$cleaned =~ s/\s|,//g;
			push @result, $cleaned if $cleaned;
		} elsif ($data[$i] =~ /enum class Type/) {
			$inside = 1;
		}
	}

	return \@result;
}
