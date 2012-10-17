#!/usr/bin/perl

##############################################################################
# Illustratie van het gebruik van lookaround in reguliere expressies         #
# Tim.DePauw@hogent.be                                                       #
# 2012-10-17                                                                 #
##############################################################################

use strict;
use warnings;

$/ = undef;
my $s = <DATA>;
my @matches;

# We willen alle woorden gevolgd door een spatie en een drieletterwoord.
# De regexp wordt dus:
#   ([a-z]+)        # Een woord
#                   # Haakjes om te capturen; drukken we af
#   \               # Letterlijke spatie (met /x modifier)
#   [a-z]{3}        # Drieletterwoord
#   \b              # Exact drie letters, niet meer, dus boundary
# met modifiers:
#   /x              # Negeer witruimte en comments
#   /i              # Hoofdletterongevoelig
#   /g              # Alle woorden, niet enkel eerste

@matches = ($s =~ /
        ([a-z]+)        # $1
        \ 
        [a-z]{3}
        \b
    /xig);
print '1. ', scalar(@matches), ': ', join(' ', @matches), "\n\n";

# We introduceren nu de zgn. "lookahead". Door (?= ) rond een deel van de
# regexp te plaatsen, wordt dat deel "zero-length": we willen dat het er
# staat, maar het wordt niet opgenomen in de match, en heeft dus geen lengte.
# Ook ^, $ en \b zijn voorbeelden van zero-length-uitdrukkingen.
@matches = ($s =~ /
        ([a-z]+)        # $1
        (?=             # Lookahead
            \ 
            [a-z]{3}
            \b
        )               # Einde lookahead
    /xig);
print '2. ', scalar(@matches), ': ', join(' ', @matches), "\n\n";

# Maar we krijgen hier zowaar meer resultaten. Klopt er iets niet? Wel,
# voorbeeld 1 is niet helemaal correct. We passen het toe op vers 8:
#
#     en hoe zij tot hem opkeek als een stervend paard.
#
# De eerste match gebeurt al helemaal bij het begin ervan:
#
#     ([a-z]+)          =>  $1 = 'en'
#     \                 =>  spatie gematcht
#     [a-z]{3}          =>  'hoe'
#     \b                =>  er staat een spatie na 'hoe', dus in orde
#
# Maar dan gaat het fout. De pointer van de m// operator is immers
# opgeschoven tot _na_ de "hoe". De volgende match kan dus ten vroegste
# beginnen bij de spatie na het woord "hoe":
#
#     en hoe zij tot hem opkeek als een stervend paard.
#           ^
#
# Da's echter niet de bedoeling. We willen immers dat de "hoe" ook wordt
# gevonden, want erna staat het drieletterwoord "zij".
# Waarom vinden we dit wel met lookahead? Precies omdat lookaround
# "zero-length" en dus "non-consuming" is: er wordt enkel gecontroleerd of de
# gegeven expressie er staat, maar de pointer schuift niet op. Nadat "en"
# werd gevonden, is de situatie bijgevolg als volgt:
#
#     en hoe zij tot hem opkeek als een stervend paard.
#       ^
#
# De volgende match begint dus ten vroegste bij de spatie na het woord "en",
# en dan wordt "hoe" natuurlijk wel gevonden.
#
# Bemerk overigens dat lookahead ook zuiniger is: /(ab)cd/ slaat "abcd" op
# in de bijzondere variabele $&, maar /(ab)(?=cd)/ slaat enkel "ab" op. Iets
# om in het achterhoofd te houden ...

# Dat lookahead geen lengte heeft, wil niet zeggen dat je ook niet zou kunnen
# capturen -- althans, _binnen_ de lookahead. Als je dus ook het
# drieletterwoord wilt kennen, dan plaats je dat stuk van de expressie gewoon
# tussen haakjes.
@matches = ($s =~ /
        ([a-z]+)        # $1
        (?=             # Lookahead
            \ 
            ([a-z]{3})  # $2 (dus @matches per twee beschouwen)
            \b
        )               # Einde lookahead
    /xig);
print '3. ', scalar(@matches), ': ', join(' ', @matches), "\n\n";

# Je kunt vaak handig gebruikmaken van de niet-verschuivende pointer. Als je
# bv. telkens de eerste van drie of meer opeenvolgende medeklinkers wilt, dan
# kun je dit wel schrijven als
@matches = ($s =~ /([bcdfghj-np-tvwxz])(?=[bcdfghj-np-tvwxz]{2})/g);
print '4. ', scalar(@matches), ': ', join(' ', @matches), "\n\n";

# ... maar die redundantie kan vermeden worden als volgt:
@matches = ($s =~ /(?=[bcdfghj-np-tvwxz]{3})(.)/g);
print '5. ', scalar(@matches), ': ', join(' ', @matches), "\n\n";

# Bemerk dat de lookahead hier _voor_ het consuming deel van de regexp staat!

# Ter illustratie passen we dit ook eens toe op het tweede vers. De pointer
# komt bij de r van "doorkloven" en matcht daar het lookahead-gedeelte. Hij
# schuift echter niet op. Bijgevolg kunnen we eenvoudigweg het eerstvolgende
# karakter opslaan in $1, want we weten al dat we een match hebben. De pointer
# schuift uiteindelijk dus één plaats op.

# Wat we totnogtoe deden is positieve lookahead. We kunnen echter ook op zoek
# gaan naar alle woorden die _niet_ gevolgd worden door een drieletterwoord.
# We veranderen de (?= ) daartoe in (?! ) en verwezenlijken daarmee een
# negatieve lookahead.
@matches = ($s =~ /
        ([a-z]+)        # $1
        (?!             # Negatieve lookahead
            \ 
            [a-z]{3}
            \b
        )               # Einde lookahead
    /xig);
print '6. ', scalar(@matches), ': ', join(' ', @matches), "\n\n";

# Maar dit doet niet wat we willen. Logisch, want het volstaat nu dat een
# opeenvolging van letters niet wordt gevolgd door een spatie. Aangezien een
# letter geen spatie is, worden deelwoorden dus ook gevonden. In de positieve
# versie was dit geen probleem, want de noodzakelijke spatie sloot het woord
# steeds af.
# Hoe kunnen we dit oplossen? De spatie verplaatsen naar buiten de lookahead
# lijkt misschien een mogelijkheid. Niet elk woord wordt echter gevolgd door
# een spatie; er zijn immers ook nog regeleindes en leestekens. We hebben
# daarom opnieuw een boundary nodig.
@matches = ($s =~ /
        ([a-z]+)        # $1
        \b              # Nieuw
        (?!             # Negatieve lookahead
            \ 
            [a-z]{3}
            \b
        )               # Einde lookahead
    /xig);
print '7. ', scalar(@matches), ': ', join(' ', @matches), "\n\n";

# Binnen _negatieve_ lookahead kun je niet capturen. Dit spreekt voor zich:
# iets wat er niet staat, kun je ook niet opslaan. Als je toch wilt capturen
# vanaf de spatie, kun je de lookahead niet tussen capturing haakjes plaatsen,
# want zoals je intussen weet, heeft hij geen lengte. Je moet in dat geval dus
# achteraan de reguliere expressie nog een stuk toevoegen. Je kunt bv. als
# volgt het volgende woord mee opslaan (waarvan je al weet dat het geen drie
# letters telt):
@matches = ($s =~ /
        ([a-z]+)        # $1
        \b
        (?!             # Negatieve lookahead
            \ 
            [a-z]{3}
            \b
        )               # Einde lookahead
        \               # Nieuw
        ([a-z]+)        # $2 (dus @matches opnieuw per 2 beschouwen)
    /xig);
print '8. ', scalar(@matches), ': ', join(' ', @matches), "\n\n";

# Maar helaas, dit is niet volledig. Het stuk achteraan laat nu immers de
# pointer opschuiven, en we maken ongeveer dezelfde fout als in voorbeeld 1.
# Ook dit kunnen we echter op dezelfde manier oplossen: de negatieve lookahead
# heeft de pointer nog niet verplaatst, dus we kunnen er gewoon nog een
# positieve achter plaatsen, die een extra restrictie oplegt en tegelijk een
# capture uitvoert, maar de pointer laat waar hij is.
@matches = ($s =~ /
        ([a-z]+)        # $1
        \b
        (?!             # Negatieve lookahead
            \ 
            [a-z]{3}
            \b
        )               # Einde negatieve lookahead
        (?=             # Nieuw: positieve lookahead
            \ 
            ([a-z]+)    # $2 (dus resultaat opnieuw per 2 beschouwen)
        )               # Einde positieve lookahead
    /xig);
print '9. ', scalar(@matches), ': ', join(' ', @matches), "\n\n";

# De tegenhanger van lookahead is "lookbehind". Waar lookahead controleert of
# een expressie wordt _gevolgd_ door een andere, controleert lookbehind
# logischerwijs of deze erdoor wordt _voorafgegaan_. De operator voor
# lookbehind is (?<= ). Naar analogie met voorbeeld 2 vinden we alle woorden
# voorafgegaan door een drieletterwoord (en een spatie) dus als volgt:
@matches = ($s =~ /
        (?<=            # Lookbehind
            \b          # Exact 3 letters, niet meer, dus boundary
            [a-z]{3}
            \ 
        )               # Einde lookbehind
        ([a-z]+)        # $1
    /xig);
print '10. ', scalar(@matches), ': ', join(' ', @matches), "\n\n";

# En als vierde geval is er ook negatieve lookbehind. Ook hier wordt het
# gelijkheidsteken gewoon een uitroepteken. We kunnen dus op zoek gaan naar
# alle woorden die niet worden voorafgegaan door een drieletterwoord. Zoals
# bij de overgang van voorbeeld 6 naar 7, voegen we weer een boundary toe;
# anders zouden we immers gewoon alle deelwoorden vinden.
@matches = ($s =~ /
        (?<!            # Negatieve lookbehind
            \b
            [a-z]{3}
            \ 
        )               # Einde lookbehind
        \b              # Nieuw
        ([a-z]+)        # $1
    /xig);
print '11. ', scalar(@matches), ': ', join(' ', @matches), "\n\n";

# Er is echter een beperking op (zowel positieve als negatieve) lookbehind:
# de expressie binnen de lookbehind moet helaas een vaste lengte hebben. Bij
# lookahead is dit niet het geval. We kunnen voorbeeld 2 dus wel aanpassen om
# woorden gevolgd door een woord van drie _of meer_ letters te vinden:
@matches = ($s =~ /
        ([a-z]+)        # $1
        (?=             # Lookahead
            \ 
            [a-z]{3,}   # Enige verschil: komma na de 3
                        # Hier stond nog een boundary; mag nu weg
        )               # Einde lookahead
    /xig);
print '12. ', scalar(@matches), ': ', join(' ', @matches), "\n\n";

# Maar als we voorbeeld 11 op analoge manier zouden aanpassen, zouden we de
# foutmelding "Variabele length lookbehind not implemented" krijgen. Misschien
# ondersteunt Perl dit ooit wel, maar intussen wordt reeds een tegemoetkoming
# gedaan, en wel met het \K-anker ("keep"). Alles wat in een regexp voor \K
# komt, wordt als het ware weggegooid. Belangrijk verschil echter: (?<= ) kan
# terugkeren in de string, zelfs voorbij het \G-anker (het einde van de vorige
# match), terwijl \K enkel kan zoeken vanaf \G. Volgende twee operaties (met
# regexp met vaste lengte) zijn dus verschillend:
@matches = ('abcdefghi' =~ /(?<=[a-z]{3})./g);
print '13. ', scalar(@matches), ': ', join(' ', @matches), "\n\n";
@matches = ('abcdefghi' =~ /[a-z]{3}\K./g);
print '14. ', scalar(@matches), ': ', join(' ', @matches), "\n\n";

# Tot slot: totnogtoe hebben we enkel de m//-operator gebruikt, maar
# natuurlijk wordt lookaround ook ondersteund bij substitutie. Om bijvoorbeeld
# alle woorden gevolgd door een drieletterwoord om te keren, passen we
# voorbeeld 7 licht aan. Om duidelijk te zien welke woorden werden vervangen,
# plaatsen we deze ook tussen vierkante haakjes.
$s =~ s/
        ([a-z]+)        # $1
        \b
        (?=             # Lookahead
            \ 
            [a-z]{3}
            \b
        )               # Einde lookahead
    /'[' . reverse($1) . ']'/xige;
print '15. ', $s;

# Ook dit kan niet zonder lookahead. Als je immers de lookahead omzet in een
# gewone capturing group (de "?=" weglaten) en $2 achter de vervangstring
# plakt, krijg je opnieuw te maken met het probleem van opeenvolgende woorden.

##############################################################################

__DATA__
Toen hij bespeurde hoe de nevel van de tijd
in de ogen van zijn vrouw de vonken uit kwam doven,
haar wangen had verweerd, haar voorhoofd had doorkloven
toen wendde hij zich af en vrat zich op van spijt.

Hij vloekte en ging te keer en trok zich bij de baard
en mat haar met de blik, maar kon niet meer begeren,
hij zag de grootse zonde in duivelsplicht verkeren
en hoe zij tot hem opkeek als een stervend paard.

Maar sterven deed zij niet, al zoog zijn helse mond
het merg uit haar gebeente, dat haar toch bleef dragen.
Zij dorst niet spreken meer, niet vragen of niet klagen,
en rilde waar zij stond, maar leefde en bleef gezond.

Hij dacht: ik sla haar dood en steek het huis in brand.
Ik moet de schimmel van mijn stramme voeten wassen
en rennen door het vuur en door het water plassen
tot bij een ander lief in enig ander land.

Maar doodslaan deed hij niet, want tussen droom en daad
staan wetten in de weg en praktische bezwaren,
en ook weemoedigheid, die niemand kan verklaren,
en die des avonds komt, wanneer men slapen gaat.

Zo gingen jaren heen. De kindren werden groot
en zagen dat de man die zij hun vader heetten,
bewegingloos en zwijgend bij het vuur gezeten,
een godvergeten en vervaarlijke aanblik bood.
