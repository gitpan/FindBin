
use FindBin qw($Bin);
use lib $Bin;

print "1..1\n";

if($INC[0] eq $Bin) {
 print "ok 1\n";
}
else {
 print "not ok 1\n";
}
