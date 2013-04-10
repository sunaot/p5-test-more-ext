use strict;
use warnings;

use Test::More;
use Test::More::Ext;

testcase {
    subtest 'what you need' => sub {
        ok(1);
    };

    context(
        'when login' => sub {
            subtest 'should be login' => sub {
                my $params = shift;
                is $params->{login}, 1;
                $params->{login} = -100;
            };

            # setup/teardown is called for every subtest
            subtest 'should be ...' => sub {
                my $params = shift;
                is $params->{login}, 1, 'cleanup automatically';
            };
        },
        setup => sub {
            return {login => 1};
        },
        teardown => sub { 
        }
    );

    context(
        'when not login' => sub {
            subtest 'should not be logged in' => sub {
                my $params = shift;
                is $params->{login}, 0;
            };
        },
        setup => sub {
            {login => 0}
        },
        teardown => sub {
        },
    );
};

done_testing;
