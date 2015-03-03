#! /usr/bin/perl 
#
# It does two things:
# a) Prepare a dictionary from the given transcription files
# b) Convert the phonemes in dictionary from METUBET to WORLDBET.
# 
# The dictionary is printed the form: <word>   <phn1> <phn2> ... <phnN>
#
# For a), the syntax is:
# metuworld.pl D <i/p: transcription directory> <o/p: dictionary 1 in METUBET format> \n
# For b), the syntax is:
# metuworld.pl T <i/p: dictionary 1 in METUBET format> <i/p: METU to WORLDBET map file> <o/p: dictionary 2 in WORLDBET format> \n
#  
#
# ============================================================================
# Revision History
# Date 				Author 					Description of Change
# 10/21/13			AD 						Created 
#
# USAGE:
# perl metudict2world.pl D trans_dir lexicon_metu.txt 
# perl metudict2world.pl T lexicon_metu.txt metu2worldmap.txt lexicon_world.txt
# 
# ============================================================================

########################################################
# Section 0: GLOBAL VARIALBES AND PARAMETERS
use File::Path;     
#require "config.pl"; 


#$TRANSTREE = $TRANSTREE_TURKISH; 
#$dictfile1 = #"$DICTDIR/TURKISHDICT_METUBET.txt";
#$dictfile2 = #"$DICTDIR/TURKISHDICT_WORLDBET.txt";
# $dictxformfile = "local/metu2worldmap.txt"; 
$WORDEXT  = "wrd";
$PHNEXT   = "phn";
$searchWordExt = qr/\.$WORDEXT$/i;

my %cmdline;
my %WORDLIST;
my %PHONEMELIST;

#####################################################################
# Section 1: PERL SUBROUTINES

# peruse_tree: a recursive subroutine to search the data tree
# Takes two arguments.  The first argument is the path to the sound 
# files.  The second argument is the extension of the file type you are
# searching for.
# Used in section(s): 2
sub peruse_tree {
    my(@rval)=();	
    # If $_[0] is a directory, open it and recurse
    if ( -d $_[0] ) {
        opendir(TOPDIR, $_[0]) || die "Can't opendir $_[0]: $!";
        foreach $filename (readdir(TOPDIR)) {
            # If $filename doesn't end in period, append recursion to @rval			
            unless( $filename =~ /\.$/ ) { push(@rval, peruse_tree("$_[0]/$filename", $_[1])); }
        }
        closedir(TOPDIR);
    }
    # Otherwise: if $_[0] matches the pattern, return it
    elsif ( $_[0] =~ $_[1] )  { @rval = ( $_[0] ); }
	#else {print "error: Directory $_[0] does not exist!!!!! \n";}
    return(@rval);
}   # END of function definition peruse_tree

sub extract_phonemes_in_segment {
	my($ref, $t1, $t2) = @_;
	my $start = 0;
	my(@phonemes) = ();
	while ($line = <$ref>) {
		my(@recs) = split(/\s+/,$line);
		
		if ($recs[0] == $t1) { 
			$start = 1; 
			# push @phonemes, $recs[2]; 
		}		
		if ($start == 1) {
			push @phonemes, $recs[2]; 
		}	
		if ($recs[1] == $t2) { 
			$start = 0; 
			#if ($recs[0] != $t1) { push @phonemes, $recs[2];}
			last;
		}	
	}
	return(@phonemes);
}

#####################################################################
# Section 2: Process and save the command line input

$USAGE = "USAGE: To be run in the following order: \
metuworld.pl D <i/p: transcription directory> <o/p: dictionary 1 in METUBET format> \n
metuworld.pl T <i/p: dictionary 1 in METUBET format> <i/p: METU to WORLDBET map file> <o/p: dictionary 2 in WORLDBET format> \n
\n"; 

# Check correct number of command-line args
#$num_args = $#ARGV + 1;
#if ($num_args != 3) {
#    print "$USAGE\n";
#    exit;
#}
#else {	
    print "script to do list:\n";
    $item = 0;
    #check the command line arguments and confim what train.pl will do
    if ($ARGV[0] =~ /D/) { 
        $item = $item + 1;
        $cmdline{"D"} = "";     
        shift;  
        ($TRANSTREE, $dictfile1) = @ARGV; 
        #print "TREE=$TRANSTREE\n,DICT=$dictfile1\n";
        print "$item. Create dictionary from the METUBET transcription files\n";
    }
    if ($ARGV[0] =~ /T/)  {
        $item = $item + 1;
        $cmdline{"T"} = "";
        shift;
        ($dictfile1, $dictxformfile, $dictfile2) = @ARGV; 
        print "$item. Transform dictionary from METUBET to WORLDBET\n";        
    }		
    
#}
#####################################################################
# Section 3: Create a dictionary by pooling all the words from the 
# word transcription files provided in the corpus. For each word,
# look up its corresponding phoneme level transcription from phoneme 
# transcription files. Print word and its phoneme expansion to the 
# dictionary

if (exists $cmdline{"D"}) {
#print "Looking for source files in $TRANSTREE\n";
#@PHNFILE_LIST = peruse_tree($TRANSTREE, $searchAudExt);
#print "Found $#AUDIOFILE_LIST source files\n";

print "Looking for source files in $TRANSTREE\n";
@WORDFILE_LIST = peruse_tree($TRANSTREE, $searchWordExt);
print "Found $#WORDFILE_LIST source files\n";
print "Preparing Dictionary ...\n";

mkdir "$DICTDIR" unless -d  "$DICTDIR";
open(DCT, ">$dictfile1")   || die "Unable to write to $dictfile1: $!";
foreach $n (0..$#WORDFILE_LIST) {

	$wordfile = $WORDFILE_LIST[$n];
	$phnfile = $wordfile;
	$phnfile =~ s/(.*\/)?(.*)\.[^.]*/$1$2\.$PHNEXT/g;
	#print "$n : $wordfile \n";
	#print "$n : $phnfile \n\n";
	
	open(WRD, "<$wordfile") || die "Unable to read from $wordfile: $!";
	open(PHN, "<$phnfile")  || die "Unable to read from $phnfile: $!";	
	
	while ($line = <WRD>) {
		my(@recs) = split(/\s+/,$line);
		#if ($recs[2] !~ /^SIL$/) {
			$t1 = $recs[0];	$t2 = $recs[1];
			my(@phonemes) = extract_phonemes_in_segment(\*PHN, $t1, $t2);			
			if ($WORDLIST{$recs[2]} != 1) {
				$WORDLIST{$recs[2]} = 1;
				print DCT "$recs[2] @phonemes[0..$#phonemes]\n";	
				
				# Add the phonemes to the phonemes list
				foreach $k (0..$#phonemes) {
					if ($PHONEMELIST{$phonemes[k]} != 1) { $PHONEMELIST{$phonemes[k]} = 1; }				
				}
			}
			else { #print "$recs[2] ALREADY EXISTS!!!!!! \n";				
			}				
		#}
	}
	
}

close(WRD);
close(PHN);
close(DCT);


#system("mv $dictfile1 $DICTDIR");
print "Dictionary is ready: $dictfile1\n\n\n";

# Uncomment lines below if you want the # of distinct phonemes
#my ($nphonemes) = scalar keys %PHONEMELIST;
#print "Number of phonemes = $nphonemes \n";
#print "$_\n" for sort keys %PHONEMELIST;
}

#####################################################################
# Section 4: Transform dictionary from METU to WORLDBET using
# the mapping file

if (exists $cmdline{"T"}) {
	# Read the xform file to populate the transform	in a hash
    open(XFORM,"<$dictxformfile") || die "Unable to read from $dictxformfile: $!";
    foreach $line (<XFORM>) {
        ($line =~ /^\;/) && next;	
		my(@recs) = split(/\s+/,$line);
		#print "line-> $recs[0..$#recs]\n";
		if (!defined $TRANSFORM{$recs[0]}) {
			$TRANSFORM{$recs[0]} = $recs[1];
		}					
	}
	close(XFORM);
	print "$_ $TRANSFORM{$_}\n" for sort keys %TRANSFORM;
	
	# Read phonemes from dictionary 1, apply xform, and write the xformed phonemes to
	# dictionary 2
	open(DCT1, "<$dictfile1")   || die "Unable to read from $dictfile1: $!";
	open(DCT2, ">$dictfile2")   || die "Unable to write to $dictfile2: $!";
	while ($line = <DCT1>) {
		($line =~ /^\s+$/) && next;	
		my(@recs) = split(/\s+/,$line);
		@xphonemes = map { exists $TRANSFORM{$_} ? $TRANSFORM{$_} : () } @recs[1..$#recs];		
		print DCT2 "$recs[0] @xphonemes[0..$#xphonemes]\n";				
	}
	# Finally, print SIL in dictionary as we want to model the intermediate
	# SIL regions by an HMM
	# print DCT2 "SIL  sil\n";
	close(DCT1);
	close(DCT2);
	print "Dictionary is ready: $dictfile2\n\n\n";

}


