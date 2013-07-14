use strict;
use warnings;
my @key_fields = qw(CELL CHGR);
my $test;
unless (@ARGV) {
    @ARGV = 't/freqassign.log';
    $test = 't/freqoutput.txt';
}

sub read_fields(\@\@) { # returns name of fields and their position
	my ($fields,$offsets) = @_;
    s/\t/        /g; # replace tab with 8 characters
	@$fields = m{(\w+)}g;
	# calculating the positions of fields 
	# to extract correctly values in next line
	my $re = join " +",map "($_)",@$fields;
	m{$re}; 
	@$offsets = @-;
	shift(@$offsets); # @_ starts from 1-st, we don't need it
}

# this is HEADER fields of output
local $_='CELL    CHGR   SCTYPE    SDCCH   SDCCHAC   TN       CBCH       HSN   HOP  DCHNO';
print "$_\n"; 

# use read_fields to create output format for data records
read_fields(my @out_fields,my @out_offsets);
# make string like
# %20s%30s%8s for padding output data
my $out_format = join "", map("%-${_}s", map $out_offsets[$_+1]-$out_offsets[$_],0..$#out_offsets-1), "%s";

# this will be used to differ HEADERS line from VALUES line
my $any_field = "(" . join("|", @out_fields) . ")";

my (%record); # accumulate data until is flushed
sub flush {
    printf "$out_format\n", map $_?join(",",@$_):"",@record{@out_fields};
    debug('record:%s',\%record);
    %record = (CELL => $record{CELL});
}
sub add_values {
    my ($fields,$values) = @_;
    my %field_value;
    for my $i (0..$#$fields) {        
        my $field = $fields->[$i];
        my $value = $values->[$i];
        if (length($value)) {
            $field_value{$field} = $value;
        }
    }
    # flush accummulated record if any key field is changed
    flush if (grep exists($field_value{$_}) && $record{$_}, @key_fields);
    push @{$record{$_}}, $field_value{$_} for keys %field_value;
    $record{$_} = [$field_value{$_}] for grep exists $field_value{$_}, @key_fields;
}


sub read_values {
	my @offsets = @_;
    s/\t/    /g; # replace tabs with 4 spaces
	# trim @match_start to actual length of $values
	$#offsets-- while $offsets[-1] > length($_);
	# and push virtual end position for next
	push @offsets,length($_)+1;
    my $values = $_;
	my @values = map substr($values,$offsets[$_],$offsets[$_+1]-$offsets[$_]), 0..$#offsets-1;
    s/^\s+// for @values;
    s/\s+$// for @values;
	# return left & right trimmed values
	return \@values;
}

my (@fields, @offsets);

my $n = 0;
while (<>) {
    $n++;
    # right trim and add single definite space to the end of line
    s/\s*$/ /;
	last if m{^END };
    if (m{^$any_field\s}) {
        read_fields(@fields,@offsets);
    }
    else {
        next unless @fields; # skip lines at begin of input file until fields are met
        $DB::single = 2 if $. == 116;
        add_values(\@fields,read_values(@offsets));
	}
}
flush;

use Data::Dump qw(dump);
use Time::HiRes qw(time);
my $lt = time;
sub debug {
    $lt=time unless defined($lt);
	my ($format,@par) = @_;
	my ($package, $filename, $line) = caller;
	printf STDERR "%s[%5d](%d) $format\n",$filename,(time-$lt)*1000,$line,map {defined($_)?(ref($_)?dump($_):$_):'undef'} @par;
    $lt=time;
}

=pod
Hi Mohhamed.

I have implemented the scanner for your input file.
But it was harder than "easy" because of next reasons:

1) your input file contains some mistakes.
They are wrong indentation.
Also there were tabs somewhere instead of spaces.
It looks like input file was edited by human,
not produced by some software.
Fixed input is in t/freqassign.log file,
please compare it with your file 

2) your output sample contains errors. 
Compare it with output produced by script and please 
look at your input data to make sure I am right
with this output


Good luck!
=cut