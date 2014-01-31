if ( $] < 5.010 )
{
	warn <<'WARNING'
**
** You're going to need Devel::Pragma. Unfortunately, the latest release
** of Devel::Pragma only works on Perl 5.12 and above. You need to get a
** really old version from BackPAN.
**
** http://cpan.metacpan.org/authors/id/C/CH/CHOCOLATE/Devel-Pragma-0.54.tar.gz
**
WARNING

	$meta->{prereqs}{runtime}{requires}{'Devel::Pragma'} = '0.54';
}
