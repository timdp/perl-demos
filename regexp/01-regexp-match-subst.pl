#!/usr/bin/perl

##############################################################################
# Illustratie van het gebruik van reguliere expressies in Perl               #
# Tim.DePauw@hogent.be                                                       #
# 2012-10-17                                                                 #
##############################################################################

use strict;
use warnings;

# Als je de optie -i meegeeft, kun/moet je na elk voorbeeld op return drukken.
my $interactive = (@ARGV && shift(@ARGV) eq '-i');

# Nog enkele hulpvariabelen ...
my ($m, @m, $n);

##############################################################################

# Eerst bekijken we matching, d.w.z. zoeken, telkens op basis van deze string:
my $s = 'lorem ipsum dolor sit amet';

##############################################################################

print '== De m//-operator en /g-modifier ===', "\n\n";

# Met de m//-operator ga je op zoek naar een regexp in een string. In scalaire
# context krijg je het aantal matches terug. Capture groups (d.w.z. haakjes)
# resulteren in toewijzing aan de variabelen $1, $2, enz.
print '1. $scalar = m//', "\n\n";
$m = ($s =~ m/([a-z]+) ([a-z]+)/);
print '   $m = ', $m, "\n";
print '   $1 = ', $1, "\n";
print '   $2 = ', $2, "\n";
<STDIN> if $interactive;
print "\n";

# Het instellen van pos($s) op 0 zorgt ervoor dat de volgende match weer vanaf
# het eerste teken van de string begint. Omdat we hier telkens dezelfde string
# en regexp gebruiken, is het noodzakelijk; meestal is het dat echter niet.
pos($s) = 0;

# Zoals je weet, wordt een getal verschillend van nul beschouwd als zijnde
# true. Daarom kun je het resultaat van een match ook als voorwaarde
# gebruiken, wat aanleiding geeft tot constructies als:
if ($s =~ m/([a-z]+) ([a-z]+)/) {
	my ($woord1, $woord2) = ($1, $2);
	# Hier de verdere verwerking.
} else {
	# Niet gevonden.
}

# In lijstcontext belanden de waarden van $1, $2, enz. in de array die je
# terugkrijgt.
# We maken hier ook van de gelegenheid gebruik om aan te tonen dat het
# scheidingsteken geen schuine streep hoeft te zijn. Is het echter wél een
# schuine streep, dan mag je het voorvoegsel 'm' weglaten.
print '2. @list = m//', "\n\n";
pos($s) = 0;
@m = ($s =~ m!([a-z]+) ([a-z]+)!);
print '   @m = ', join(' -- ', @m), "\n";
print '   $1 = ', $1, "\n";
print '   $2 = ', $2, "\n";
<STDIN> if $interactive;
print "\n";

# Door m// in lijstcontext toe te passen, kan de if-constructie hierboven nog
# korter worden geschreven. Mislukt de match, dan krijgen de variabelen
# allemaal de waarde undef.
pos($s) = 0;
my ($woord1, $woord2) = ($s =~ m!([a-z]+) ([a-z]+)!);

# Na de schuine streep (of een ander scheidingsteken) kun je "modifiers"
# toevoegen, die de werking van de match beïnvloeden. Een van die modifiers is
# de 'g', wat staat voor "global". Standaard gebeurt matching één enkele keer.
# Met de /g-modifier gaat het matchen door tot er geen resultaten meer worden
# gevonden. We proberen dit eerst uit in scalaire context.
print '3. $scalar = m//g', "\n\n";
pos($s) = 0;
$m = ($s =~ /([a-z]+) ([a-z]+)/g);
print '   $m = ', $m, "\n";
print '   $1 = ', $1, "\n";
print '   $2 = ', $2, "\n";
<STDIN> if $interactive;
print "\n";

# We zien dat we nog steeds enkel het eerste resultaat krijgen. Echter is
# achter de schermen wel het einde van de eerste match bijgehouden; dit is de
# befaamde pos($s). Om alle matches te krijgen, moeten we in lijstcontext
# werken:
print '4. @list = m//g', "\n\n";
pos($s) = 0;
@m = ($s =~ /([a-z]+) ([a-z]+)/g);
print '   @m = ', join(' -- ', @m), "\n";
print '   $1 = ', $1, "\n";
print '   $2 = ', $2, "\n";
<STDIN> if $interactive;
print "\n";

# Nu zien we dat de waarden van $1 en $2 voor de verschillende matches achter
# elkaar worden geplakt in één enkele array. Vaak is dat niet zo interessant;
# zowel qua structuur als qua geheugengebruik kan het vervelend worden.
# Onderstaand patroon met while is daarom courant. In elke iteratie van de lus
# wordt één match behandeld; dit is dus vergelijkbaar met de if-constructie.
print '5. while (m//g)', "\n\n";
pos($s) = 0;
my $i = 0;
while ($s =~ /([a-z]+) ([a-z]+)/g) {
	print '   -- Stap ', ++$i, ' --', "\n";
	print '   $1 = ', $1, "\n";
	print '   $2 = ', $2, "\n";
	print "\n";
}
<STDIN> if $interactive;

##############################################################################

# Een eenvoudig te gebruiken modifier is /i. Deze zorgt ervoor dat de regexp
# als hoofdletterongevoelig (case-Independent) wordt geïnterpreteerd.
print "\n";
print '== De /i-modifier ===', "\n\n";

# Een keertje zonder de modifier ...
print '1. m//', "\n\n";
$s = 'Lorem IPSUM dolor Sit Amet';
pos($s) = 0;
$m = ($s =~ /([a-z]+) ([a-z]+)/);
print '   $m = ', $m, "\n";
<STDIN> if $interactive;
print "\n";

# ... en nu mét.
print '2. m//i', "\n\n";
$s = 'Lorem IPSUM dolor Sit Amet';
pos($s) = 0;
$m = ($s =~ /([a-z]+) ([a-z]+)/i);
print '   $m = ', $m, "\n";
<STDIN> if $interactive;
print "\n";

# Merk op: om performantieredenen wordt wel eens aangeraden om de /i-modifier
# niet te gebruiken. In ons voorbeeld kunnen we daarom beter expliciet
# [A-Za-z] schrijven. Is de performantie niet cruciaal, gebruik /i dan gerust.

################################################################################

# Naar analogie met de m//-operator voor matching, is er de s//-operator om
# deelstrings te vervangen op basis van een reguliere expressie. Terwijl m//
# enkel een patroon vereist, krijgt s// ook nog een vervangstring mee, die
# eveneens wordt afgebakend door een schuine streep (of een ander karakter).
# In tegenstelling tot bij m// kan het voorvoegsel 's' nooit worden
# weggelaten.

################################################################################

print "\n";
print '== De s//-operator en /g-modifier ===', "\n\n";

# Eerst voeren we een substitutie zonder modifiers uit. Net als bij de
# m//-operator wordt enkel de eerste match behandeld. Bemerk dat de
# vervangstring wordt geïnterpoleerd, d.w.z. behandeld alsof hij tussen
# dubbele aanhalingstekens staat.
print '1. $scalar = s///', "\n\n";
$s = 'lorem ipsum dolor sit amet';
pos($s) = 0;
$n = ($s =~ s/([a-z]+) ([a-z]+)/$2 $1/);
print '   $n = ', $n, "\n";
print '   $1 = ', $1, "\n";
print '   $2 = ', $2, "\n";
print '   $s = ', $s, "\n";
<STDIN> if $interactive;
print "\n";

# Analoog kunnen we nu de substitutie globaal maken met /g. We gebruiken ter
# illustratie ook eens accolades i.p.v. schuine strepen.
print '2. $scalar = s///g', "\n\n";
$s = 'lorem ipsum dolor sit amet';
pos($s) = 0;
$n = ($s =~ s{([a-z]+) ([a-z]+)}{$2 $1}g);
print '   $n = ', $n, "\n";
print '   $1 = ', $1, "\n";
print '   $2 = ', $2, "\n";
print '   $s = ', $s, "\n";
<STDIN> if $interactive;
print "\n";

##############################################################################

print "\n";
print '== De /s-modifier ===', "\n\n";

# De /s-modifier (Single line) verandert de betekenis van de punt. Zonder deze
# modifier staat . zoals je weet voor eender welk karakter. Linefeeds horen
# daar echter niet bij, zoals mag blijken uit onderstaand voorbeeld.
# Opgelet: de verticale strepen in de vervangstring staan er om duidelijk de
# grenzen van $1, $2 en $3 te zien. Ze staan dus niet voor "of", want de
# vervangstring is geen reguliere expressie!
print '1. s///', "\n\n";
$s = "lorem ipsum\ndolor sit amet";
pos($s) = 0;
$s =~ s/([a-z])(.*)([a-z])/|$3|$2|$1|/;
print $s, "\n";
<STDIN> if $interactive;
print "\n";

# Voeg je de modifier /s toe, dan kan een punt ook een linefeed voorstellen.
print '2. s///s', "\n\n";
$s = "lorem ipsum\ndolor sit amet";
pos($s) = 0;
$s =~ s/([a-z])(.*)([a-z])/|$3|$2|$1|/s;
print $s, "\n";
<STDIN> if $interactive;
print "\n";

##############################################################################

print "\n";
print '== De /m-modifier ===', "\n\n";

# Ook de /m-modifier (Multi-line) wijzigt de betekenis van metakarakters.
# Meerbepaald beïnvloedt hij de interpretatie van de tekens ^ en $. Standaard
# stellen deze het begin en einde van de (volledige) string voor.
print '1. s///', "\n\n";
$s = "lorem ipsum\ndolor sit amet";
pos($s) = 0;
$s =~ s/^([a-z])(.*)([a-z])$/|$3|$2|$1|/;
print $s, "\n";
<STDIN> if $interactive;
print "\n";

# Voegen we echter /m toe, dan wijzigt de betekenis van ^ en $ naar resp. het
# begin en einde van een regel binnen de string.
print '2. s///m', "\n\n";
$s = "lorem ipsum\ndolor sit amet";
pos($s) = 0;
$s =~ s/^([a-z])(.*)([a-z])$/|$3|$2|$1|/m;
print $s, "\n";
<STDIN> if $interactive;
print "\n";

# Je kunt modifiers combineren naar believen; de volgorde van de letters heeft
# daarbij geen belang.
print '3. s///imsg', "\n\n";
$s = "Lorem IPSUM\ndolor Sit Amet";
pos($s) = 0;
$s =~ s/^([a-z])(.*)([a-z])$/|$3|$2|$1|/imsg;
print $s, "\n";
<STDIN> if $interactive;
print "\n";

##############################################################################

print "\n";
print '== De /e-modifier ===', "\n\n";

# De /e-modifier (Evaluate) is misschien wel de krachtigste. Hij laat toe om
# als vervangstring een Perl-expressie op te nemen i.p.v. een geïnterpoleerde
# string. Zo kun je dus eender welk stuk code uitvoeren met een match. In dit
# eenvoudige voorbeeld gebruiken we enkel de uc-functie.
print '1. s///eg', "\n\n";
$s = 'lorem ipsum dolor sit amet';
pos($s) = 0;
$s =~ s/([a-z]+) ([a-z]+)/uc($2) . ' ' . uc($1)/eg;
print '   $s = ', $s, "\n";
<STDIN> if $interactive;
print "\n";

# Bijzonder aan /e is dat hij meermaals kan voorkomen. Zo zorg je ervoor dat
# het resultaat van het stukje code nogmaals wordt geïnterpreteerd als
# Perl-code. Hieronder vervangen we bv. '%x%' door 'uc($x)', en dus vervolgens
# door de waarde van $x in hoofdletters.
print '2. s///eeg', "\n\n";
$s = '%x%, %y%';
my $x = 'Hello';
my $y = 'world';
pos($s) = 0;
$s =~ s/%([a-z]+)%/'uc($' . $1 . ')'/eeg;
print '   $s = ', $s, "\n";
<STDIN> if $interactive;
print "\n";

# De kracht van /e maakt deze modifier natuurlijk ook ietwat onveilig. Werk je
# op een string die door de gebruiker is aangeleverd, dan hoeft die niet zo
# veel moeite te doen om uitvoerbare code te injecteren. De sjabloontaal die
# we hierboven introduceerden, valt veiliger (en sneller) te implementeren:
print '3. s///g', "\n\n";
$s = '%x%, %y%';
my %strings = ('x' => 'Hello', 'y' => 'world');
$_ = uc foreach values %strings;
pos($s) = 0;
$s =~ s/%([a-z]+)%/$strings{$1}/g;
print '   $s = ', $s, "\n";
<STDIN> if $interactive;
print "\n";

##############################################################################

print "\n";
print '== De /x-modifier ===', "\n\n";

# Tot slot bespreken we nog de /x-modifier (eXtended), die toelaat om lange
# regexps leesbaarder te maken. De regexps die we hierboven bespraken, waren
# eerder eenvoudig (al zullen sommigen dat misschien betwisten). Toch
# schrijven we er hieronder eentje expliciet uit met /x. Je merkt twee zaken
# op: met het spoorwegteken kun je commentaar opnemen, en witruimte wordt
# volledig genegeerd. Als gevolg van dat laatste moet je spaties en
# spoorwegtekens wel laten voorafgaan door een backslash.
$s = 'lorem ipsum dolor sit amet';
pos($s) = 0;
$s =~ s/
		(				# Begin van $1
			[a-z]+      # Woord
		)               # Einde van $1
		\               # Expliciete spatie (\s zou hier ook werken)
		(				# Begin van $2
			[a-z]+      # Nog een woord
		)               # Einde van $2
	/$2 $1/gx;
print '   $s = ', $s, "\n";
print "\n";

##############################################################################

# Perl kent nog meer modifiers, maar we beperken ons in de labo's tot /egimsx.
# De volledige lijst met modifiers wordt besproken in de documentatie, nl.
# de pagina 'perlre'.

##############################################################################

# Slotvraagje: welke van de modifiers die we pas introduceerden bij
# substitutie kun je ook gebruiken bij matching?

##############################################################################
