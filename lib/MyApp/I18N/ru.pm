use strict;
use warnings;

package MyApp::I18N::ru;
use base 'MyApp::I18N';

sub num_params {
    return
        (shift)->SUPER::num_params(@_),
        -decimal_point => ',',
    ;
}

sub pick_quant_form {
    my ($self, $n) = @_;

    my $form = 0;
    unless ( $n ) {
        $form = 3;
    } elsif ( $n%10 == 1 && $n%100 != 11 ) {
        $form = 0;
    } elsif ( $n%10 >= 2 && $n%10 <= 4 && ($n%100 < 10 || $n%100 >= 20) ) {
        $form = 1;
    } else {
        $form = 2;
    }
    return $form;
}

1;
