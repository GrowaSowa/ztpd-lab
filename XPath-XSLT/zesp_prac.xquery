(:doc('file:///D:/studia/st2_sem2/Zaawansowane Technologie Przetwarzania Danych/ztpd-lab/XPath-XSLT/zesp_prac.xml'):)

(:for $z in doc('file:///D:/studia/st2_sem2/Zaawansowane Technologie Przetwarzania Danych/ztpd-lab/XPath-XSLT/zesp_prac.xml')/ZESPOLY/ROW:)
(:for $p in $z/PRACOWNICY/ROW:)
(:return $p/NAZWISKO:)

(:for $z in doc('file:///D:/studia/st2_sem2/Zaawansowane Technologie Przetwarzania Danych/ztpd-lab/XPath-XSLT/zesp_prac.xml')/ZESPOLY/ROW:)
(:where $z/NAZWA = "SYSTEMY EKSPERCKIE":)
(:for $p in $z/PRACOWNICY/ROW:)
(:return $p/NAZWISKO/text():)

(:for $z in doc('file:///D:/studia/st2_sem2/Zaawansowane Technologie Przetwarzania Danych/ztpd-lab/XPath-XSLT/zesp_prac.xml')/ZESPOLY/ROW:)
(:where $z/ID_ZESP = 10:)
(:return count($z/PRACOWNICY/ROW):)

(:for $z in doc('file:///D:/studia/st2_sem2/Zaawansowane Technologie Przetwarzania Danych/ztpd-lab/XPath-XSLT/zesp_prac.xml')/ZESPOLY/ROW:)
(:for $p in $z/PRACOWNICY/ROW:)
(:where $p/ID_SZEFA = 100:)
(:return $p/NAZWISKO:)

for $z in doc('file:///D:/studia/st2_sem2/Zaawansowane Technologie Przetwarzania Danych/ztpd-lab/XPath-XSLT/zesp_prac.xml')/ZESPOLY/ROW
where $z/ID_ZESP = (
    for $pr in $z/PRACOWNICY/ROW
    where $pr/NAZWISKO = "BRZEZINSKI"
    return $pr/ID_ZESP
)
for $p in $z/PRACOWNICY
return sum($p/ROW/PLACA_POD)
