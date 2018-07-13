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
my $LEX_ARG = "--lex";
my $PARSER = "$ABS/../src/parser.hh";
my $TOKENS = parser_tokens();

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
	my $pid = open3(my $in, my $out, my $err, $BIN, $LEX_ARG)
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

sub parser_tokens() {
	my @data = read_file($PARSER)
	or die "Can't read $PARSER: $!";

	my @result = ();

	my $inside = 0;
	foreach my $line (@data) {
		if ($inside) {
			last if $line =~ /}/;

			if (my ($token, $id) = $line =~ /^\s*T_(\w+)\s*=\s*(\d+),?\s*$/) {
				$result[$id] = $token;
			}
		} elsif ($line =~ /enum yytokentype/) {
			$inside = 1;
		}
	}

	return \@result;
}
