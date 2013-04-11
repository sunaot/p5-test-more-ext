use strict;
use warnings;

use Test::More;
use Test::More::Ext;

testcase {
    my $setup_counter = 0;
    context(
      'Test::More::Ext::context setup' => sub {
          subtest 'should run on first subtest call' => sub {
              is $setup_counter, 1;
          };

          subtest 'should run on each subtest calls' => sub {
              is $setup_counter, 2;
          };
      },
      setup => sub {
          $setup_counter++;
      },
    );

    my $teardown_counter = 0;
    context(
      'Test::More::Ext::context teardown' => sub {
          subtest 'should not run before first subtest call' => sub {
              is $teardown_counter, 0;
          };

          subtest 'should run after first subtest call' => sub {
              is $teardown_counter, 1;
          };

          subtest 'should run after each subtest calls' => sub {
              is $teardown_counter, 2;
          };
      },
      teardown => sub {
          $teardown_counter++;
      },
    );
};

done_testing;
