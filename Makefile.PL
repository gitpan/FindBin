# This -*- perl -*- script makes the Makefile
# $Id: Makefile.PL,v 1.3 1996/01/16 17:21:54 gbarr Exp $

use ExtUtils::MakeMaker;
use ExtUtils::Manifest qw(maniread);
use lib qw(. ./lib);

#--- Configuration section ---

#--- End User Configuration - You should not have to change anything below this line

require 5.001;
use Getopt::Std;

require 5.001;

$NAME     = 'FindBin';

$lib_only = 1;

#--- End Configuration
#--- MY package
{
 package MY;

 sub libscan {
  return '' if m,/(RCS|CVS)/, || m,[~%]$, || m,\.(orig|rej)$,;
  $_;
 }
}
#--- End MY package

sub initialize {
 local($_);

 my $manifest = maniread();

 my %PL_FILES = ();
 my %EXE_FILES = ();
 my %macro = ();

 foreach (keys %$manifest) {
  $PL_FILES{$_} = $1 if(/(.*)\.PL\Z/ && !/^Makefile.PL$/);

  if(m#\bbin/# && !m#demo#) {
   my $f = $_;

   $f =~ s#\.PL$##;

   if(defined $install_pgm{$f} && $install_pgm{$f}) {
    $EXE_FILES{$f} = 1 if(-x $f || -f "$f.PL");
   }
  }
 }

 %EXE_FILES = () if($lib_only);

 unless(defined $VERSION) {
  my($pm,$rcs);

  ($pm = $NAME . ".pm") =~ s,::,/,g;
  $pm = "lib/" . $pm unless(-f $pm);

  $VERSION  =  eval { require "./$pm"; ${"${NAME}::VERSION"} } || "0.00";
  
  ($rcs = $pm) =~ s:([^/]+\.pm):RCS/$1,v:;

  # update VERSION when checked in
  $macro{CONFIGDEP} = $rcs
    if(-f $rcs);
 }

 $VERSION .= $RELTYPE if(defined $RELTYPE);

 my $hash = {
	VERSION   => $VERSION,
	NAME      => $NAME,
	SKIP      => [qw(static dynamic linkext)],
	PL_FILES  => \%PL_FILES,
	EXE_FILES => [ keys %EXE_FILES ],
	LINKTYPE  => 'dynamic',

	'dist'    => {COMPRESS => 'gzip -9f',
		      SUFFIX   => 'gz', 
		      POSTOP   => 'mv $(DISTNAME)-$(VERSION).tar.gz ../',
		      DIST_DEFAULT => 'all tardist',
		      CI => 'ci -l'
		     },

	'clean'   => {FILES => join(" ", qw(*% *.html *.bak *.old lib/*% lib/*/*%),values %PL_FILES)},
 };

 $hash->{macro} = \%macro if(%macro);
 $hash->{DISTNAME} = $DISTNAME if(defined $DISTNAME);
 $hash;
}

# -- Make the Makefile

getopts("l") or
 die "Usage: $0 [-l]\n";

$lib_only = 1 
  if(defined $opt_l && $opt_l);

my $hash = initialize();
WriteMakefile( %$hash ) ;


