use 5.008003;
use strict;
use warnings;

package warnings::MaybeFatal;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.001';

use B::Hooks::EndOfScope;

BEGIN { *_VERY_OLD = ($] < 5.010) ? sub{!!1} : sub{!!0} };

sub import
{
	goto \&_import_perl58 if _VERY_OLD;
	
	$^H{+__PACKAGE__} = 1;
	
	# Keep original signal handler
	my $orig = $SIG{__WARN__};
	
	$SIG{__WARN__} = sub {
		my $hints = (caller(0))[10];
		$hints->{+__PACKAGE__} ? die("@_") : $orig ? $orig->(@_) : warn(@_);
	};
	
	on_scope_end {
		$SIG{__WARN__} = $orig;
	};
}

sub unimport
{
	goto \&_unimport_perl58 if _VERY_OLD;
	
	$^H{+__PACKAGE__} = 0;
}

eval(<<'END_PERL_58') if _VERY_OLD;

sub _import_perl58
{
	require Devel::Pragma;
	
	my $hints = Devel::Pragma::my_hints();
	$hints->{+__PACKAGE__} = 1;
	
	# Keep original signal handler
	my $orig = $SIG{__WARN__};
	
	$SIG{__WARN__} = sub {
		my $hints = Devel::Pragma::my_hints();
		$hints->{+__PACKAGE__} ? die("@_") : $orig ? $orig->(@_) : warn(@_);
	};
	
	on_scope_end {
		$SIG{__WARN__} = $orig;
	};
}

sub _unimport_perl58
{
	require Devel::Pragma;
	
	Devel::Pragma::my_hints()->{+__PACKAGE__} = 0;
}

END_PERL_58

1;

__END__

=pod

=encoding utf-8

=head1 NAME

warnings::MaybeFatal - make warnings FATAL at compile-time only

=head1 SYNOPSIS

   use strict;
   use warnings qw(all);
   use warnings::MaybeFatal;
   
   # Use of uninitialized value.
   # Run-time warning, so this is non-fatal.
   print join(undef, "a", "b");
   
   # Useless use of constant in void context.
   # Compile-time warning, so this is fatalized.
   "Hello world"; 1;

=head1 DESCRIPTION

Because it's kind of annoying if a warning stops your program from
being compiled, but it's I<really> annoying if it breaks your program
part way through actually executing.

This lexically scoped pragma will make all warnings (including custom
warnings emitted with the C<warn> keyword) FATAL during compile time.
It does not enable or disable any warnings in its own right. It just
makes any warnings that happen to be enabled FATAL during the compile.

(Note that the compile phase an execute phase are not as cleanly
divided in Perl as they are in, say, C. If module X loads module Y at
run-time, then module Y's compile time happens during module X's
run-time. In this situation, a warning that is triggered while
compiling Y will be FATAL, even though from module X's perspective,
this is at run-time.)

This module should run pretty cleanly on Perl 5.10 and above. It will
work on Perl 5.8.3 and above if L<Devel::Pragma> is installed. However,
current versions of Devel::Pragma are broken on Perl older than 5.12,
so you will need to find and install an old version of Devel::Pragma.
I'd recommend version 0.54.

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=warnings-MaybeFatal>.

=head1 SEE ALSO

L<warnings>.

L<http://cpan.metacpan.org/authors/id/C/CH/CHOCOLATE/Devel-Pragma-0.54.tar.gz>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2014 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

