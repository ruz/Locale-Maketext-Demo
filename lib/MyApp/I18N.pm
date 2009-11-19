use strict;
use warnings;

package MyApp::I18N;

# uncomment for debug
#BEGIN { package Locale::Maketext; sub DEBUG() {1} };
#BEGIN { package Locale::Maketext::Guts; sub DEBUG() {1} };

use base qw(Locale::Maketext);
our %Lexicon = (
    _AUTO => 1,
);
use Locale::Maketext::Lexicon {
    _decode => 1,
    '*' => [Gettext => 'share/po/*.po'],
};
sub init {
    my $self = shift;
    require MyApp::I18N::en;
    require MyApp::I18N::ru;
    return $self->SUPER::init(@_);
}




use Number::Format;

sub numf_params {
    return (
        -thousands_sep  => ' ',
        -decimal_point  => '.',
        -decimal_digits => 2,
    );
}

sub numf_formatter {
    my $self = shift;
    return Number::Format->new(
        $self->numf_params, @_
    );
}

sub numf {
    my ($self, $number, $scale) = @_;
    $scale = '' unless defined $scale;
    my $formatter = $self->{'numf'}{$scale}
        ||= $self->numf_formatter(
            length $scale
                ? (-decimal_digits => $scale)
                : ()
        );
    return $formatter->format_number( $number );
}

sub list {
    my ($self, $list, $last_sep, @forms) = @_;

    my $number = $list? @$list : 0;
    my ($index, $exact) = $self->quant_index( $number, @forms ); 
    return $number unless defined $index;
    return $forms[ $index ] if $exact && !$number;

    my $list_text = $list->[-1];
    $list_text = '' unless defined $list_text;
    $list_text =
        join( ', ', @{$list}[0 .. @$list - 2] )
        ." $last_sep "
        . $list_text
            if @$list > 1;

    my $text = $forms[ $index ];
    return join ' ',
        grep defined && length,
        $list_text, $text
        unless $text =~ /_1/;

    $text =~ s/_1/$list_text/;
    return $text;
}

sub quant {
    my ($self, $number, @forms) = @_;

    my ($index, $exact) = $self->quant_index( $number, @forms ); 
    return $number unless defined $index;
    return $forms[ $index ] if $exact && !$number;

    my $text = $forms[ $index ];
    return $number .' '. $text unless $text =~ /_1/;

    $text =~ s/_1/$number/;
    return $text;
}

sub quant_index {
    my ($self, $number, @forms) = @_;

    return undef unless @forms;

    my @index = $self->pick_quant_form( $number );
    die "pick_quant_form didn't return any index for $number"
        unless @index;

    return ($index[0], 1) if $forms[ $index[0] ];

    my ($res) = grep $forms[$_], @index;
    unless ( defined $res ) {
        ($res) = grep $forms[$_], reverse 0 .. $index[-1];
    }
    return ($res, 0);
}

sub pick_quant_form {
    my ($handle, $number, @forms) = @_;

    return 2 unless $number;
    return 1 if $number > 1;
    return 0;
}

1;
