package Test::More::Ext;

use 5.008008;
use strict;
use warnings;

our $VERSION = '0.01';

use parent qw(Exporter);
our @EXPORT = qw(testcase context);

use Test::More;

# based on Test::Builder VERSION 0.98
sub testcase(&) {
    my $block = shift;
    my $subtest = *Test::Builder::subtest{CODE};
    my $child = *Test::Builder::child{CODE};
    my $more_subtest = *Test::More::subtest{CODE};

    my $safe_more_subtest = sub($&) {
        eval { $more_subtest->(@_) };
    };
    my $ext_child = sub {
        my ($self, $name) = @_;
        my $c = $child->(@_);
        $c->{Setup} = $self->{Setup};
        $c->{Teardown} = $self->{Teardown};
        return $c;
    };
    my $safetest = sub {
        my ($self, $name, $subtests) = @_;

        if ('CODE' ne ref $subtests) {
            $self->croak("subtest()'s second argument must be a code ref");
        }

        my($error, $child, %parent);
        {
            # child() calls reset() which sets $Level to 1, so we localize
            # $Level first to limit the scope of the reset to the subtest.
            local $Test::Builder::Level = $Test::Builder::Level + 1;

            %parent = %$self;
            $child  = $self->child($name);
            %$self  = %$child;

            my $run_the_subtests = sub {
                my @errors;
                my $params;
                eval {
                    foreach my $setup (@{ $self->{Setup} }) {
                        $params = $setup->($params);
                    }
                    1;
                } or push @errors, $@; # continue to ensure teardown when error
                if (!$@) {
                    eval {
                        $subtests->($params);
                        1;
                    } or push @errors, $@;
                }
                eval {
                    foreach my $teardown (@{ $self->{Teardown} }) {
                        $teardown->($params);
                    }
                    1;
                } or push @errors, $@;
                die shift @errors if @errors;
                $self->done_testing unless $self->_plan_handled;
                1;
            };

            if( !eval { $run_the_subtests->() } ) {
                $error = $@;
            }
        }

        # Restore the parent and the copied child.
        %$child = %$self;
        %$self = %parent;

        # Restore the parent's $TODO
        $self->find_TODO(undef, 1, $child->{Parent_TODO});

        # Die *after* we restore the parent.
        die $error if $error and !eval { $error->isa('Test::Builder::Exception') };

        local $Test::Builder::Level = $Test::Builder::Level + 1;
        return $child->finalize;
    };
    my $context = sub {
        my ($self, $name, $scope, %args) = @_;

        my $setup = delete local $args{setup} || sub {};
        my $teardown = delete local $args{teardown} || sub {};
        $self->{Setup} ||= ();
        $self->{Teardown} ||= ();
        push @{ $self->{Setup} }, $setup;
        unshift @{ $self->{Teardown} }, $teardown;

        $subtest->($self, $name, $scope);
    };
    {
        no warnings 'redefine';
        local *Test::Builder::subtest = $safetest;
        local *Test::Builder::child = $ext_child;
        local *Test::Builder::context = $context;
        local *Test::More::subtest = $safe_more_subtest;
        local *main::subtest = *Test::More::subtest{CODE};
        $block->();
    }
}

sub context($&@) {
    my ($name, $context) = @_;

    my $tb = Test::More->builder;
    return eval { $tb->context(@_) };
}

{
    package Test::Builder;
    sub context {}
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Test::More::Ext - enable nested setup/teardown to Test::More::subtest

=head1 SYNOPSIS

  use Test::More;
  use Test::More::Ext;
  
  testcase {
      subtest 'test should pass' => sub {
          pass;
      };

      context(
          'when login' => sub {
              subtest 'should be logged in' => sub {
                  my $params = shift;
                  is $params->{login}, 1;
              };

              # setup/teardown is called for every subtest
              subtest 'should be ...' => sub {
                  my $params = shift;
                  ...
              };
          },
          setup => sub {
              return {login => 1};
          },
          teardown => sub {
              my $params = shift;
              delete $params->{login};
          },
      );
  };

  done_testing;

=head1 DESCRIPTION

Test::More::Ext is Test::More extension and can be used with bare subtest.

This module only affect during the testcase { } block, so bare 
subtest function can be used outside of the testcase { } block.

Using Test::More::Ext, subtest can continue to run after an uncatched die()
error in subtest closures.

=head1 SEE ALSO

* Test::More

=head1 AUTHOR

Sunao Tanabe, E<lt>sunao.tanabe@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Sunao Tanabe

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.3 or,
at your option, any later version of Perl 5 you may have available.


=cut
