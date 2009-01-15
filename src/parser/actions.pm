# $Id$

=begin comments

perk::Grammar::Actions - ast transformations for perk

********
THIS INITIAL VERSION IS PURELY DEBUG CODE!  There is no real implementation here yet...
********

This file contains the methods that are used by the parse grammar
to build the PAST representation of an perk program.
Each method below corresponds to a rule in F<src/parser/grammar.pg>,
and is invoked at the point where C<{*}> appears in the rule,
with the current match object as the first argument.  If the
line containing C<{*}> also has a C<#= key> comment, then the
value of the comment is passed as the second argument to the method.

=end comments

class perk::Grammar::Actions;

method TOP($/) {
   say('TOP');
   make PAST::Block.new( :pirflags(':main') );
}
method compilationUnit($/) {
   say('compilationUnit');
}
method packageDeclaration($/) {
   say('package');
}
method annotation($/) {
   say('annot:');
   say($<annotationName>);
}
method importDeclaration($/) {
   say($/);
}
method fieldDeclaration($/) {
   say('field:');
   say($/);
}
method methodDeclaration($/) {
   say('method:');
   say($<Identifier>);
}
method block($/) {
   say('block:');
   say($/);
}
method expression($/) {
   say('expression:');
   say($/);
}
method parExpression($/) {
   say('parExpression:');
   say($/);
}
method blockStatement($/) {
   say('statement:');
   say($<statement>);
}
method localVariableDeclaration($/) {
   say('local:');
   say($/);
}
method normalClassDeclaration($/, $key) {
   if ($key eq 'start') {
      say('class:');
      say($<Identifier>);
   }
}
method arrayCreatorRest($/) {
   say('arrayCreatorRest, expr:');
   say($<expression>);
}

method primary($/) {
   say('primary, this:');
   say($/);
}

method switchLabel($/, $key) {
  say('switchLabel:');
  if ($key eq 'normal') {
    say($<constantExpression>);
  } elsif ($key eq 'enum') {
    say($<enumConstantName>);
  } elsif ($key eq 'default') {
    say('default');
  }
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
