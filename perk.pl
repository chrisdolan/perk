use v6;
use PCT;
use Perk::Builtins;
use Perk::Grammar;
use Perk::Grammar::Actions;

# env PERL6LIB='./t:./lib:../rakudo:../../runtime/parrot/library' ../../parrot ../rakudo/perl6.pbc perk.pl --target=past t/Sanity.java

my $pct = PCT::HLLCompiler.new;
$pct.language('Perk');
$pct.parsegrammar('Perk::Grammar'.WHICH);
$pct.parseactions('Perk::Grammar::Actions'.WHICH); # ".WHICH" is a hack to force cast from Rakudo Str to Parrot String

my $compiler = q:PIR { %r = compreg 'Perk' };
@*ARGS.unshift('');  # hack to workaround PCT cmdline problem -- maybe Rakudo shifted already?
$compiler.command_line(@*ARGS);
