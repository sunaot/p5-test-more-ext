package Test::More::Ext;

use 5.008008;
use strict;
use warnings;

our $VERSION = '0.01';

use parent qw(Exporter);
our @EXPORT = qw(testcase);

use Test::More;
use List::MoreUtils qw(any);

# based on Test::Builder VERSION 0.98
sub testcase(&) {
    my $proc = shift;
    my $subtest = *Test::Builder::subtest{CODE};
    my $more_subtest = *Test::More::subtest{CODE};

    my $safe_more_subtest = sub($&@) {
        eval { $more_subtest->(@_) };
    };
    my $safetest = sub {
        my ($self, $name, $subtests, %args) = @_;

        if ('CODE' ne ref $subtests) {
            $self->croak("subtest()'s second argument must be a code ref");
        }
        my $setup = delete local $args{setup} || sub {};
        my $teardown = delete local $args{teardown} || sub {};

        # Turn the child into the parent so anyone who has stored a copy of
        # the Test::Builder singleton will get the child.
        my($error, $child, %parent);
        {
            # child() calls reset() which sets $Level to 1, so we localize
            # $Level first to limit the scope of the reset to the subtest.
            local $Test::Builder::Level = $Test::Builder::Level + 1;

            $child  = $self->child($name);
            %parent = %$self;
            %$self  = %$child;

            my $run_the_subtests = sub {
                my @errors;
                my $params;
                eval {
                    $params = $setup->();
                    1;
                } or push @errors, $@;
                if (!$@) {
                    eval {
                        $subtests->($params);
                        1;
                    } or push @errors, $@;
                }
                eval {
                    $teardown->($params);
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
    {
        no warnings 'redefine';
        local *Test::Builder::subtest = $safetest;
        local *Test::More::subtest = $safe_more_subtest;
        $proc->();
    }
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Test::Ext - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Test::Ext;
  
  testcase {
      subtest 'what you need' => sub {
          ok(1);
      };

      sub setup {
          # setup is called before each subtests like xUnit.
      }

      sub teardown {
          # teardown is called after each subtests.
      }
  };

  done_testing;

=head1 DESCRIPTION

Test::Ext is Test::More extension and can be used with bare subtest.

This module only affect during the testcase { } block, so bare 
subtest function can be used outside of the testcase { } block.

Using Test::Ext, your subtests are never stopped with uncatched die()
in subtest closure.

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
