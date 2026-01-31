for $k in doc('file:///D:/studia/st2_sem2/Zaawansowane Technologie Przetwarzania Danych/ztpd-lab/XPath-XSLT/swiat.xml')/SWIAT/KRAJE/KRAJ
(:where $k/starts-with(NAZWA, "A"):)
where $k/starts-with(NAZWA, $k/substring(STOLICA, 1, 1))
return <KRAJ>
{$k/NAZWA, $k/STOLICA}
</KRAJ>

(:doc('file:///D:/studia/st2_sem2/Zaawansowane Technologie Przetwarzania Danych/ztpd-lab/XPath-XSLT/swiat.xml')//KRAJ:)