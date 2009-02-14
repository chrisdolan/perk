use v6;
use PCT;
use Perk::Builtins;
use Perk::Grammar;
use Perk::Grammar::Actions;

#my $perl6_compiler = q:PIR { %r = compreg 'Perl6' }; #: # close ':' for emacs highlighting glitch
#my $compiler_name = $perl6_compiler.compiler_progname;
#say 'Perl6 HLL Program: ', $compiler_name;
#say 'This program: ', $?PROGRAM;

my $pct = PCT::HLLCompiler.new;
$pct.language('Perk');
$pct.parsegrammar('Perk::Grammar'.WHICH); # ".WHICH" is a hack to force cast from Rakudo Str to Parrot String
$pct.parseactions('Perk::Grammar::Actions'.WHICH);

# Hack: the Rakudo PCT::HLLCompiler instance already shifted args[0]
# off, so we need to put something back on just so PCT::HLLCompiler
# can shift it back off again.
#@*ARGS.unshift(PROCESS::<$PROGRAM_NAME>);
@*ARGS.unshift('perk.pbc'); # hack since program name is not implemented in Rakudo

$pct.command_line(@*ARGS, :encoding('utf8'));
#my $perk_compiler_name = $pct.compiler_progname;
#say 'Perk HLL Program: ', $perk_compiler_name;
