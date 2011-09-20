#!/usr/bin/perl -w

use strict;

die "Usage: $0 MAIN.bdf SUB.bdf OUT.bdf" unless @ARGV == 3;

open(my $f1, '<', $ARGV[0]) or die "$ARGV[0]: $!";
open(my $f2, '<', $ARGV[1]) or die "$ARGV[1]: $!";
open(my $fo, '>', $ARGV[2]) or die "$ARGV[2]: $!";

select $fo;
$\ = "\n";

sub read_header($)
{
	my ($f) = @_;
	my %h;
	die "not a font" unless <$f> eq "STARTFONT 2.1\n";
	local $_;
	while ($_ = <$f>) {
		chomp;
		my ($k, $v) = split / /, $_, 2;
		if (exists $h{$k}) {
			$h{$k} .= "\n$v";
		} else {
			$h{$k} = $v;
		}
		last if $k eq 'CHARS';
	}
	die "no chars" unless exists $h{CHARS};
	return \%h;
}

sub write_header($)
{
	my ($h) = @_;
	my %h = %$h;
	print "STARTFONT 2.1";
	print "COMMENT $_" for split /\n/, delete $h{COMMENT};
	print "$_ " . delete $h{$_} for qw(FONT SIZE FONTBOUNDINGBOX STARTPROPERTIES);
	my $n = delete $h{CHARS};
	delete $h{ENDPROPERTIES};
	print "$_ " . $h{$_} for keys %h;
	print 'ENDPROPERTIES';
	return $n;
}

sub read_char($)
{
	my ($f) = @_;
	my ($c, @d);
	local $_ = <$f>; chomp;
	return 99999 if $_ eq 'ENDFONT';
	die "not a char" unless $_ =~ /^STARTCHAR /;
	push @d, $_;
	$_ = <$f>; chomp;
	die "not a char" unless ($c) = $_ =~ /^ENCODING (.*)$/;
	push @d, $_;
	do
	{
		$_ = <$f>; chomp;
		push @d, $_;
	} while ($_ ne 'ENDCHAR');
	return ($c, \@d);
}

sub write_char($)
{
	my ($c) = @_;
	print for @$c;
}

my $h = read_header($f1);
my $h2 = read_header($f2);

$h->{COMMENT} .= "\n" . $h2->{FONT};
die "size mismatch\n" unless $h->{FONTBOUNDINGBOX} eq $h2->{FONTBOUNDINGBOX};

my $n = write_header($h);
my $charoff = 6 + tell $fo;
print "CHARS XXXXX";

my ($c2, $d2) = read_char($f2);
while (1)
{
	my ($c1, $d1) = read_char($f1);
	while ($c2 < $c1)
	{
		$n ++;
		write_char($d2);
		($c2, $d2) = read_char($f2);
	}
	last unless defined $d1;
	($c2, $d2) = read_char($f2) if $c2 == $c1;
	write_char($d1);
}

print 'ENDFONT';
seek $fo, $charoff, 0;
printf "%05d", $n;
