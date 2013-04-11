use strict;
use warnings;

use Test::More;
use Test::More::Ext;

testcase {
    my $history;
    context(
      'on condition A' => sub {
          context(
              'on condition B' => sub {
                  subtest 'context can nest setup procedures' => sub {
                      my $params = shift;
                      is_deeply [$params->{call_stack}->history],
                                ['condition-A-setup', 'condition-B-setup'];
                      $params->{call_stack}->add('subtest');
                  };
              },
              setup => sub {
                  my $params = shift;
                  $params->{call_stack}->add('condition-B-setup');
                  return $params;
              },
              teardown => sub {
                  my $params = shift;
                  $params->{call_stack}->add('condition-B-teardown');
              },
          );
      },
      setup => sub {
          my $stack = CallStack->new('condition-A-setup');
          return { call_stack => $stack };
      },
      teardown => sub {
          my $params = shift;
          $params->{call_stack}->add('condition-A-teardown');
          $history = $params->{call_stack};
      },
    );
    subtest 'context can nest teardown procedures' => sub {
        is_deeply [$history->history],
                  [qw[
                      condition-A-setup
                      condition-B-setup
                      subtest
                      condition-B-teardown
                      condition-A-teardown
                  ]];
    };
};

done_testing;

{
    package CallStack;
    sub new {
        my ($class, @args) = @_;
        bless {
            call_stack => [@args],
        }, $class;
    }
    sub add {
        my ($self, @args) = @_;
        push @{ $self->{call_stack} }, @args;
    }
    sub history {
        return @{ shift->{call_stack} };
    }
}
