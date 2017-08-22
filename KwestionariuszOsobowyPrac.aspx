<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %><%@ Register TagPrefix="eb" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %><%@ import Namespace="Soneta.Tools" %><%@ import Namespace="Soneta.Types" %><%@ import Namespace="Soneta.Business" %><%@ import Namespace="Soneta.Kadry" %><%@ import Namespace="Soneta.Place" %><%@ Import Namespace="Soneta.Core" %><%@ Page language="c#" AutoEventWireup="false" codePage="1200" %><HTML><HEAD><TITLE>Umowa_o_prace</TITLE>
<META name=CODE_LANGUAGE content=C#>
<SCRIPT runat="server">


    void dc_ContextLoad(object sender, EventArgs e) {

        PracHistoria ph = (PracHistoria)dc[typeof(PracHistoria)];

        DanePracownika(ph);


    }

    void DanePracownika(PracHistoria ph)
    {
        string adresZameldowaniaUlica = ph.AdresZameldowania.Ulica;
        string adresZameldowaniaNrDomu = ph.AdresZameldowania.NrDomu;
        string adresZameldowaniaNrLokalu = " ";
        string adresZamelodwaniakodPocztowy = ph.AdresZameldowania.KodPocztowyS;
        string adresZameldowaniaMiejscowosc = ph.AdresZameldowania.Miejscowosc;



        string adresDoKorespondencjiUlica = ph.AdresZamieszkania.Ulica;
        string adresDoKorespondencjiNrDomu = ph.AdresZamieszkania.NrDomu;
        string adresDoKorespondencjiNrLokalu = " ";
        string adresDoKorespondencjikodPocztowy = ph.AdresZamieszkania.KodPocztowyS;
        string adresDoKorespondencjiMiejscowosc = ph.AdresZamieszkania.Miejscowosc;

        if(ph.AdresZamieszkania.NrLokalu!="")
        {
            adresDoKorespondencjiNrLokalu = "/"+ph.AdresZamieszkania.NrLokalu;
        }
        if(ph.AdresZameldowania.NrLokalu!="")
        {
            adresZameldowaniaNrLokalu = "/"+ph.AdresZameldowania.NrLokalu;
        }

        if(adresDoKorespondencjiMiejscowosc!="" || adresDoKorespondencjiUlica!="" || adresDoKorespondencjikodPocztowy!="" )
        {
           // adres.EditValue = adresDoKorespondencjiUlica + " " +adresDoKorespondencjiNrDomu+adresDoKorespondencjiNrLokalu + ", " + adresDoKorespondencjikodPocztowy + " " + adresDoKorespondencjiMiejscowosc;
        }
        else
        {
          //  adres.EditValue = adresZameldowaniaUlica + " "+adresZameldowaniaNrDomu+adresZameldowaniaNrLokalu + ", " + adresZamelodwaniakodPocztowy + " " + adresZameldowaniaMiejscowosc;
        }

    }


    void Ankieta(Pracownik pr)
    {

        CheckLabel.EditValue = (bool)pr.Features["1"];
        CheckLabel1.EditValue = !((bool)pr.Features["1"]);

        CheckLabel2.EditValue = (bool)pr.Features["2"];
        CheckLabel3.EditValue = !((bool)pr.Features["2"]);

        CheckLabel4.EditValue = (bool)pr.Features["3"];
        CheckLabel5.EditValue = !((bool)pr.Features["3"]);

        CheckLabel6.EditValue = (bool)pr.Features["4"];
        CheckLabel7.EditValue = !((bool)pr.Features["4"]);

        CheckLabel8.EditValue = (bool)pr.Features["5"];
        CheckLabel9.EditValue = !((bool)pr.Features["5"]);

        CheckLabel10.EditValue = (bool)pr.Features["6"];
        CheckLabel11.EditValue = !((bool)pr.Features["6"]);

        CheckLabel12.EditValue = (bool)pr.Features["7"];
        CheckLabel13.EditValue = !((bool)pr.Features["7"]);


    }



    protected void Page_Load(object sender, EventArgs e)
    {

    }
</SCRIPT>

<META name=vs_defaultClientScript content=JavaScript>
<META name=vs_targetSchema 
content=http://schemas.microsoft.com/intellisense/ie5>
<STYLE type=text/css>
        .auto-style1 {
            width: 485px;
            table-layout: fixed;
        }
        .auto-style2 {
            width: 285px;
        }
        .auto-style3 {
            width: 248px;
        }
    </STYLE>
</HEAD>
<BODY>
<FORM method=post runat="server">
<P><ea:DataContext runat="server" ID="dc"  OnContextLoad="dc_ContextLoad" TypeName="Soneta.Kadry.PracHistoria,Soneta.KadryPlace" RightMargin="-1" PageSize=""></ea:DataContext></P>
<H1 class=western style="LINE-HEIGHT: 200%" align=center>KWESTIONARIUSZ OSOBOWY 
- Pracownik</H1>
<P class=western style="LINE-HEIGHT: 200%" align=center>Dla firmy PARETTI Sp. z 
o.o. sp.k. z siedzibą w Opolu, ul. Oleska 7, NIP: 7543074437, REGON: 
161544360</P>
<P class=western style="LINE-HEIGHT: 200%" align=center><STRONG>DANE 
PERSONALNE&nbsp;</STRONG></P>
<TABLE class=auto-style1 align=center>
  <COLGROUP>
  <COL>
  <COL style="WIDTH: 200px"></COLGROUP>
  <TBODY>
  <TR>
    <TD class=auto-style3>Nazwisko : <ea:DataLabel runat=server DataMember="Nazwisko" EncodeHTML="True"></ea:DataLabel></TD>
    <TD class=auto-style2>NIP : <ea:DataLabel runat=server DataMember="NIP" EncodeHTML="True"></ea:DataLabel></TD></TR>
  <TR>
    <TD class=auto-style3>Imię, imiona :&nbsp;<ea:DataLabel runat=server DataMember="Imie" EncodeHTML="True"></ea:DataLabel></TD>
    <TD class=auto-style2>NFZ (numer) : <ea:DataLabel runat=server DataMember="OddzialNFZ.Oddział.Nazwa" EncodeHTML="True"></ea:DataLabel></TD></TR>
  <TR>
    <TD class=auto-style3>Pesel : <ea:DataLabel runat=server DataMember="PESEL" EncodeHTML="True"></ea:DataLabel></TD>
    <TD class=auto-style2>email :</TD></TR>
  <TR>
    <TD class=auto-style3>
      <P>Nazwisko rodowe :&nbsp;<ea:DataLabel runat=server DataMember="NazwiskoRodowe" EncodeHTML="True"></ea:DataLabel> </P></TD>
    <TD class=auto-style2>telefon : </TD></TR>
  <TR>
    <TD class=auto-style3>Data urodzenia : <ea:DataLabel runat=server DataMember="Urodzony.Data" EncodeHTML="True"></ea:DataLabel></TD>
    <TD class=auto-style2></TD></TR>
  <TR>
    <TD class=auto-style3>Miejsce urodzenia : <ea:DataLabel runat=server DataMember="Urodzony.Miejsce" EncodeHTML="True"></ea:DataLabel></TD>
    <TD class=auto-style2></TD></TR>
  <TR>
    <TD class=auto-style3>Imię Ojca, Matki :<ea:DataLabel runat=server DataMember="ImieOjca" EncodeHTML="True"></ea:DataLabel>&nbsp;,<ea:DataLabel runat=server DataMember="ImieMatki" EncodeHTML="True"></ea:DataLabel> </TD>
    <TD class=auto-style2></TD></TR>
  <TR>
    <TD class=auto-style3>
      <P align=center><STRONG>Adres zameldowania</STRONG></P></TD>
    <TD class=auto-style2>
      <P align=center><STRONG>Adres do korespondecji</STRONG></P></TD></TR>
  <TR>
    <TD class=auto-style3>
      <P>ulica :&nbsp;&nbsp; <ea:DataLabel runat=server DataMember="AdresZameldowania.Ulica" EncodeHTML="True"></ea:DataLabel>&nbsp;<ea:DataLabel runat=server DataMember="AdresZameldowania.NrDomu" EncodeHTML="True"></ea:DataLabel>&nbsp;/ <ea:DataLabel runat=server DataMember="AdresZameldowania.NrLokalu" EncodeHTML="True"></ea:DataLabel></P></TD>
    <TD class=auto-style2>&nbsp;</TD></TR>
  <TR>
    <TD class=auto-style3>kod pocztowy : <ea:DataLabel runat=server DataMember="AdresZameldowania.KodPocztowy" EncodeHTML="True"></ea:DataLabel></TD>
    <TD class=auto-style2>
      <P>&nbsp;</P></TD></TR>
  <TR>
    <TD class=auto-style3>miejscowość : <ea:DataLabel runat=server DataMember="AdresZameldowania.Miejscowosc" EncodeHTML="True"></ea:DataLabel></TD>
    <TD class=auto-style2>&nbsp;</TD></TR></TBODY></TABLE>
<P class=western 
style="MARGIN-BOTTOM: 0cm; LINE-HEIGHT: 105%; MARGIN-RIGHT: 1.02cm"><FONT 
face="Tahoma, sans-serif"><FONT face="Times New Roman"></FONT>&nbsp;</P>
<P class=western style="MARGIN-BOTTOM: 0cm; LINE-HEIGHT: 150%"><FONT 
face="Tahoma, sans-serif"><B>Stan rodziny ( imiona i nazwiska oraz daty 
urodzenia dzieci) :</B></FONT></P>
<P class=western 
style="MARGIN-BOTTOM: 0cm; LINE-HEIGHT: 150%"><B>________________________________________________________________________________________________________</B></P>
<P class=western 
style="MARGIN-BOTTOM: 0cm; LINE-HEIGHT: 150%"><B>________________________________________________________________________________________________________</B></P>
<P class=western style="MARGIN-BOTTOM: 0cm; LINE-HEIGHT: 150%"><B>Powszechny 
obowiązek obrony:</B></P>
<OL type=a>
  <LI>
  <P class=western style="MARGIN-BOTTOM: 0cm; LINE-HEIGHT: 150%">Stosunek do 
  powszechnego obowiązku obrony____________________________________</P>
  <LI>
  <P class=western style="MARGIN-BOTTOM: 0cm; LINE-HEIGHT: 150%">Stopień 
  wojskowy___________________________________________________________</P></LI></OL>
<P class=western 
style="MARGIN-BOTTOM: 0cm; MARGIN-LEFT: 1.27cm; LINE-HEIGHT: 150%">Numer 
specjalności wojskowej________________________________________________</P>
<OL type=a start=3>
  <LI>
  <P class=western style="MARGIN-BOTTOM: 0cm; LINE-HEIGHT: 150%">Przynależność 
  ewidencyjna do WKU_____________________________________________</P>
  <LI>
  <P class=western style="MARGIN-BOTTOM: 0cm; LINE-HEIGHT: 150%">Numer 
  książeczki wojskowej___________________________________________________</P>
  <LI>
  <P class=western style="MARGIN-BOTTOM: 0cm; LINE-HEIGHT: 150%">Przydział 
  mobilizacyjny do sił zbrojnych 
  RP________________________________________</P></LI></OL>
<P class=western style="MARGIN-BOTTOM: 0cm; LINE-HEIGHT: 150%"><B>Osoba, którą 
należy zawiadomić w razie wypadku ( imię i nazwisko, adres, 
telefon</B>)_________________________________________________________________________________</P>
<P class=western style="MARGIN-BOTTOM: 0cm; LINE-HEIGHT: 150%"><ea:PageBreak runat=server></ea:PageBreak></P>
<P class=western style="MARGIN-BOTTOM: 0cm; LINE-HEIGHT: 150%">&nbsp;</P>
<TABLE style="WIDTH: auto; TABLE-LAYOUT: fixed; undefined: ">
  <COLGROUP>
  <COL style="WIDTH: 662px">
  <COL style="WIDTH: 42px">
  <COL style="WIDTH: 40px"></COLGROUP>
  <TBODY>
  <TR>
    <TD>
      <P>&nbsp;</P></TD>
    <TD>TAK</TD>
    <TD>NIE</TD></TR>
  <TR>
    <TD>- jestem zatrudniony(a) na podstawie umowy o pracę i osiągam 
      minimalne,wynagrodzenie :</TD>
    <TD vAlign=top><ea:CheckLabel runat=server ID ="CheckLabel"></ea:CheckLabel></TD>
    <TD vAlign=top><ea:CheckLabel runat=server ID ="CheckLabel1"></ea:CheckLabel></TD></TR>
  <TR>
    <TD>- jestem zatrudniony(a) na podstawie umowy zlecenie i osiągam 
      minimalne wynagrodzenie :</TD>
    <TD vAlign=top><ea:CheckLabel runat=server ID ="CheckLabel2"></ea:CheckLabel></TD>
    <TD vAlign=top><ea:CheckLabel runat=server ID ="CheckLabel3"></ea:CheckLabel></TD></TR>
  <TR>
    <TD>- prowadzę,własną działalność gospodarczą :</TD>
    <TD vAlign=top><ea:CheckLabel runat=server ID ="CheckLabel4"></ea:CheckLabel></TD>
    <TD vAlign=top><ea:CheckLabel runat=server ID ="CheckLabel5"></ea:CheckLabel></TD></TR>
  <TR>
    <TD>- jestem,studentem lub uczniem i nie przekroczyłem(am) 26 lat :</TD>
    <TD vAlign=top><ea:CheckLabel runat=server ID ="CheckLabel6"></ea:CheckLabel></TD>
    <TD vAlign=top><ea:CheckLabel runat=server ID ="CheckLabel7"></ea:CheckLabel></TD></TR>
  <TR>
    <TD>- jestem bezrobotny(a) :</TD>
    <TD vAlign=top><ea:CheckLabel runat=server ID ="CheckLabel8"></ea:CheckLabel></TD>
    <TD vAlign=top><ea:CheckLabel runat=server ID ="CheckLabel9"></ea:CheckLabel></TD></TR>
  <TR>
    <TD>- z,tej umowy chcę być objęty ubezpieczeniem emerytalnym i 
      rentowym,(zbieg tytułów ubezpieczeń) :</TD>
    <TD vAlign=top><ea:CheckLabel runat=server ID ="CheckLabel10"></ea:CheckLabel></TD>
    <TD vAlign=top><ea:CheckLabel runat=server ID ="CheckLabel11"></ea:CheckLabel></TD></TR>
  <TR>
    <TD>- z tytułu tej umowy chcę być objęty(a) ubezpieczeniem chorobowym :</TD>
    <TD vAlign=top><ea:CheckLabel runat=server ID ="CheckLabel12"></ea:CheckLabel></TD>
    <TD vAlign=top><ea:CheckLabel runat=server ID ="CheckLabel13"></ea:CheckLabel></TD></TR></TBODY></TABLE>
<P class=western 
style="MARGIN-BOTTOM: 0cm; MARGIN-LEFT: 0cm; LINE-HEIGHT: 150%; MARGIN-RIGHT: -0.24cm"><FONT 
face="Tahoma, sans-serif">Oświadczam, że dane zawarte w tym kwestionariusz są 
zgodne z prawdą oraz z <ea:DataLabel runat=server DataMember="Dokument.Rodzaj" EncodeHTML="True"></ea:DataLabel>&nbsp;</FONT></P>
<P class=western 
style="MARGIN-BOTTOM: 0cm; MARGIN-LEFT: 0cm; LINE-HEIGHT: 150%; MARGIN-RIGHT: -0.24cm"><FONT 
face="Tahoma, sans-serif">nr <ea:DataLabel runat=server DataMember="Dokument.SeriaNumer" EncodeHTML="True"></ea:DataLabel>&nbsp;wydanym przez <ea:DataLabel runat=server DataMember="Dokument.WydanyPrzez" EncodeHTML="True"></ea:DataLabel>&nbsp;</FONT></P>
<P class=western style="MARGIN-BOTTOM: 0cm; LINE-HEIGHT: 100%" 
align=left>&nbsp;</P>
<P class=western style="MARGIN-BOTTOM: 0cm; LINE-HEIGHT: 100%" align=left><FONT 
face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" 
size=2>...............................................&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;...............................................&nbsp;</FONT></FONT></P>
<P class=western style="MARGIN-BOTTOM: 0cm; LINE-HEIGHT: 100%" align=left><FONT 
face=Tahoma>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(miejscowośc i 
data)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
&nbsp;&nbsp;&nbsp;&nbsp; <FONT style="FONT-SIZE: 11pt" 
size=2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
(podis pracownika )&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
</FONT></FONT></P></FORM></FONT></BODY></HTML>
