#! /usr/bin/perl 
#
# Convert the mapped phones from symbols to int
# "Mapped phones" means phones in one language are mapped to another language 
# perl utils/l1tol2phonemap_to_int.pl [-col n] <l2 to l1 phone map file> <l2 phones.txt> <l1 phones.txt>
# 
# ============================================================================
# Revision History
# Date 				Author 					Description of Change
# 11/27/14			AD 						Created 
#
# ============================================================================

my $usage = "Usage:\n>perl $0 [-col n] <l2 to l1 phone map file> <l2 phones.txt> <l1 phones.txt>\n
Converts the mapped phones from symbols to int. In the phone map file,\n
phones from l2 are in column 1, and phones from l1 are in column 2\n 
(or a higher numbered column if you want a different mapping).\n 
The [-col n] option determines which column is used for the l1 phones. Default column is 2.\n

>perl $0 -col 2 utils/phonemap/timit2turkishmap.txt timit/s5/data/lang/phones.txt turkish/s5/data/lang/phones.txt\n";

#use strict;
use Getopt::Long;
die "$usage" unless(@ARGV >= 3);
my $col_to_map = 2; # column 1 is the phone set in L1, column 2 is the phone set in L2.
GetOptions ("col=i" => \$col_to_map); 	    
	    
# Transform transcripts in METU to WORLDBET 
my ($mapfile, $l2phonefile, $l1phonefile) = @ARGV;

die "column should be greater than or equal to 2\n" unless ($col_to_map >= 2);

my %L1SYM2INT = ();
my %L2SYM2INT = ();

#print "$col_to_map, $mapfile, $l1phonefile, $l2phonefile\n";


# Read L1 phone file
# aa 1
# ax 2 ... 
open(L1PHF,"<$l1phonefile") || die "Unable to read from $l1phonefile: $!";
foreach $line (<L1PHF>) {
	($line =~ /^\;/) && next;	
	my(@recs) = split(/\s+/,$line);
	#print "line-> $recs[0..$#recs]\n";
	if (!defined $L1SYM2INT{$recs[0]}) {
		$L1SYM2INT{$recs[0]} = $recs[1];		
	}
}
close(L1PHF);

# Read L2 phone file
# ae 1
# axr 2 ... 
open(L2PHF,"<$l2phonefile") || die "Unable to read from $l2phonefile: $!";
foreach $line (<L2PHF>) {
	($line =~ /^\;/) && next;	
	my(@recs) = split(/\s+/,$line);
	#print "line-> $recs[0..$#recs]\n";
	if (!defined $L2SYM2INT{$recs[0]}) {
		$L2SYM2INT{$recs[0]} = $recs[1];		
	}
}
close(L2PHF);

# Read the cols in map file (which are the keys to the hash tables %L1SYM2INT, %L2SYM2INT)
# ae ax
# axr aa
# Expected output:
# 1 2
# 2 1
open(XFORM,"<$mapfile") || die "Unable to read from $dictxformfile: $!";
foreach $line (<XFORM>) {
	($line =~ /^\;/) && next;	
	my(@recs) = split(/\s+/,$line);
	my $l2phone = $recs[0];
	my $l1phone = $recs[$col_to_map - 1];
	#print "line-> $recs[0..$#recs]\n";
	if (defined $L2SYM2INT{$recs[0]} && defined $L1SYM2INT{$recs[$col_to_map - 1]}) {
		#print "$l2phone ($L2SYM2INT{$l2phone})    $l1phone ($L1SYM2INT{$l1phone}) \n" # prints both the phone syms and ints
		print "$L2SYM2INT{$l2phone}    $L1SYM2INT{$l1phone} \n"
	}
	else {
		die "Either \"$l1phone\" is not a part of $l1phonefile or \"$l2phone\" is not a part of  $l2phonefile\n";
	}
}
close(XFORM);
#print "$_ -> $TRANSFORM{$_}\n" for sort keys %TRANSFORM;
