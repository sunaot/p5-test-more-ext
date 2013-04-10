use strict;
use warnings;

use Test::More;
use Test::More::Ext;

my $state = 'off';
testcase {
    subtest q(should receive params from setup) => sub {
        my $params = {age => 18};
        is $params->{age}, 18, 'A';
    };

    subtest 'another' => sub {
        pass 'B';
    };

    subtest q(can die resume subtests) => sub {
        pass 'C';
        die 'fatal';
    };

    subtest q(should receive params from setup 2) => sub {
        my $params = {name => 'tarou'};
        is $params->{name}, 'tarou', 'D';
    };

    subtest 'another' => sub {
        pass 'E';
    };
    is $state, 'off', 'after teardown';
};

done_testing;
