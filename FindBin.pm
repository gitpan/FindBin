# FindBin.pm
#
# Copyright (c) 1995 Graham Barr & Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

=head1 NAME

FindBin - Locate directory of original perl script

=head1 SYNOPSIS

 use FindBin;
 BEGIN { unshift(@INC,"$FindBin::Bin/../lib") }

 or 

 use FindBin qw($Bin);
 BEGIN { unshift(@INC,"$Bin/../lib") }

=head1 DESCRIPTION

Locates the full path to the script bin directory to allow the use
of paths relative to the bin directory.

This allows a user to setup a directory tree for some software with
directories <root>/bin and <root>/lib and then the above example will allow
the use of modules in the lib directory without knowing where the software
tree is installed

=head1 EXPORTABLE VARIABLES

 $Bin         - path to bin directory from where script was invoked
 $Script      - name os script from which perl was invoked
 $RealBin     - $Bin with all links resolved
 $RealScript  - $Script with all links resolved

=head1 AUTHORS

Graham Barr <bodg@tiuk.ti.com>
Nick Ing-Simmons <nik@tiuk.ti.com>

=head1 COPYRIGHT

Copyright (c) 1995 Graham Barr & Nick Ing-Simmons. All rights reserved.
This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 REVISION HISTORY

# $Log: FindBin.pm,v $
# Revision 1.1  1995/11/14  11:00:09  gbarr
# Initial revision
#

=cut

package FindBin;
use Carp;
require 5.000;
require Exporter;

@EXPORT_OK = qw($Bin $Script $RealBin $RealScript);
@ISA = qw(Exporter);

$VERSION = sprintf("%d.%02d", q$Revision: 1.1 $ =~ /(\d+)\.(\d+)/);

sub Version { $VERSION }

sub import
{
# Call the exporter package to do it's stuff
 my $pkg = shift;
 my($callpkg) = caller(0);

 $pkg->export($callpkg, @_);

# Determine the paths

 $Bin        = undef;
 $Script     = undef;
 $RealBin    = undef;
 $RealScript = undef;

 my $script = $0;

 unless (-x $script)
  {
   local $dir;
   foreach $dir (split(/:/,$ENV{PATH}))
    {
     if (-x "$dir/$script")
      {
       $script = "$dir/$script";
       last;
      }
    }
  }

 croak("Cannot find executable $0") unless (-x $script);

 $script =~ s,^\./,,;

 unless( "/" eq substr($script,0,1))
  {
   require Cwd;
   $script = Cwd::getcwd() . "/" . $script;
  }

 ($Bin,$Script) = $script =~ m,^(.*)/([^/]+)$,;

 while(1)
  {
   my $linktext = readlink($script);

   ($RealBin,$RealScript) = $script =~ m,^(.*)/([^/]+)$,;
   last unless defined $linktext;

   $script = ("/" eq substr($linktext,0,1))
              ? $linktext
              : $RealBin . "/" . $linktext;
  }
}

1; # Keep require happy

