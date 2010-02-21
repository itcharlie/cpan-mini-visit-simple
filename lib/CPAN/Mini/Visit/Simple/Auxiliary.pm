package CPAN::Mini::Visit::Simple::Auxiliary;
use 5.010;
use strict;
use warnings;
our @ISA       = qw( Exporter );
our @EXPORT_OK = qw(
    dedupe_superseded
    normalize_version_number
);
use File::Basename;
use File::Spec;

sub dedupe_superseded {
    my $listref = shift;
    my (%version_seen, @newlist);
    foreach my $distro (@$listref) {
        my $dir   = dirname($distro);
        my $base  = basename($distro);
        my $archive_re = qr{\.(?:tar\.(?:bz2|gz|Z)|t(?:gz|bz)|zip\.gz)$}i;
        if ($base =~ m/^(.*)-([\d\.]+)(?:$archive_re)/) {
            my ($stem, $version) = ($1,$2);
            my $k = File::Spec->catfile($dir, $stem);
            if ( not $version_seen{$k}{version} ) {
                $version_seen{$k} = {
                    distro => $distro,
                    version => normalize_version_number($version),
                };
            }
            else {
                my $norm_current =
                    normalize_version_number($version_seen{$k}{version});
                my $norm_new = normalize_version_number($version);
                if ( $norm_new > $norm_current ) {
                    $version_seen{$k} = {
                        distro => $distro,
                        version => $norm_new,
                    };
                }
            }
        }
        else {
            push @newlist, $distro;
        }
    }
    foreach my $k (keys %version_seen) {
        push @newlist, $version_seen{$k}{distro};
    }
    return [ sort @newlist ];
}

sub normalize_version_number {
    my $v = shift;
    my @captures = split /\./, $v;
    my $normalized = "$captures[0].";
    $normalized =~ s/^0+?(\d+\.)/$1/;
    for my $cap (@captures[1..$#captures]) {
        $normalized .= sprintf("%05d", $cap);
    }
    $normalized =~ s/-//g;
    return $normalized;
}

1;


=head1 NAME

CPAN::Mini::Visit::Simple::Auxiliary - Helper functions for CPAN::Mini::Visit::Simple

=head1 SYNOPSIS

    use CPAN::Mini::Visit::Simple::Auxiliary qw(
        dedupe_superseded
    );

=head1 DESCRIPTION

This package provides subroutines, exported on demand only, which are used in
Perl extension CPAN-Mini-Visit-Simple and its test suite.

=head1 SUBROUTINES

=head2 C<dedupe_superseded()>

=over 4

=item * Purpose

Due to what is probably a bug in CPAN::Mini, a minicpan repository may, under
its F<author/id/> directory, contain two or more versions of a single CPAN
distribution.  Example:

    minicpan/authors/id/D/DR/DROLSKY/Class-MOP-0.82.tar.gz
    minicpan/authors/id/D/DR/DROLSKY/Class-MOP-0.88.tar.gz
    minicpan/authors/id/D/DR/DROLSKY/Class-MOP-0.98.tar.gz

This I<may> be due to an algorithm which searches for the most recent version
of each Perl I<module> on CPAN and then places the I<distribution> in which it
is found in the minicpan -- even if that module is not found in the most
recent version of the distribution.

Be this as it may, if you are using a minicpan, chances are that you really
want only the most recent version of a particular CPAN distribution and that
you don't care about packages found in older versions which have been deleted
by the author/maintainer (presumably for good reason) from the newest
version.

So when you traverse a minicpan to compose a list of distributions, you
probably want that list I<deduplicated> by stripping out older, presumably
superseded versions of distributions.   This function tries to accomplish
that.  It does I<not> try to be omniscient.  In particular, it does not strip
out distributions with letters in their versions.  So, faced with a situation
like this:

    minicpan/authors/id/D/DR/DROLSKY/Class-MOP-0.82.tar.gz
    minicpan/authors/id/D/DR/DROLSKY/Class-MOP-0.88.tar.gz
    minicpan/authors/id/D/DR/DROLSKY/Class-MOP-0.98.tar.gz
    minicpan/authors/id/D/DR/DROLSKY/Class-MOP-0.98b.tar.gz

... it will dedupe this listing to:

    minicpan/authors/id/D/DR/DROLSKY/Class-MOP-0.98.tar.gz
    minicpan/authors/id/D/DR/DROLSKY/Class-MOP-0.98b.tar.gz

=item * Arguments

    $newlist_ref = dedupe_superseded(\@list);

One argument:  Reference to an array holding a list of distributions needing
to be duplicated.

=item * Return Value

Reference to an array holding a deduplicated list.

=back

=head2 C<normalize_version_number()>

=over 4

=item * Purpose

Yet another attempt to deal with version number madness.  No attempt to claim
that this is the absolutely correct way to create comparable version numbers.

=item * Arguments

    $new_version = normalize_version_number($old_version),

One argument:  Version number, hopefully in two or more
decimal-point-delimited parts.

=item * Return Value

A version number in which 'minor version', 'patch version', etc., have been
changed to C<0>-padded 5-digit numbers.

=back

=head1 BUGS

Report bugs at
F<https://rt.cpan.org/Public/Bug/Report.html?Queue=CPAN-Mini-Visit-Simple>.

=head1 AUTHOR

    James E Keenan
    CPAN ID: jkeenan
    Perl Seminar NY
    jkeenan@cpan.org
    http://thenceforward.net/perl/modules/CPAN-Mini-Visit-Simple/

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

CPAN-Mini.  CPAN-Mini-Visit-Simple.

=cut
