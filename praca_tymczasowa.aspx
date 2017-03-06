<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %><%@ Register TagPrefix="eb" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %><%@ import Namespace="Soneta.Tools" %><%@ import Namespace="Soneta.Types" %><%@ import Namespace="Soneta.Business" %><%@ import Namespace="Soneta.Kadry" %><%@ import Namespace="Soneta.Place" %><%@ Import Namespace="Soneta.Core" %><%@ Page language="c#" AutoEventWireup="false" codePage="1200" %><HTML><HEAD><TITLE>Umowa_o_prace</TITLE>
<META name=CODE_LANGUAGE content=C#>
<SCRIPT runat="server">
    
    
    void dc_ContextLoading(object sender, EventArgs e) {

        



        data.EditValue = DateTime.Now.ToString("yyyy-MM-dd");





    }


</SCRIPT>

<META name=vs_defaultClientScript content=JavaScript>
<META name=vs_targetSchema 
content=http://schemas.microsoft.com/intellisense/ie5></HEAD>
<BODY>
<FORM method=post runat="server">
<P><ea:DataContext runat="server" ID="dc"  OnContextLoading="dc_ContextLoading" TypeName="Soneta.Kadry.PracHistoria,Soneta.KadryPlace" RightMargin="-1" PageSize=""></ea:DataContext></P>
<H1 class=western style="LINE-HEIGHT: 200%" align=center><FONT 
face="Tahoma, serif">Umowa o pracę tymczasową</FONT></H1>
<P class=western style="MARGIN-BOTTOM: 0cm; LINE-HEIGHT: 150%"><BR></P>
<P class=western style="MARGIN-BOTTOM: 0cm; LINE-HEIGHT: 150%"><FONT 
face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" size=2>Zawarta w 
</FONT></FONT><FONT face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" 
size=2><B>Opolu</B></FONT></FONT><FONT face="Tahoma, serif"><FONT 
style="FONT-SIZE: 11pt" size=2> w dniu <ea:DataLabel runat="server" EncodeHTML="True" ID="data"> </ea:DataLabel> 
</FONT></FONT><FONT face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" size=2>r. 
pomiędzy:</FONT></FONT></P>
<P class=western 
style="MARGIN-BOTTOM: 0cm; MARGIN-LEFT: 0.6cm; LINE-HEIGHT: 150%" 
align=left><FONT face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" 
size=2><B>PARETTi sp. z o.o.sp.k</B></FONT></FONT><FONT 
face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" size=2>., z siedzibą w 
</FONT></FONT><FONT face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" 
size=2><B>Opolu, ul. Oleska 7</B></FONT></FONT><FONT face="Tahoma, serif"><FONT 
style="FONT-SIZE: 11pt" size=2>, zwaną dalej Agencją, </FONT></FONT><FONT 
face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" size=2>a </FONT></FONT><FONT 
face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" 
size=2>Panią/Panem&nbsp;</FONT></FONT><FONT face="Tahoma, serif"><FONT 
style="FONT-SIZE: 11pt" size=2>&nbsp;<ea:DataLabel runat=server DataMember="Imie" EncodeHTML="True"></ea:DataLabel>&nbsp;<ea:DataLabel runat=server DataMember="Nazwisko" EncodeHTML="True"></ea:DataLabel>&nbsp;zam. w <ea:DataLabel runat=server DataMember="AdresZamieszkania.Miejscowosc" EncodeHTML="True"></ea:DataLabel></FONT></FONT><FONT 
face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" size=2><B>, ul.&nbsp;<ea:DataLabel runat=server DataMember="AdresZamieszkania.Ulica" EncodeHTML="True"></ea:DataLabel></B></FONT></FONT><FONT 
face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" size=2><ea:DataLabel runat=server DataMember="AdresZamieszkania.NrDomu" EncodeHTML="True"></ea:DataLabel>\<ea:DataLabel runat=server DataMember="AdresZamieszkania.NrLokalu" EncodeHTML="True"></ea:DataLabel>&nbsp;zwanym 
dalej Pracownikiem tymczasowym, </FONT></FONT><FONT face="Tahoma, serif"><FONT 
style="FONT-SIZE: 11pt" size=2>o treści następującej :</FONT></FONT></P>
<OL>
  <OL>
    <LI>
    <DIV align=left><FONT face=Tahoma>Agencja zatrudnia Pracownika tymczasowego 
    na czas określony w okresie od dnia&nbsp;<ea:DataLabel runat=server DataMember="Etat.Okres.From" EncodeHTML="True"></ea:DataLabel></FONT><FONT 
    face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" size=2> do dnia <ea:DataLabel runat=server DataMember="Etat.Okres.To" EncodeHTML="True"></ea:DataLabel></FONT></FONT><FONT 
    face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" size=2>r. w 
    wymiarze&nbsp;<ea:DataLabel runat=server DataMember="Etat.Zaszeregowanie.Wymiar" EncodeHTML="True"></ea:DataLabel>&nbsp;&nbsp;&nbsp;</FONT></FONT><FONT 
    face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" size=2>na stanowisku 
    <ea:DataLabel runat=server DataMember="Etat.Stanowisko" EncodeHTML="True"></ea:DataLabel>.</FONT></FONT></DIV>
    <LI>
    <P class=western style="MARGIN-BOTTOM: 0cm; LINE-HEIGHT: 150%" 
    align=left><FONT face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" 
    size=2>Pracownik tymczasowy zobowiązuje się wykonywać pracę na rzecz 
    Pracodawcy użytkownika&nbsp;<ea:DataLabel runat=server DataMember="Etat.Wydzial.Nazwa" EncodeHTML="True"></ea:DataLabel>&nbsp;&nbsp;</FONT></FONT><FONT 
    face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" size=2>w 
    </FONT></FONT><FONT face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" 
    size=2><B>______________________</B></FONT></FONT><FONT 
    face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" size=2> i pod jego 
    kierownictwem. </FONT></FONT><FONT face="Tahoma, serif"><FONT 
    style="FONT-SIZE: 11pt" size=2><B>Godziny pracy</B></FONT></FONT><FONT 
    face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" size=2>: 
    ________________________.</FONT></FONT></P>
    <LI>
    <P class=western style="MARGIN-BOTTOM: 0cm; LINE-HEIGHT: 150%" 
    align=left><FONT face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" 
    size=2>Za wykonaną pracę Pracownik tymczasowy będzie otrzymywał od Agencji 
    wynagrodzenie w wysokości <ea:DataLabel runat=server DataMember="Etat.Zaszeregowanie.Stawka" EncodeHTML="True"></ea:DataLabel></FONT></FONT><FONT 
    face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" size=2><B>&nbsp;brutto 
    miesięcznie</B></FONT></FONT><FONT face="Tahoma, serif"><FONT 
    style="FONT-SIZE: 11pt" size=2>, płatne przelewem </FONT></FONT><FONT 
    face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" size=2><B>dziesiątego 
    dnia następnego miesiąca kalendarzowego.</B></FONT></FONT></P>
    <LI>
    <P class=western style="MARGIN-BOTTOM: 0cm; LINE-HEIGHT: 150%" 
    align=left><FONT face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" 
    size=2>Każda ze stron może rozwiązać umowę za </FONT></FONT><FONT 
    face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" 
    size=2><B>jednotygodniowym</B></FONT></FONT><FONT face="Tahoma, serif"><FONT 
    style="FONT-SIZE: 11pt" size=2> wypowiedzeniem</FONT></FONT><FONT 
    face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" 
    size=2><I>.</I></FONT></FONT></P>
    <LI>
    <P class=western style="MARGIN-BOTTOM: 0cm; LINE-HEIGHT: 150%" 
    align=left><FONT face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" 
    size=2>Umowę sporządzono w trzech jednobrzmiących egzemplarzach (po jednym 
    dla Agencji, Pracownika tymczasowego i Pracodawcy 
    użytkownika).</FONT></FONT><FONT face="Tahoma, serif"><FONT 
    style="FONT-SIZE: 11pt" size=2>&nbsp;</FONT></FONT></P></LI></OL></OL>
<P class=western 
style="MARGIN-BOTTOM: 0cm; MARGIN-LEFT: 0.66cm; LINE-HEIGHT: 150%" 
align=left>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</P>
<P class=western 
style="MARGIN-BOTTOM: 0cm; MARGIN-LEFT: 0.66cm; LINE-HEIGHT: 150%" 
align=left>&nbsp;PODPIS 
PRACOWNIKA&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;PODPIS 
AGENCJI<FONT face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" 
size=2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
</FONT></FONT></P>
<P class=western style="MARGIN-BOTTOM: 0cm; LINE-HEIGHT: 100%" align=left><FONT 
face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" 
size=2></FONT></FONT>&nbsp;</P>
<P class=western style="MARGIN-BOTTOM: 0cm; LINE-HEIGHT: 100%" align=left><FONT 
face="Tahoma, serif"><FONT style="FONT-SIZE: 11pt" 
size=2>...............................................&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;...............................................&nbsp;</FONT></FONT></P>
<P class=western style="MARGIN-BOTTOM: 0cm; LINE-HEIGHT: 100%" align=left><FONT 
face=Tahoma>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(data 
i 
podpis)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
<FONT style="FONT-SIZE: 11pt" 
size=2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <FONT size=3>(data 
i podpis)&nbsp;</FONT>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
</FONT></FONT></P></FORM></BODY></HTML>
