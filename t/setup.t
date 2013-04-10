use strict;
use warnings;

use Test::More;
use Test::More::Ext;

testcase {
    subtest q(this test will pass) => sub {
        my $params = shift;
        pass;
      },
      setup => sub {
          return name => 'tanabe',
                 age  => 30;
      },
      teardown => sub {
          my $params = shift;
      };
};

done_testing;
