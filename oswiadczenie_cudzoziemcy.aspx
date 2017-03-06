<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ Import Namespace="Soneta.Business" %>
<%@ Import Namespace="Soneta.Core" %>
<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %>
<%@ Register TagPrefix="eb" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %>
<%@ Import Namespace="Soneta.Kadry" %>
<%@ Import Namespace="Soneta.HR" %>
<%@ Import Namespace="Soneta.Tools" %><%@ Import Namespace="Soneta.Types" %>
<%@ Page language="c#" AutoEventWireup="false" codePage="1200" %>

<HTML><HEAD><TITLE>oswiadczenie o zatrudnienun cudzoziemca</TITLE>
<SCRIPT runat="server">

    void dc_ContextLoad(object sender, EventArgs e)
    {
        Pracownik pr = (Pracownik)dc[typeof(Pracownik)];

//   FeatureCollection fc = (FeatureCollection) dc[typeof(FeatureCollection)];



        WalidacjaUmowy(pr);
        DatyZatrudnieniaFunk(pr);


    }

    void WalidacjaUmowy(Pracownik pr)
    {
       
        // int[] tablica = new int[4];


        string value = "";

        string uop = "<s>umowa o pracę</s>";
        string uz = "<s>umowa zlecenie</s>";
        string ud = "<s>umowa o dzieło</s>";
        string inne = "<s>inne</s>";

        var  test = pr.Features["rodzajUmowy"];
        object uop1 = "umowa o pracę";

        if (test == uop1)
            uop = "umowa o pracę";


        value = uop + "/" + uz + "/" + ud + "/" + inne;

       

        rodzajUmowy.EditValue = test.ToString() ;

    }

    void DatyZatrudnieniaFunk(Pracownik pr)
    {
        string value = "";
        string od1 = pr.Features["okresPracy1od"].ToString();
        string do1 = pr.Features["okresPracy1do"].ToString();
        string od2 = pr.Features["okresPracy2od"].ToString();
        string do2 = pr.Features["okresPracy2do"].ToString();
        string od3 = pr.Features["okresPracy3od"].ToString();
        string do3 = pr.Features["okresPracy3do"].ToString();
        string od4 = pr.Features["okresPracy4od"].ToString();
        string do4 = pr.Features["okresPracy4do"].ToString();

        if(!(od1.IsNullOrEmpty()&& do1.IsNullOrEmpty()))
            value += "<strong>1</strong> od: " + od1 + " do: " + do1;

        if (!(od1.IsNullOrEmpty()&& do1.IsNullOrEmpty()))
            value += "<strong> 2</strong> od: " + od2 + " do: " + do2;

        if (!(od1.IsNullOrEmpty()&& do1.IsNullOrEmpty()))
            value += "<strong> 3</strong> od: " + od3 + " do: " + do3;

        if (!(od1.IsNullOrEmpty()&& do1.IsNullOrEmpty()))
            value += "<strong> 4</strong> od: " + od4 + " do: " + do4;

        DatyZatrudnienia.EditValue = value;
        stanowiskoLabel.EditValue = pr.Features["stanowisko"];
        rodzajPracyLabel.EditValue = pr.Features["rodzajPracy"];
        miejscePracyLabel.EditValue = pr.Features["miejscePracy"];
        wynagrodzenie.EditValue = pr.Features["wynagrodzenie"];
        miejsceStalegoZamieszkania.EditValue = pr.Features["panstwoObwodZamieszkania"];


    }




</SCRIPT>

<META name=CODE_LANGUAGE content=C#>
<META name=vs_defaultClientScript content=JavaScript>
<META name=vs_targetSchema 
content=http://schemas.microsoft.com/intellisense/ie5></HEAD>
<BODY>
<FORM method=post runat="server">
<ea:DataContext runat="server" ID="dc"   OnContextLoad="dc_ContextLoad" PageSize="" RightMargin="-1" TypeName="Soneta.Kadry.PracHistoria,Soneta.KadryPlace"></ea:DataContext>
<P align=right><EM><FONT size=1>Należy wypełnić czytelnie i wraz z kopią złożyć 
w powiatowym urzędzie pracy</FONT></EM></P>
<DIV style="FONT-SIZE: 12px" align=center><STRONG>OŚWIADCZENIE O ZAMIARZE 
POWIERZENIA WYKONYWANIA PRACY OBYWATELOWI REPUBLIKI ARMENII, REPUBLIKI 
BIAŁORUSI, REPUBLIKI GRUZJI, REPUBLIKI MOŁDAWII, FEDERACJI ROSYJSKIEJ LUB 
UKRAINY</STRONG></DIV>
<DIV style="FONT-SIZE: 11px; TEXT-ALIGN: center; PADDING-TOP: 0px">na warunkach 
określonych w § 1 pkt 20 rozporządzenia Ministra Pracy i Polityki Społecznej z 
dnia 21 kwietnia 2015 r. <BR>w sprawie przypadków, w których powierzenie 
wykonywania pracy cudzoziemcowi na terytorium Rzeczypospolitej Polskiej <BR>jest 
dopuszczalne bez konieczności uzyskania zezwolenia na pracę (poz. 588)</DIV>
<FORM method=post runat="server">
<DIV style="FONT-SIZE: 12px"><STRONG>Dane podmiotu powierzającego wykonywanie 
pracy : </STRONG><BR><S>imię i nazwisko</S> / nazwa* : <STRONG>PARETTi&nbsp; Sp 
Z O.O Spółka komandytowa <BR></STRONG><S>miejsce pobytu stałego</S>/siedziba* : 
<STRONG>Oleska 7, 45-052 Opole</STRONG> </DIV>
<TABLE style="FONT-SIZE: 12px; WIDTH: auto">
  <TBODY>
  <TR>
    <TD>tel.: &nbsp;&nbsp;&nbsp; +48 77 544 99 99&nbsp;&nbsp;&nbsp;&nbsp; </TD>
    <TD 
      style="TEXT-ALIGN: left">fax.:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
    </TD>
    <TD style="TEXT-ALIGN: left">NIP: 7543074437 </TD></TR>
  <TR>
    <TD><STRONG>PESEL :</STRONG></TD>
    <TD colSpan=2><STRONG>REGON : 161544360 </STRONG></TD></TR>
  <TR>
    <TD style="FONT-SIZE: 11px">(dotyczy osób fizycznych)</TD>
    <TD style="FONT-SIZE: 11px" colSpan=2>(dotyczy podmiotów podlegających 
      wpisowi do rejestru REGON)</TD></TR></TBODY></TABLE>
<TABLE style="FONT-SIZE: 12px; WIDTH: auto">
  <TBODY>
  <TR>
    <TD>w ramach sekcji Polskiej Klasyfikacji Działalności : 7820Z</TD></TR>
  <TR>
    <TD style="FONT-SIZE: 10px"><EM>(zgodnie z Polską Klasyfikacją 
      Działalności na poziomie podklasy – dostępną na stronie internetowej 
      www.stat.gov.pl)</EM></TD>
  <TR>
    <TD><FONT size=1>typ działalności*<EM>: działalność gospodarcza - 
      działalność rolnicza - nie prowadzi działalności gospodarczej ani 
      rolniczej</EM></FONT></TD></TR></TR></TBODY></TABLE>
<DIV style="FONT-SIZE: 12px"><STRONG>oświadcza, że zamierza powierzyć 
wykonywanie pracy przez okres(y) </STRONG>(należy podać daty rozpoczęcia i 
zakończenia pracy)<BR>
<ea:DataLabel runat="server" ID="DatyZatrudnienia" Bold="False"> </ea:DataLabel>

</DIV>
<DIV style="FONT-SIZE: 11px"><EM>Łączna długość okresów wykonywania pracy przez 
cudzoziemca bez zezwolenia na pracę w związku z jednym lub wieloma 
oświadczeniami, jednego lub wielu pracodawców nie może przekroczyć 6 miesięcy 
(180 dni) w ciągu kolejnych 12 miesięcy</EM></DIV>
<DIV style="FONT-SIZE: 12px">Zawód 
<ea:DataLabel runat="server" ID="stanowiskoLabel" Bold="True"> </ea:DataLabel> stanowisko/rodzaj 
wykonywanej pracy 
(opcjonalne) <ea:DataLabel runat="server" ID="rodzajPracyLabel" Bold="True"> </ea:DataLabel></DIV>
<DIV style="FONT-SIZE: 10px">(zawód wg grup elementarnych klasyfikacji zawodów i 
specjalności, dostępnej na stronie internetowej http://www.psz.praca.gov.pl/ w 
zakładce Klasyfikacja Zawodów)</DIV>
<DIV style="FONT-SIZE: 12px">miejsce wykonywania pracy (adres): <ea:DataLabel runat="server" ID="miejscePracyLabel" Bold="True"> </ea:DataLabel> 
<BR>rodzaj umowy na podstawie której ma być wykonywana praca*: 
<BR><EM> <ea:DataLabel runat="server" ID="rodzajUmowy" Bold="False"> </ea:DataLabel></EM>....................................................
    
     <BR>wysokość 
wynagrodzenia brutto (<EM>należy wpisać przewidywane miesięczne wynagrodzenie w 
PLN</EM>) : <ea:DataLabel runat="server" ID="wynagrodzenie" Bold="True"> </ea:DataLabel> <BR><STRONG>obywatelowi/obywatelce 
Republiki Armenii/Republiki Białorusi/Republiki Gruzji/Republiki 
Mołdawii/Federacji Rosyjskiej/Ukrainy* </STRONG><BR><EM>Panu/Pani*</EM> 
Imię/Imiona: <ea:DataLabel runat=server DataMember="Imie" EncodeHTML="True"></ea:DataLabel>&nbsp;Nazwisko: <ea:DataLabel runat=server DataMember="Nazwisko" EncodeHTML="True"></ea:DataLabel><BR>
<DIV style="FONT-SIZE: 11px"><EM>(zgodnie z pisownią alfabetem łacińskim w 
paszporcie)</EM></DIV>Data urodzenia : <ea:DataLabel runat=server DataMember="Urodzony.Data" EncodeHTML="True"></ea:DataLabel>&nbsp;Nr paszportu : <ea:DataLabel runat=server DataMember="Dokument.SeriaNumer" EncodeHTML="True"></ea:DataLabel><BR>Państwo, obwód i 
miejscowość stałego zamieszkania : <ea:DataLabel runat="server" ID="miejsceStalegoZamieszkania" Bold="True"> </ea:DataLabel><BR>Oświadczenie 
wydaję się*: </DIV>
<TABLE style="FONT-SIZE: 12px; WIDTH: auto">
  <TBODY>
  <TR>
    <TD colSpan=2>a) dla cudzoziemca, który będzie składał wniosek o wydanie 
      wizy w celu wykonywania pracy<BR>b) dla cudzoziemca, który będzie składał 
      wniosek o zezwolenie na pobyt czasowy</TD></TR>
  <TR>
    <TD vAlign=top>c) dla cudzoziemca przebywającego w Polsce : </TD>
    <TD>▪ na podstawie wizy w celu wykonywania pracy<BR>▪ na podstawie wizy 
      wydanej w innym celu, uprawniającej do wykonywania pracy<BR>▪ na podstawie 
      zezwolenia na pobyt czasowy<BR></TD></TR>
  <TR>
    <TD colSpan=2>d) dla cudzoziemca posiadającego inny tytuł pobytowy 
      (jaki?).................................................................................................</TD></TR></TBODY></TABLE>
<DIV style="FONT-SIZE: 12px">Nr wizy/karty 
pobytu*.......................................... okres ważności wizy/karty 
pobytu*: od........................do.......................<BR>Organ, który 
wydał wizę/kartę pobytu*: 
.........................................................................................................................................<BR><STRONG><BR>Ponadto 
oświadczam, że:</STRONG><BR>- zapoznałem/am się z przepisami prawnymi 
dotyczącymi pobytu i zatrudniania cudzoziemców w Polsce,<BR>-<EM> nie mam / 
podmiot, który reprezentuję nie ma*</EM> możliwości zaspokojenia potrzeb 
kadrowych w oparciu o lokalny rynek pracy. <BR>Podpis podmiot powierzający 
wykonywanie pracy (w tym osoba umocowana do reprezentowania podmiotu zgodnie z 
KRS).........................................................................<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; pełnomocnik 
.......................................................................<BR><EM>*niewłaściwe 
skreślić</EM> <BR>Rejestracja oświadczenia w Powiatowym Urzędzie Pracy (wypełnia 
PUP): <BR>W oparciu o: okazane dokumenty/wiedzę urzędu dokonano/nie dokonano 
weryfikacji faktu prowadzenia działalności / tożsamości podmiotu składającego 
oświadczenie (niewłaściwe skreślić). <BR>Zarejestrowano pod nr: 
................................................. <BR>Numer tel. rejestrującego: 
............................................. 
<TABLE style="FONT-SIZE: 12px; WIDTH: auto">
  <TBODY>
  <TR>
    <TD>Data i podpis: .......................................</TD>
    <TD></TD></TR>
  <TR>
    <TD style="FONT-SIZE: 11px"><EM>Rejestrując oświadczenie PUP zachowuje 
      jego kopię w ewidencji</EM></TD>
    <TD 
      style="FONT-SIZE: 11px; TEXT-ALIGN: center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
      (pieczątka PUP)</TD></TR></TBODY></TABLE><SPAN 
style="FONT-SIZE: 11px"><EM>Uwaga: Do oświadczenia powinno być dołączone 
podpisane pouczenie prawne, najlepiej wydrukowane na odwrocie </EM></SPAN></DIV>
<P><ea:PageBreak runat=server></ea:PageBreak></P>&nbsp;
<P align=center><STRONG>POUCZENIE DLA PODMIOTU SKŁADAJĄCEGO OŚWIADCZENIE<BR>O 
ZAMIARZE POWIERZENIA WYKONYWANIA PRACY CUDZOZIEMCOWI</STRONG></P>
<OL style="FONT-SIZE: 12px">
  <LI>
  <DIV align=justify>Oświadczenie musi być zarejestrowane przed podjęciem pracy 
  przez cudzoziemca (najpóźniej w dniu poprzedzającym dzień rozpoczęcia pracy 
  przez cudzoziemca). </DIV>
  <LI>
  <DIV align=justify>Łączny okres wykonywania pracy przez danego cudzoziemca na 
  podstawie oświadczenia nie może przekraczać 6 miesięcy w ciągu kolejnych 12 
  miesięcy, niezależnie od liczby zarejestrowanych oświadczeń i liczby podmiotów 
  powierzających wykonywanie pracy. </DIV>
  <LI>
  <DIV align=justify>Podmiot zamierzający powierzyć pracę cudzoziemcowi na okres 
  dłuższy niż 6 miesięcy w ciągu kolejnych 12 miesięcy powinien złożyć wniosek o 
  wydanie dla tego cudzoziemca zezwolenia na pracę. Jeżeli cudzoziemiec był 
  poprzednio zatrudniony u&nbsp;wnioskodawcy na podstawie oświadczenia przez 
  okres powyżej 3 miesięcy na takim samym stanowisku jak we wniosku o wydanie 
  zezwolenia, zezwolenie jest wydawane w&nbsp;trybie uproszczonym (bez 
  informacji starosty) pod warunkiem przedstawienia zarejestrowanego 
  oświadczenia, umowy uwzględniającej warunki zadeklarowane w&nbsp;oświadczeniu 
  oraz dokumentów potwierdzających opłacanie składek na ubezpieczenie społeczne 
  (jeżeli były wymagane). </DIV>
  <LI>
  <DIV align=justify>Złożenie oświadczenia niezgodnego z rzeczywistym zamiarem 
  może powodować odpowiedzialność karną za współudział w&nbsp;przestępstwie 
  wyłudzenia wizy. </DIV>
  <LI>
  <DIV align=justify>Żądanie korzyści majątkowej w zamian za wystawienie 
  oświadczenia jest wykroczeniem i podlega karze grzywny nie niższej niż 3000 
  zł. </DIV>
  <LI>
  <DIV align=justify>Cudzoziemiec wymieniony w oświadczeniu może wykonywać pracę 
  w Polsce tylko wtedy, gdy uzyska tytuł pobytowy uprawniający do wykonywania 
  pracy – są to: </DIV>
  <OL>
    <LI>
    <DIV align=justify>wiza (z wyjątkiem wizy turystycznej oraz wiz wydanych na 
    podstawie art. 60 ust. 1 pkt 22 i 23 ustawy o cudzoziemcach), </DIV>
    <LI>
    <DIV align=justify>zezwolenie na pobyt czasowy (z wyjątkiem zezwolenia 
    udzielonego na podstawie art. 181 ust. 1 ustawy o cudzoziemcach), </DIV>
    <LI>
    <DIV align=justify>wiza lub dokument pobytowy wydane przez inne państwo 
    obszaru Schengen, </DIV>
    <LI>
    <DIV align=justify>pobyt na podstawie art. 108 ust. 1 pkt 2 lub art. 206 
    ust. 1 pkt 2 ustawy o cudzoziemcach lub na podstawie umieszczonego 
    w&nbsp;dokumencie podróży odcisku stempla, który potwierdza złożenie wniosku 
    o udzielenie zezwolenia na pobyt rezydenta długoterminowego Unii 
    Europejskiej, jeżeli cudzoziemiec bezpośrednio przed złożeniem wniosku o 
    udzielenie zezwolenia na zamieszkanie był uprawniony do wykonywania pracy w 
    Polsce. </DIV></LI></OL>
  <LI>
  <DIV align=justify>Zarejestrowane oświadczenie może być podstawą do ubiegania 
  się przez cudzoziemca o wizę w celu wykonywania pracy w okresie 
  nieprzekraczającym 6 miesięcy w ciągu kolejnych 12 miesięcy (wiza „05”) lub 
  zezwolenia na pobyt czasowy, jeżeli przebywa on już w Polsce. </DIV>
  <LI>
  <DIV align=justify>Podmiot powierzający wykonywanie pracy cudzoziemcowi jest 
  obowiązany żądać od niego przedstawienia przed rozpoczęciem pracy ważnego 
  dokumentu uprawniającego do pobytu w Polsce i przechowywać kopię tego 
  dokumentu przez cały okres wykonywania pracy. </DIV>
  <LI>
  <DIV align=justify>Powierzenie wykonywania pracy cudzoziemcowi przebywającemu 
  nielegalnie w Polsce jest wykroczeniem karanym grzywną nie niższą niż 3000 zł, 
  a w niektórych przypadkach – przestępstwem. Ponadto podmiot powierzający 
  wykonywanie pracy cudzoziemcowi przebywającemu nielegalnie w Polsce zostaje 
  wykluczony z ubiegania się o udzielenie zamówienia publicznego przez 1 rok, 
  może także zostać pozbawiony dostępu do niektórych środków europejskich oraz 
  obowiązany do zapłaty równowartości takich środków otrzymanych w okresie 12 
  miesięcy poprzedzających wydanie wyroku. </DIV>
  <LI>
  <DIV align=justify>Podmiot powierzający wykonywanie pracy cudzoziemcowi 
  obowiązany jest zawrzeć z cudzoziemcem umowę na piśmie, uwzględniającą warunki 
  zadeklarowane w oświadczeniu. Niezawarcie umowy w formie pisemnej jest 
  wykroczeniem i podlega karze grzywny nie niższej niż 3000 zł. </DIV>
  <LI>
  <DIV align=justify>Umowa zawarta z cudzoziemcem musi być zgodna z 
  zarejestrowanym oświadczeniem. Praca cudzoziemca na warunkach innych niż 
  określone w oświadczeniu jest wykonywana nielegalnie i skutkuje karą grzywny 
  (dla podmiotu powierzającego cudzoziemcowi wykonywanie pracy – nie niższą niż 
  3000 zł, dla cudzoziemca – nie niższą niż 1000 zł). </DIV>
  <LI>
  <DIV align=justify>Podmiot powierzający wykonywanie pracy cudzoziemcowi 
  obowiązany jest przestrzegać wszystkich przepisów odnośnie zatrudnienia lub 
  innego stosunku prawnego będącego podstawą wykonywania pracy, w szczególności 
  zakazu dyskryminacji ze względu na narodowość lub obywatelstwo. Naruszanie 
  przepisów prawa pracy (m.in. zawarcie umowy cywilnoprawnej w warunkach, 
  w&nbsp;których powinna być zawarta umowa o pracę, naruszanie przepisów o 
  czasie pracy lub bhp, niewypłacanie wynagrodzenia) jest wykroczeniem 
  zagrożonym karą grzywny w&nbsp;wysokości od 1000 do 30000 zł. </DIV>
  <LI>
  <DIV align=justify>Doprowadzenie cudzoziemca do nielegalnego wykonywania pracy 
  (lub doprowadzenie innej osoby do powierzenia cudzoziemcowi nielegalnego 
  wykonywania pracy) za pomocą wprowadzenia w błąd, wyzyskania błędu, 
  wykorzystania zależności służbowej lub niezdolności do należytego pojmowania 
  przedsiębranego działania jest wykroczeniem zagrożonym karą grzywny do 10000 
  zł. </DIV>
  <LI>
  <DIV align=justify>Podmiot zawierający z cudzoziemcem umowę o pracę lub umowę 
  cywilnoprawną objętą obowiązkiem odprowadzania składek na ubezpieczenie 
  społeczne (umowa agencyjna, umowa zlecenia albo inna umowa o świadczenie 
  usług, do której zgodnie z kodeksem cywilnym stosuje się przepisy dotyczące 
  zlecenia) jest obowiązany do zgłoszenia tego cudzoziemca do ubezpieczenia 
  społecznego w&nbsp;terminie 7 dni od rozpoczęcia pracy oraz comiesięcznego 
  odprowadzania za tę osobę składek w należnej wysokości. Niedopełnienie tych 
  obowiązków skutkuje sankcjami administracyjnymi (dodatkowa opłata, odsetki) 
  lub karą grzywny. </DIV>
  <LI>
  <DIV align=justify>Podmiot powierzający cudzoziemcowi wykonywanie pracy na 
  podstawie umowy o pracę (a także na podstawie umowy cywilnoprawnej, jeżeli 
  podmiotem tym jest osoba prawna lub osoba fizyczna prowadząca działalność 
  gospodarczą) jest obowiązany odprowadzać z tytułu tej umowy zaliczki na 
  podatek dochodowy od osób fizycznych lub zryczałtowany podatek dochodowy, 
  chyba że odpowiednia umowa międzynarodowa o&nbsp;unikaniu podwójnego 
  opodatkowania stanowi inaczej. Niedopełnienie tych obowiązków skutkuje 
  sankcjami administracyjnymi (odsetki) i&nbsp;jednocześnie stanowi przestępstwo 
  lub wykroczenie skarbowe. </DIV></LI></OL>
<P><EM><FONT size=2>Oświadczam, że zapoznałem/zapoznałam się z powyższym 
pouczeniem.</FONT></EM></P>
<TABLE style="WIDTH: auto">
  <TBODY>
  <TR>
    <TD style="WIDTH: auto">________________________________</TD>
    <TD style="WIDTH: auto">&nbsp; ___________________</TD>
    <TD style="WIDTH: auto">&nbsp; _______________________________</TD></TR>
  <TR>
    <TD>
      <P align=center><FONT size=1>Nazwa podmiotu lub imię i nazwisko osoby 
      fizycznej</FONT></P></TD>
    <TD>
      <P align=center><FONT size=1>Miejscowość i data</FONT></P></TD>
    <TD>
      <P align=center><FONT size=1>Podpis składającego oświadczenie/osoby 
      <BR>upoważnionej do reprezentacji 
podmiotu</FONT></P></TD></TR></TBODY></TABLE><BR><BR><STRONG>Podstawy prawne 
:</STRONG> 
<OL style="FONT-SIZE: 10px">
  <LI>§ 1 pkt 20 rozporządzenia Ministra Pracy i Polityki Społecznej z dnia 21 
  kwietnia 2015 r. w sprawie przypadków, w których powierzenie wykonywania pracy 
  cudzoziemcowi na terytorium Rzeczypospolitej Polskiej jest dopuszczalne bez 
  konieczności uzyskania zezwolenia na pracę (Dz. U. z&nbsp;2015 r., poz. 588); 
  <LI>Art. 264 § 3, art. 264a § 1 i art. 272 ustawy z dnia Kodeks karny (Dz. U. 
  z 1997 r., Nr 88, poz. 553 z późn. zm.); 
  <LI>Art. 60 ust. 1 pkt 5 i art. 64 ust. 3 ustawy z dnia 12 grudnia 2013 r. o 
  cudzoziemcach (Dz. U. z 2013 r., poz. 1650 z późn. zm.); 
  <LI>Art. 9, 10, 11 i 12 ustawy z dnia 15 czerwca 2012 r. o skutkach 
  powierzania wykonywania pracy cudzoziemcom przebywającym wbrew przepisom na 
  terytorium Rzeczypospolitej Polskiej (Dz. U. z 2012 r., poz. 769); 
  <LI>Art. 24 ust. 1 pkt 10 i 11 ustawy z dnia z dnia 29 stycznia 2004 r. Prawo 
  zamówień publicznych (t.j.: Dz. U. z 2013 r., poz. 907 z późn. zm.); 
  <LI>Art. 120 ustawy z dnia 20 kwietnia 2004 r. o promocji zatrudnienia i 
  instytucjach rynku pracy (t.j.: Dz. U. z 2015 r., poz. 149 z późn. zm.); 
  <LI>Art. 24 ust. 1a-1d oraz art. 98 ustawy z dnia 13 października 1998 r. o 
  systemie ubezpieczeń społecznych (t.j.: Dz. U. z 2015 r., poz. 121); 
  <LI>Art. 13, 31 i 41 ustawy z 26 lipca 1991 r. o podatku dochodowym od osób 
  fizycznych (t.j.: Dz. U. z 2012 r., poz. 361 z późn. zm.). </LI></OL>
<P></P></FORM></FORM>
</BODY></HTML>
