# $Id$

=head1

Perk::Builtins -- compiler helper routines

=cut

.namespace []

.sub '!create_class'
    .param string name
    $P0 = split '.', name
    $P0 = newclass $P0
    .return ($P0)
.end

.sub 'say'
    .param pmc args            :slurpy
    .local pmc iter
    iter = new 'Iterator', args
  iter_loop:
    unless iter goto iter_end
    $P0 = shift iter
    print $P0
    goto iter_loop
  iter_end:
    print "\n"
    .return ()
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

