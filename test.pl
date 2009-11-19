use strict;
use warnings;

use open IO => ':locale';

use lib 'lib';

use MyApp::I18N;

my @LANG = ('en');
sub loc(@) {
    my $handle = MyApp::I18N->get_handle(@LANG);
    return $handle->maketext(@_)
}

print loc_all("Hello, World!"),"\n";
print loc_all("Hello, [_1]!", getpwuid($<) ),"\n";

my $msg = "Launched [quant,_1,process,processes,zero processes]";
print loc_all($msg, 0),"\n";
print loc_all($msg, 1),"\n";
print loc_all($msg, 22),"\n";
print loc_all($msg, 16),"\n";

$msg = "[list,_1,and,Player _1 won,Players _1 won,Draw]!";
print loc_all($msg),"\n";
print loc_all($msg, [scalar getpwuid($<)]),"\n";
print loc_all($msg, [qw(foo bar baz)]),"\n";

sub loc_all {
    my @arg = @_;
    my @res;
    foreach (['en'], ['ru']) {
        @LANG = @$_;
        push @res, loc(@arg);
    }
    return join "\n", @res;
}
