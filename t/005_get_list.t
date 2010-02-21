# -*- perl -*-

# t/005_get_list.t

use CPAN::Mini::Visit::Simple;
use Test::More tests =>  6;

my ( $self, @input_list, @output_list, $output_list, $output_ref );

$self = CPAN::Mini::Visit::Simple->new({});
isa_ok ($self, 'CPAN::Mini::Visit::Simple');

@input_list = qw(
    /home/user/minicpan/authors/id/A/AA/AARDVARK/Alpha-Beta-0.01-tar.gz
    /home/user/minicpan/authors/id/A/AA/AARDVARK/Gamma-Delta-0.02-tar.gz
    /home/user/minicpan/authors/id/A/AA/AARDVARK/Epsilon-Zeta-0.03-tar.gz
);
$self->identify_distros( { list => \@input_list } );

@output_list = $self->get_list();
is_deeply(
    { map { $_ => 1 } @output_list },
    { map { $_ => 1 } @input_list },
    "List context: contents of output set match input set"
);

$output_list = $self->get_list();
is( $output_list, scalar(@input_list),
    "Scalar context: got expected number of items in list" );

$output_ref = $self->get_list_ref();
is_deeply(
    { map { $_ => 1 } @{$output_ref} },
    { map { $_ => 1 } @input_list },
    "Contents of output set match input set"
);

$self = CPAN::Mini::Visit::Simple->new({});
is( $self->get_list(),
    undef,
    "List not yet determined, so 'get_list()' returned undefined value"
);

$self = CPAN::Mini::Visit::Simple->new({});
is( $self->get_list_ref(),
    undef,
    "List not yet determined, so 'get_list_ref()' returned undefined value"
);

