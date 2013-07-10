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
while (<DATA>) {
	chomp;
	next unless m{^[A-Z]};
	last if m{^END\s*$};
	if (m{^(CELL|CELLR)}) {
		flush;
	} else {
		# skip while there is no CELL data
		next unless $cellr{CELL}; 
	}
	my @fields = m{(\w+)}g;
	# calculating the positions of fields 
	# to extract correctly values in next line
	my $re = join " +",map "($_)",@fields;
	m{$re}; 
	my @match_start = @-;
	shift(@match_start); # it starts from 1-th
	my $values = <DATA>;
	$values =~ s{\s+$}{}; # trim EOL spaces etc.
	# trim @match_start to actual length of $values
	$#match_start-- while $match_start[-1] > length($values);
	# and push virtual end position for next
	push @match_start,length($values)+1;
	my @values = map substr($values,$match_start[$_],$match_start[$_+1]-$match_start[$_]), 0..$#match_start-1;
	# save left & right trimmed values
	@cellr{@fields} = map m{^\s*(.*?)\s*$},@values;
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