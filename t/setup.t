use strict;
use warnings;

use Test::More;
use Test::More::Ext;

my $state = 'off';
testcase {
    context q(this test will pass) => sub {
        subtest q(should receive params from setup) => sub {
            my $params = shift;
            is $params->{age}, 18;
        };

        subtest q(can die resume subtests) => sub {
            pass;
        };

        subtest q(should receive params from setup 2) => sub {
            my $params = shift;
            is $params->{name}, 'tarou';
        };

        subtest 'another' => sub {
            pass;
        };

        subtest 'another' => sub {
            pass;
        };
    }, setup => sub {
          $state = 'on';
          return { name => 'tarou',
                   age  => 18 };
    }, teardown => sub {
          my $params = shift;
          $state = 'off';
    };
    is $state, 'off', 'after teardown';
};

done_testing;
