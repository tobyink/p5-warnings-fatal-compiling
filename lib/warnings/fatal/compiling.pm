use 5.008003;
use strict;
use warnings;

package warnings::fatal::compiling;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.001';

use B::Hooks::EndOfScope;

BEGIN { *_VERY_OLD = ($] < 5.010) ? sub{!!1} : sub{!!0} };

sub import
{
	goto _import_perl58 if _VERY_OLD;
	
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
	goto _unimport_perl58 if _VERY_OLD;
	
	$^H{+__PACKAGE__} = 0;
}

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

1;

__END__

=pod

=encoding utf-8

=head1 NAME

warnings::fatal::compiling - make warnings FATAL at compile-time only

=head1 SYNOPSIS

   use strict;
   use warnings;
   use warnings::fatal::compiling;
   
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

This pragma is lexically scoped.

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=warnings-fatal-compiling>.

=head1 SEE ALSO

L<warnings>.

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

