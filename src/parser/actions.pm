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
   make $( $<compilationUnit> );
}

method compilationUnit($/) {
    my $outer := PAST::Block.new( :node($/) );
    if $<classOrInterfaceDeclaration> {
        $outer.push($( $<classOrInterfaceDeclaration> ));
    }
    if $<typeDeclaration> {
        for $<typeDeclaration> {
            if $_<classOrInterfaceDeclaration> {
                $outer.push($( $_<classOrInterfaceDeclaration> ));
            }
        }
    }
    make $outer;
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

method classOrInterfaceDeclaration($/) {
    if $<classDeclaration> {
        make $( $<classDeclaration> );
    }
    else {
        make $( $<interfaceDeclaration> );
    }
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
    my $statements := PAST::Stmts.new( :node($/) );
    if $<blockStatement> {
        for $<blockStatement> {
            $statements.push($( $_ ));
        }
    }
    make PAST::Block.new( $statements );
}

method expression($/) {
    make PAST::Stmts.new();
}

method parExpression($/) {
   say('parExpression:');
   say($/);
}

method blockStatement($/, $key) {
   make $( $/{$key} );
}

method localVariableDeclaration($/) {
   say('local:');
   say($/);
}

method classDeclaration($/, $key) {
    make $( $/{$key} );
}

method normalClassDeclaration($/) {
    my $class := $( $<classBody> );
    $class.loadinit().push(
        PAST::Op.new(
            :pasttype('call'),
            :name('!create_class'),
            ~$<Identifier>
        )
    );
    $class.namespace(~$<Identifier>);
    make $class;
}

method classBody($/) {
    my $body := PAST::Block.new( :node($/) );
    for $<classBodyDeclaration> {
        $body.push($( $_ ));
    }
    make $body;
}

method classBodyDeclaration($/, $key) {
    if $key eq 'staticinit' {
        my $block := $( $<block> );
        $block.pirflags(':load :init');
        make $block;
    }
    else {
        make $( $<memberDecl> );
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

method memberDecl($/, $key) {
    my $past := $( $/{$key} );
    if $<Identifier> {
        $past.name(~$<Identifier>);
    }
    make $past;
}

method voidMethodDeclaratorRest($/) {
    my $block := $( $<methodBody> );
    # XXX Params
    make $block;
}

method methodBody($/) {
    make $( $<block> );
}

method statement($/) {
    # XXX loads to fill out here
    make $( $<statementExpression> );
}

method statementExpression($/) {
    make $( $<expression> );
}



# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
