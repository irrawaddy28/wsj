#! /usr/bin/perl 
#
# Print a phone mapping table from source (or L2) to target (or L1) phones
# perl utils/l2l1phonemap.pl [-col n] <phone map file> 
# 
# ============================================================================
# Revision History
# Date 				Author 					Description of Change
# 11/27/14			AD 						Created 
#
# ============================================================================

my $usage = "\nUsage:\n>perl $0 [-col n] <l2 to l1 phone map file>\n
Generate a phone mapping table from source (or L2) to target (or L1) phones. In the phone map file,
phones from l2 are in column 1, and phones from l1 are in column 2
(or a higher numbered column if you want to use a different column).
The [-col n] option determines which column is used for the l1 phones. Default column is 2.

The phone map file should be in this format:
===========
; comment line begins with a semi-colon
; comment line begins with a semi-colon
; comment line begins with a semi-colon
; Col1 Col2 Col3
a  a1 a2
b  b1 b2
c  c1 c2
==========

>perl $0 -col 3 map.txt
Expected Output:
a a2
a b2
c c2
\n";

#use strict;
use Getopt::Long;
use Encode qw(encode decode);

die "$usage" unless(@ARGV == 1);
my $col_to_map = 2; # $col_to_map is the column number of source (or L1) phones
GetOptions ("col=i" => \$col_to_map); 	    
	    

my $mapfile = $ARGV[0];

die "column should be greater than or equal to 2\n" unless ($col_to_map >= 2);

# Read the phones in map file 
# ae ax
# axr aa
#
# Expected output:
# ae = ax ; axr = aa ;

my $str = "";
open(XFORM,"<$mapfile") || die "Unable to read from $mapfile: $!";
foreach $line (<XFORM>) {
	($line =~ /^\;/) && next;	
	my(@recs) = split(/\s+/,$line);	
	my $l2phone = $recs[0];
	my $l1phone = $recs[$col_to_map - 1];
	$str .= "$l2phone\t$l1phone\n";	
}
close(XFORM);
#print "$_ -> $TRANSFORM{$_}\n" for sort keys %TRANSFORM;
print "$str";
