<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %><%@ Register TagPrefix="eb" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %><%@ Page language="c#" AutoEventWireup="false" codePage="1200" %><HTML><HEAD><TITLE>Upowaznienie o wynagrodzeniu</TITLE>
<SCRIPT runat="server">
    void dc_ContextLoad(Object sender, EventArgs e)
    {
        Data.EditValue = DateTime.Now.ToString("dd-MM-yyyy");

    }



</SCRIPT>

<META name=CODE_LANGUAGE content=C#>
<META name=vs_defaultClientScript content=JavaScript>
<META name=vs_targetSchema 
content=http://schemas.microsoft.com/intellisense/ie5></HEAD>
<BODY>
<FORM method=post runat="server">
<P><ea:DataContext runat="server" ID="dc" TypeName="Soneta.Kadry.PracHistoria,Soneta.KadryPlace" OnContextLoad="dc_ContextLoad" RightMargin="-1" PageSize=""></ea:DataContext></P>
<TABLE width="100%">
  <TBODY>
  <TR>
    <TD align=left>
      <P><ea:DataLabel runat=server DataMember="Imie" EncodeHTML="True"></ea:DataLabel>&nbsp;<ea:DataLabel runat=server DataMember="Nazwisko" EncodeHTML="True"></ea:DataLabel>
      <br /><ea:DataLabel runat=server DataMember="AdresZameldowania.Ulica" EncodeHTML="True"></ea:DataLabel>&nbsp;<ea:DataLabel runat=server DataMember="AdresZameldowania.NrDomu" EncodeHTML="True"></ea:DataLabel>&nbsp;/ <ea:DataLabel runat=server DataMember="AdresZameldowania.NrLokalu" EncodeHTML="True"></ea:DataLabel>
      <br /><ea:DataLabel runat=server DataMember="AdresZameldowania.KodPocztowy" EncodeHTML="True"></ea:DataLabel>&nbsp;&nbsp;<ea:DataLabel runat=server DataMember="AdresZameldowania.Miejscowosc" EncodeHTML="True"></ea:DataLabel>
      </P>
      </TD>
    <TD align=right valign="top">Opole, <ea:DataLabel runat="server" EncodeHTML="True" ID="Data"></ea:DataLabel></TD></TR></TBODY></TABLE>
<P class=western style="LINE-HEIGHT: 150%" align=center><FONT 
face="Tahoma, serif"><FONT style="FONT-SIZE: 12pt" size=3><B>Upoważnienie do 
przekazywania wynagrodzenia </B></FONT></FONT></P>
<P class=western style="LINE-HEIGHT: 150%" align=center><FONT 
face="Tahoma, serif"><FONT style="FONT-SIZE: 12pt" size=3><B>na rachunek 
bankowy</B></FONT></FONT></P>
<P class=western style="LINE-HEIGHT: 150%"><BR></P>
<P class=western style="LINE-HEIGHT: 150%" align=justify><FONT 
face="Tahoma, serif"><FONT style="FONT-SIZE: 10pt" size=2>Wyrażam zgodę na 
przekazywanie mojego wynagrodzenia i innych świadczeń pieniężnych ze stosunku 
pracy w całości na rachunek bankowy:</FONT></FONT></P>
<P class=western style="LINE-HEIGHT: 150%"><FONT face="Tahoma, serif"><FONT 
style="FONT-SIZE: 10pt" size=2>W banku: <ea:DataLabel runat=server DataMember="Pracownik.DomyslnyRachunek.Rachunek.Bank.Nazwa" EncodeHTML="True"></ea:DataLabel></FONT></FONT></P>
<P class=western style="LINE-HEIGHT: 150%"><FONT face="Tahoma, serif"><FONT 
style="FONT-SIZE: 10pt" size=2>numer konta:&nbsp; <ea:DataLabel runat=server DataMember="Pracownik.DomyslnyRachunek.Rachunek.Numer.Pełny" EncodeHTML="True"></ea:DataLabel></FONT></FONT></P>
<P class=western style="LINE-HEIGHT: 150%"><A name=_GoBack></A><FONT 
face="Tahoma, serif"><FONT style="FONT-SIZE: 10pt" size=2>Jednocześnie 
zobowiązuję się do każdorazowego powiadomienia pracodawcy o zmianie numeru 
konta.</FONT></FONT></P>
   ................................................
                (podpis pracownika) 
<P>&nbsp;</P>
<P>&nbsp;</P>
<P>&nbsp;</P></FORM></BODY></HTML>
