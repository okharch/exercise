# this scripts implememts functionality for exercize mentioned on great Perl site
# http://perlmaven.com/reading-multi-line-records#description
# Thank you for exercize, Gabor!
use strict;
use warnings;
$\ = "\n";
my %cellr;
my @fields=qw(CELL CELLR DIR CAND CS KHYST KOFFSETP KOFFSETN LHYST LOFFSETP LOFFSETN TRHYST TROFFSETP TROFFSETN AWOFFSET BQOFFSET HIHYST LOHYST OFFSETP OFFSETN BQOFFSETAFR BQOFFSETAWB);
print join "\t",@fields;
sub flush {
	return unless $cellr{CELLR};
	print join "\t",map $_||"",@cellr{@fields};
	# empty all fields except of CELL
	%cellr = (CELL => $cellr{CELL}); 
}

sub read_fields(\@\@) { # returns name of fields and their position
	my ($fields,$offset) = @_;
	@$fields = m{(\w+)}g;
	# calculating the positions of fields 
	# to extract correctly values in next line
	my $re = join " +",map "($_)",@$fields;
	m{$re}; 
	@$offset = @-;
	shift(@$offset); # @_ starts from 1-st, we don't need it
}

sub read_values {
	my @offset = @_;
 	my $values = <DATA>;
	$values =~ s{\s+$}{}; # trim EOL spaces etc.
	# trim @match_start to actual length of $values
	$#offset-- while $offset[-1] > length($values);
	# and push virtual end position for next
	push @offset,length($values)+1;
	my @values = map substr($values,$offset[$_],$offset[$_+1]-$offset[$_]), 0..$#offset-1;
	# return left & right trimmed values
	return map m{^\s*(.*?)\s*$},@values;
}

while (<DATA>) {
	chomp;
	next unless m{^[A-Z]};
	last if m{^END\s*$};
	read_fields(my @fields,my @offset);
	if (grep m{^(CELL|CELLR)}, @fields) {
		flush;
	} else {
		# skip while there is no CELL data
		next unless $cellr{CELL}; 
	}
	@cellr{@fields} = read_values(@offset);
}
flush;
__END__
<rlnrp:cell=all;
NEIGHBOUR RELATION DATA
 
CELL
G37423
 
CELLR     DIR     CAND   CS
G31761    MUTUAL  BOTH   NO
 
KHYST   KOFFSETP  KOFFSETN   LHYST   LOFFSETP  LOFFSETN
 3       0                    3       0
 
TRHYST  TROFFSETP  TROFFSETN  AWOFFSET  BQOFFSET
 2       0                     5         3
 
HIHYST  LOHYST  OFFSETP  OFFSETN  BQOFFSETAFR  BQOFFSETAWB
 5       3       0                 3           
 
CELLR     DIR     CAND   CS
G37911    MUTUAL  BOTH   NO
 
KHYST   KOFFSETP  KOFFSETN   LHYST   LOFFSETP  LOFFSETN
 3       0                    3       0
 
TRHYST  TROFFSETP  TROFFSETN  AWOFFSET  BQOFFSET
 2       0                     5         3
 
HIHYST  LOHYST  OFFSETP  OFFSETN  BQOFFSETAFR  BQOFFSETAWB
 5       3       0                 3           
 
CELL
G37521
 
CELLR     DIR     CAND   CS
G37422    MUTUAL  BOTH   YES
 
KHYST   KOFFSETP  KOFFSETN   LHYST   LOFFSETP  LOFFSETN
 3       0                    3       0
 
TRHYST  TROFFSETP  TROFFSETN  AWOFFSET  BQOFFSET
 2       0                     5         3
 
HIHYST  LOHYST  OFFSETP  OFFSETN  BQOFFSETAFR  BQOFFSETAWB
 5       3       0                 3           
 
CELLR     DIR     CAND   CS
G37421    MUTUAL  BOTH   YES
 
KHYST   KOFFSETP  KOFFSETN   LHYST   LOFFSETP  LOFFSETN
 3       0                    3       0
 
TRHYST  TROFFSETP  TROFFSETN  AWOFFSET  BQOFFSET
 2       0                     5         3
 
HIHYST  LOHYST  OFFSETP  OFFSETN  BQOFFSETAFR  BQOFFSETAWB
 5       3       0                 3           
 
END