<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %><%@ Register TagPrefix="eb" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %><%@ Page language="c#" AutoEventWireup="false" codePage="1200" %><HTML><HEAD><TITLE>Informacja do umowy</TITLE>
<META name=CODE_LANGUAGE content=C#>
<META name=vs_defaultClientScript content=JavaScript>
<META name=vs_targetSchema 
content=http://schemas.microsoft.com/intellisense/ie5>
    <style type="text/css">
        .auto-style1 {
            width: 55px;
        }
    </style>
</HEAD>
<BODY>
<FORM method=post runat="server">
<P align=center><ea:DataContext runat="server" ID="dc" TypeName="Soneta.Kadry.PracHistoria,Soneta.KadryPlace" PageSize=""></ea:DataContext><FONT 
size=4><STRONG>INFORMACJA</STRONG></FONT></P>
<P align=center><FONT size=4><STRONG><BR>do umowy zawartej w dniu <ea:DataLabel runat=server DataMember="Etat.DataZawarcia" EncodeHTML="True"></ea:DataLabel></STRONG></FONT></P>
<P>Pani/Pan :&nbsp;<ea:DataLabel runat=server DataMember="Imie" EncodeHTML="True"></ea:DataLabel>&nbsp;<ea:DataLabel runat=server DataMember="Nazwisko" EncodeHTML="True"></ea:DataLabel></P>
<P>Urodzona/y : <ea:DataLabel runat=server DataMember="Urodzony.Data" EncodeHTML="True"></ea:DataLabel>&nbsp;w&nbsp; <ea:DataLabel runat=server DataMember="Urodzony.Miejsce" EncodeHTML="True"></ea:DataLabel></P>
<P>zatrudniona/y na stanowisku&nbsp;: <ea:DataLabel runat=server DataMember="Etat.Stanowisko" EncodeHTML="True"></ea:DataLabel></P>
<P><BR><STRONG>Zgodnie z art.29 § 3 Kodeksu Pracy informuję, że:</STRONG></P>
<P>
<OL>
  <LI>Obowiązuje 8 godz. dobowa oraz 40 godz. tygodniowa norma czasu pracy. 
  <LI>Stosuje się system równoważnego czasu pracy, w którym jest dopuszczalne 
  przedłużenie dobowego wymiaru pracy, nie więcej jednak niż do 12 godzin, w 
  okresie rozliczeniowym wynoszącym 3 miesiące. Przedłużony dobowy wymiar czasu 
  pracy jest równoważony krótszym, dobowym wymiarem czasu pracy w niektórych 
  dniach lub dniami wolnymi od pracy. 
  <LI>Wypłata wynagrodzenia odbywa się 1 raz w miesiącu 
  <LI>Wymiar należnego urlopu wypoczynkowego wynosi 2 dni robocze za każdy 
  przepracowany miesiąc 
  <LI>Pora nocna liczona jest od godz. 22:00 do godz. 6:00 
  <LI>Wypłata dokonywana jest 10-tego następnego miesiąca przelewem bankowym na 
  konto wskazane przez pracownika. Jeżeli ustalony dzień wypłaty jest dniem 
  wolnym, wynagrodzenie wypłaca się w dniu poprzedzającym 
  <LI>Potwierdzenie przybycia do pracy dokonuje się przez wpisanie godziny 
  rozpoczęcia i zakończenia pracy na liście obecności i jej podpisaniu 
  <LI>Określenie sposobu usprawiedliwiania nieobecności w pracy. Pracownik 
  powinien uprzedzić pracodawcę o przyczynie i przewidywanym okresie 
  nieobecności w pracy, jeżeli przyczyna tej nieobecności jest z góry wiadoma 
  lub możliwa do przewidzenia. W razie zaistnienia przyczyn uniemożliwiających 
  stawienie się do pracy pracownik jest obowiązany niezwłocznie zawiadomić 
  pracodawcę o przyczynie swojej nieobecności i przewidywanym okresie jej 
  trwania, nie później jednak niż w drugim dniu nieobecności w pracy. 
  Zawiadomienia tego pracownik dokonuje osobiście lub przez inna osobę, 
  telefonicznie lub za pośrednictwem innego środka łączności. 
  <LI>Wyjścia służbowe i prywatne odbywają się za wiedza i zgoda bezpośredniego 
  przełożonego. </LI></OL>
<P></P>
<P>&nbsp;</P>
<P class=western 
style="MARGIN-BOTTOM: 0cm; MARGIN-LEFT: 0.66cm; LINE-HEIGHT: 150%" 
align=left>Otrzymałem dnia_______________________ Podpis 
Pracownika_______________________</P>
<P class=western 
style="MARGIN-BOTTOM: 0cm; MARGIN-LEFT: 0.66cm; LINE-HEIGHT: 150%" 
align=left>&nbsp;</P>
<P class=western style="MARGIN-BOTTOM: 0cm; MARGIN-LEFT: 0.66cm; LINE-HEIGHT: 150%" align=left><ea:PageBreak runat=server></ea:PageBreak></P>


<P class=western style="MARGIN-BOTTOM: 0cm; MARGIN-LEFT: 0.66cm; LINE-HEIGHT: 150%" align=left>&nbsp;</P>
<P dir=ltr><SPAN><U>Oświadczenie Pracownika Tymczasowego o dotychczasowym zatrudnieniu:</U></SPAN></P>
<P dir=ltr><SPAN>Pracownik Tymczasowy oświadcza, że w okresie 36 miesięcy poprzedzających zawarcie niniejszej umowy:</SPAN></P>
<TABLE style="WIDTH: auto; TABLE-LAYOUT: fixed; undefined: ">
    <TBODY>
        <tr>
            <td valign="top"><ea:CheckLabel runat=server></ea:CheckLabel></td>
            <td> <P class=western style="MARGIN-BOTTOM: 0cm; MARGIN-LEFT: 0.66cm; LINE-HEIGHT: 150%" align=left>
    Nie wykonywał pracy na rzecz Pracodawcy Użytkownika w związku z czym nie posiada zaświadczeń dokumentujących okres pracy tymczasowej 
    świadczonej na rzecz Pracodawcy użytkownika
</P> </td>
        </tr>
          </TBODY>
</TABLE>

        <TABLE style="WIDTH: auto; TABLE-LAYOUT: fixed; undefined: ">
    <TBODY>
         <tr>
            <td valign="top"><ea:CheckLabel runat=server></ea:CheckLabel></td>
            <td><P class=western style="MARGIN-BOTTOM: 0cm; MARGIN-LEFT: 0.66cm; LINE-HEIGHT: 150%" align=left>    
    Wykonywał na rzecz Pracodawcy Użytkownika pracę na podstawie umowy o pracę w wymiarze………………./umowy zlecenia w wymiarze………………………… 
    Na potwierdzenie powyższego przedkłada komplet zaświadczeń dokumentujących okres pracy tymczasowej świadczonej na rzecz Pracodawcy Użytkownika
</P>            </td>
        </tr>

    </TBODY>
</TABLE>

</P>   

<P><BR><STRONG>Informacja – kontakt z Agencją Pracy</STRONG></P>
    <ol>
        <li>Biuro agencji znajduje się przy ulicy Oleskiej 7 w Opolu, jest otwarte od poniedziałku do piątku, w godzinach od 8:00 do 16:00 z wyłączeniem dni ustawowo wolnych od pracy</li>
        <li>Adres email służący do kontaktu z agencją to: opole@paretti.pl</li>
        <li>Numer telefonu służący do kontaktu z agencją to: 77 544 99 99</li>
        <li>We wskazanych w pkt. 1 godzinach możliwy jest również kontakt telefoniczny z agencją oraz poprzez pocztę email</li>
    </ol>
    <p>
        &nbsp;</p>
</FORM>
<P class=western 
style="MARGIN-BOTTOM: 0cm; MARGIN-LEFT: 0.66cm; LINE-HEIGHT: 150%" 
align=left>data _______________________ Podpis 
Pracownika_______________________</P>
</BODY></HTML>
