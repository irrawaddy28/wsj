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

my $usage = "\nUsage:\nperl $0 [-col-l1ph-l1f n] [-col-l1ph-mapf m1] [-col_l2ph_mapf m2] <l1 phone file> <l2 to l1 phone map file>
Prints a table of mappings of L1 phones to L2 phones.

Example:
perl $0  metu2worldmap.txt  timit2turkishmap.txt\n\n";

use Getopt::Long;
die "$usage" unless(@ARGV >= 2);

my $col_l1ph_l1f = 2; # column index of L1 phones in L1 phone file
my $col_l1ph_mapf = 2; # column index of L1 phones in map file
my $col_l2ph_mapf = 1; # column index of L2 phones in map file
GetOptions ("col-l1ph-l1f=i" => \$col_l1ph_l1f, "col-l1ph-mapf=i" => \$col_l1ph_mapf, "col_l2ph_mapf=i" => \$col_l2ph_mapf);
	    
# Transform transcripts in METU to WORLDBET 
my ($l1phonef, $l2l1mapf) = @ARGV;

my %L1SYM = ();
my %L2L1SYM = ();

# Read the L1 phone file and create hash table L1SYM with each key 
# set to an L1 phone and value set to an empty string
# a => ""
# A => ""
# b => ""
# J => " "
# dZ => ""
$col_l1ph_l1f--;
open(L1PHF,"<$l1phonef") || die "Unable to read from $l1phonef: $!";
foreach $line (<L1PHF>) {
	($line =~ /^\;/) && next;	
	my(@recs) = split(/\s+/,$line);
	#print "line-> $recs[$col_l1ph_l1f]\n";
	if (!defined $L1SYM{$recs[$col_l1ph_l1f]}) {
		$L1SYM{$recs[$col_l1ph_l1f]} = "";		
	}
}
close(L1PHF);
#print "$_\n" for sort keys %L1SYM;

# Read the map file which looks like:
# L2 L1
# A	 A	
# @	 a	
# >	 A
# b  b
# aI a
# Λ  A
# dZ dZ
#
# Now create hash table L2L1SYM with the each key set to 
# an L1 phone and value set to an array L2 phones that was present in the map file.
# a => @, aI
# A => A, >, Λ
# b => b
# dZ => dZ
#
# Note: No "J" in the hash table since J was not mapped to any L2 phone in the map file
$col_l1ph_mapf--;
$col_l2ph_mapf--;
open(L2L1MAPF,"<$l2l1mapf") || die "Unable to read from $l2l1mapf: $!";
foreach $line (<L2L1MAPF>) {
	($line =~ /^\;/) && next;	
	my(@recs) = split(/\s+/,$line);
	#print "line-> $recs[$col_l1ph_mapf] :: $recs[$col_l2ph_mapf]\n";
	push ( @{ $L2L1SYM{$recs[$col_l1ph_mapf]} }, $recs[$col_l2ph_mapf] );	
}
close(L2L1MAPF);
#for my $k ( sort keys %L2L1SYM ) {
#	print "$k => ", join(', ', @{$L2L1SYM{$k}}),"\n";	
#}

# Now copy the key-value pairs from L2L1SYM to L1SYM. 
# After copy, phones in L1 which had no map to L2 will have empty values. 
@L1SYM{ keys %L2L1SYM } = @L2L1SYM{ keys %L2L1SYM };

# Print the map hash table. 
# Each key is an L1 phone. Each value is an array of L2 phones that were 
# mapped to the L1 phone.
# a => @, aI  (2)
# A => A, >, Λ (3)
# b => b  (1)
# J =>    (0)
# dZ => dZ  (1)
print "\nL1 phone => array of L2 phones  (size of array)\n";
print "===============================================\n";
for my $k ( sort keys %L1SYM ) {
	print "$k => ", join(', ', @{$L1SYM{$k}}), "\t( ", scalar @{$L1SYM{$k}}," )","\n";	
}


