package ThisShouldDieToo;

use strict;
use warnings;
use warnings::fatal::compiling;

{
	no warnings::fatal::compiling;
	sub yyy { 1 };
	sub yyy { 2 };
}

sub xxx { 1 };
sub xxx { 2 };

1;