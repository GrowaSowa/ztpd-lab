(:XQuery (19.12):)
(:5:)
for $b in doc("db/bib/bib.xml")/bib/book
return $b/author/last


(:6:)
for $b in doc("db/bib/bib.xml")/bib/book
return <ksiazka>
  {$b/author}
  {$b/title}
</ksiazka>


(:7:)
for $b in doc("db/bib/bib.xml")/bib/book
return <ksiazka>
  <autor>{$b/author/last/text()}{$b/author/first/text()}</autor>
  <tytul>{$b/title/text()}</tytul>
</ksiazka>


(:8:)
for $b in doc("db/bib/bib.xml")/bib/book
return <ksiazka>
  <autor>{concat($b/author/last/text()," ",$b/author/first/text())}</autor>
  <tytul>{$b/title/text()}</tytul>
</ksiazka>


(:9:)
for $b in doc("db/bib/bib.xml")/bib
return <wynik>
  {for $bk in $b/book
  return <ksiazka>
    <autor>{concat($bk/author/last/text()," ",$bk/author/first/text())}</autor>
    <tytul>{$bk/title/text()}</tytul>
  </ksiazka>}
</wynik>


(:10:)
for $b in doc("db/bib/bib.xml")/bib/book
where $b/title = "Data on the Web"
return <imiona>
  {for $a in $b/author
  return <imie>{$a/first/text()}</imie>}
</imiona>


(:11:)
<DataOnTheWeb>
  {doc("db/bib/bib.xml")/bib/book[title="Data on the Web"]}
</DataOnTheWeb>

for $b in doc("db/bib/bib.xml")/bib/book
where $b/title = "Data on the Web"
return <DataOnTheWeb>{$b}</DataOnTheWeb>


(:12:)
for $b in doc("db/bib/bib.xml")/bib/book
where contains($b/title, "Data")
return <Data>
  {for $a in $b/author
  return <nazwisko>{$a/last/text()}</nazwisko>}
</Data>


(:13:)
for $b in doc("db/bib/bib.xml")/bib/book
where contains($b/title, "Data")
return <Data>
  {$b/title}
  {for $a in $b/author
  return <nazwisko>{$a/last/text()}</nazwisko>}
</Data>


(:14:)
for $b in doc("db/bib/bib.xml")/bib/book
where count($b/author) < 3
return <ksiazka>
  {$b/title}
</ksiazka>


(:15:)
for $b in doc("db/bib/bib.xml")/bib/book
return <ksiazka>
  {$b/title}
  <autorow>{count($b/author)}</autorow>
</ksiazka>


(:16:)
let $p := for $b in doc("db/bib/bib.xml")/bib/book
  return $b/@year/number()
return <przedział>
  {concat(min($p), " - ",max($p))}
</przedział>


(:17:)
let $p := for $b in doc("db/bib/bib.xml")/bib/book
  return $b/price/number()
return <różnica>
  {max($p)-min($p)}
</różnica>


(:18:)
let $p := min(for $b in doc("db/bib/bib.xml")/bib/book
  return $b/price/number())
return <najtańsze>
  {for $b in doc("db/bib/bib.xml")/bib/book
  where $b/price = $p
  return <najtańsza>
    {$b/title}
    {$b/author}
  </najtańsza>}
</najtańsze>


(:19:)
let $sns := for $b in doc("db/bib/bib.xml")/bib/book
  return $b/author/last
return for $s in distinct-values($sns)
  return <autor>
    <last>{$s}</last>
    {doc("db/bib/bib.xml")/bib/book[author/last=$s]/title}
  </autor>


(:20:)
<wynik>
  {collection("db/shakespeare")/PLAY/TITLE}
</wynik>


(:21:)
for $p in collection("db/shakespeare")/PLAY
return <PLAY>
  {$p/TITLE}
  <LINES>
    {concat($p/ACT/SCENE/SPEECH/LINE)}
  </LINES>
</PLAY>[contains(LINES, "or not to be")]/TITLE


(:22:)
<wynik>
 {for $p in collection("db/shakespeare")/PLAY
  return <sztuka tytul="{$p/TITLE/text()}">
    <postaci>{count($p/PERSONAE/PERSONA) + count($p/PERSONAE/PGROUP/PERSONA)}</postaci>
    <aktow>{count($p/ACT)}</aktow>
    <scen>{count($p/ACT/SCENE)}</scen>
  </sztuka>}
</wynik>