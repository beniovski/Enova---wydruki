<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ import Namespace="Soneta.Kadry" %><%@ import Namespace="Soneta.Place" %><%@ import Namespace="Soneta.Kadry" %><%@ import Namespace="Soneta.KadryPlace" %><%@ import Namespace="Soneta.Core" %><%@ import Namespace="Soneta.Tools" %><%@ import Namespace="Soneta.Types" %><%@ import Namespace="Soneta.Kalend" %><%@ import Namespace="Soneta.Business" %><%@ import Namespace="System.ComponentModel" %><%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %><%@ Register TagPrefix="eb" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %><%@ Page language="c#" AutoEventWireup="false" codePage="1200" %><HTML><HEAD><TITLE>UmowaParetti</TITLE>
<script runat=server>
// <![CDATA[
// <![CDATA[

  
	static int umowaID = 0;

	void dc_ContextLoading(object sender, EventArgs e) {
		try {
			if (Request.QueryString.Get("UmowaID") != string.Empty)
				umowaID = Convert.ToInt32(Request.QueryString.Get("UmowaID"));
		}
		catch { }
		if (umowaID != 0) {
			KadryModule km = KadryModule.GetInstance(dc);
			UmowaHistoria uh = km.UmowaHistorie[umowaID];
			if (uh != null) {
				dc.Context[typeof(UmowaHistoria)] = uh;
				dc.Context[typeof(Umowa)] = uh.Umowa;
			}
		}
	}

	void dc_ContextLoad(object sender, EventArgs e) {


		UmowaHistoria umowaHist = (UmowaHistoria)dc[typeof(UmowaHistoria)];
		Umowa umowa = umowaHist.Umowa;
		PracHistoria ph = umowa.PracHistoria;
		Pracownik pr = umowa.Pracownik;

	 
		Ankieta(pr);
		DanePracownika(ph);
	  //  data.EditValue = DateTime.Now.ToString("yyyy-MM-dd");


	}

	void DanePracownika(PracHistoria ph)
	{
		string imie = ph.Imie;
		string nazwisko = ph.Nazwisko;

		string adresDoKorespondencjiUlica = ph.AdresZamieszkania.Ulica;
		string adresDoKorespondencjiNrDomu = ph.AdresZamieszkania.NrDomu;
		string adresDoKorespondencjiNrLokalu = " ";
		string adresZameldowaniaNrLokalu = " ";

		string adresDoKorespondencjikodPocztowy = ph.AdresZamieszkania.KodPocztowyS;
		string adresDoKorespondencjiMiejscowosc = ph.AdresZamieszkania.Miejscowosc;

		 if(ph.AdresZamieszkania.NrLokalu!="")
		{
		  adresDoKorespondencjiNrLokalu = "/"+ph.AdresZamieszkania.NrLokalu;
		}
		 if(ph.AdresZameldowania.NrLokalu!="")
		{
		   AdresZameldowaniaNrLokalu.EditValue = "/"+ph.AdresZameldowania.NrLokalu;
		}



		if(adresDoKorespondencjiUlica=="" || adresDoKorespondencjikodPocztowy=="" || adresDoKorespondencjiMiejscowosc =="")
		{
			AdresKorespondencji.Visible = false;
			AdresKorespondencjiUlica.Visible = false;
			AdresKorespondencjiKodPocztowy.Visible = false;
			AdresKorespondencjiMiejscowosc.Visible = false;
		}

		AdresKorespondencji.EditValue = "Adres korespondencji";
		AdresKorespondencjiMiejscowosc.EditValue = "miejscowość : " + adresDoKorespondencjiMiejscowosc;
		AdresKorespondencjiKodPocztowy.EditValue = "kod pocztowy : " + adresDoKorespondencjikodPocztowy;
		AdresKorespondencjiUlica.EditValue = "ulica : " + adresDoKorespondencjiUlica + " " + adresDoKorespondencjiNrDomu +adresDoKorespondencjiNrLokalu;  

	  




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



// ]]>
// ]]>
</script>

<META name=CODE_LANGUAGE content=C#>
<META name=vs_defaultClientScript content=JavaScript>
<META name=vs_targetSchema 
content=http://schemas.microsoft.com/intellisense/ie5></HEAD>
<BODY>
<FORM method=post runat="server">
<P><ea:DataContext runat="server" OnContextLoading="dc_ContextLoading" OnContextLoad="dc_ContextLoad" TypeName="Soneta.Kadry.Umowa,Soneta.KadryPlace" RightMargin="-2" PageSize="" ID="dc"></ea:DataContext></P>
<P class=auto-style1 align=center style:=" text-align:center"><FONT 
size=6><STRONG>Umowa zlecenia nr <ea:DataLabel runat="server" DataMember="Numer.Pelny" EncodeHTML="True" ID="NumerPelny"></ea:DataLabel></STRONG></FONT></P>
<P class=auto-style1 align=justify style:=" text-align:center">Zawarta w 
dniu&nbsp;<ea:DataLabel runat=server DataMember="Last.Umowa.Data" EncodeHTML="True"></ea:DataLabel> w Opolu pomiędzy firmą 
<STRONG>PARETTI &nbsp;Sp. z o.o. sp.k. z siedzibą w Opolu, ul. Oleska 7, NIP: 
7543074437, REGON: 161544360</STRONG>, zwanym dalej Zleceniodawcą, a:</P>
<TABLE style="WIDTH: 485px; TABLE-LAYOUT: fixed; undefined: " align=center>
  <COLGROUP>
  <COL style="WIDTH: 285px">
  <COL style="WIDTH: 200px"></COLGROUP>
  <TBODY>
  <TR>
    <TD>Nazwisko : <ea:DataLabel runat=server DataMember="PracHistoria.Nazwisko" EncodeHTML="True"></ea:DataLabel></TD>
    <TD>Pesel : <ea:DataLabel runat="server" DataMember="PracHistoria.PESEL" EncodeHTML="True" ID="Pesel"></ea:DataLabel></TD></TR>
  <TR>
    <TD>Imię :&nbsp;<ea:DataLabel runat="server" DataMember="PracHistoria.Imie" EncodeHTML="True" ID="Imie"></ea:DataLabel></TD>
    <TD>NIP : <ea:DataLabel runat="server" DataMember="PracHistoria.NIP" EncodeHTML="True" ID="Nip"></ea:DataLabel></TD></TR>
  <TR>
    <TD>Nazwisko rodowe : <ea:DataLabel runat="server" DataMember="PracHistoria.NazwiskoRodowe" EncodeHTML="True" ID="NazwiskoRodowe"></ea:DataLabel></TD>
    <TD><ea:DataLabel runat=server DataMember="PracHistoria.Dokument.Rodzaj" EncodeHTML="True"></ea:DataLabel>: <ea:DataLabel runat="server" DataMember="PracHistoria.Dokument.SeriaNumer" EncodeHTML="True" ID="DokumentNr"></ea:DataLabel> 
  <TR>
    <TD>
      <P>Uczelnia : </P></TD>
    <TD>NFZ (numer) : <ea:DataLabel runat="server" DataMember="Last.Umowa.PracHistoria.OddzialNFZ.Kod" EncodeHTML="True" ID="OddzialNfz"></ea:DataLabel></TD></TR>
  <TR>
    <TD>Data urodzenia : <ea:DataLabel runat="server" DataMember="PracHistoria.Urodzony.Data" EncodeHTML="True" ID="DataUrodzenia"></ea:DataLabel></TD>
    <TD>Urząd Skarbowy : <ea:DataLabel runat=server DataMember="PracHistoria.Podatki.UrzadSkarbowy.Nazwa" EncodeHTML="True"></ea:DataLabel></TD></TR>
  <TR>
    <TD>Miejsce urodzenia : <ea:DataLabel runat="server" DataMember="PracHistoria.Urodzony.Miejsce" EncodeHTML="True" ID="MiejsceUrodzenia"></ea:DataLabel></TD>
    <TD>email : </TD></TR>
  <TR>
    <TD>Imię Ojca, Matki :<ea:DataLabel runat="server" DataMember="PracHistoria.ImieOjca" EncodeHTML="True" ID="ImieOjca"></ea:DataLabel>&nbsp;,<ea:DataLabel runat="server" DataMember="PracHistoria.ImieMatki" EncodeHTML="True" ID="ImieMatki"></ea:DataLabel> </TD>
    <TD>telefon : <ea:DataLabel runat=server DataMember="PracHistoria.AdresZameldowania.Telefon" EncodeHTML="True"></ea:DataLabel></TD></TR>
  <TR>
    <TD>
      <P align=left><STRONG>Adres zameldowania</STRONG></P></TD>
    <TD><STRONG>
      <P align=center><ea:DataLabel runat="server" EncodeHTML="True" ID="AdresKorespondencji"></ea:DataLabel> 
</STRONG></P></TD></TR>
  <TR>
    <TD>ulica : <ea:DataLabel runat="server" DataMember="PracHistoria.AdresZameldowania.Ulica" EncodeHTML="True" ID="AdresZameldowaniaUlica"></ea:DataLabel>&nbsp; 
      <ea:DataLabel runat="server" DataMember="PracHistoria.AdresZameldowania.NrDomu" EncodeHTML="True" ID="AderesZameldowaniaNrDomu"></ea:DataLabel><ea:DataLabel runat="server" EncodeHTML="True" ID="AdresZameldowaniaNrLokalu"></ea:DataLabel></TD>
    <TD><ea:DataLabel runat="server" EncodeHTML="True" ID="AdresKorespondencjiUlica"></ea:DataLabel> </TD></TR>
  <TR>
    <TD>kod pocztowy : <ea:DataLabel runat="server" DataMember="PracHistoria.AdresZameldowania.KodPocztowy" EncodeHTML="True" ID="AdresZameldowaniaKodPocztowy"></ea:DataLabel></TD>
    <TD>
      <P><ea:DataLabel runat="server" EncodeHTML="True" ID="AdresKorespondencjiKodPocztowy"></ea:DataLabel></P></TD></TR>
  <TR>
    <TD>miejscowość : <ea:DataLabel runat="server" DataMember="Pracownik.Workers.Info.Historia.AdresZameldowania.Miejscowosc" EncodeHTML="True" ID="AdresZameldowaniaMiejscowosc"></ea:DataLabel></TD>
    <TD><ea:DataLabel runat="server" EncodeHTML="True" ID="AdresKorespondencjiMiejscowosc"></ea:DataLabel></TD></TR></TBODY></TABLE>
<P><FONT face="Tahoma, sans-serif"></FONT>&nbsp;<FONT 
face="Tahoma, sans-serif">Nr Konta Bankowego: <ea:DataLabel runat=server DataMember="Pracownik.EtatGłówny.Rachunki" EncodeHTML="True"></ea:DataLabel></P></FONT>
<P class=western><FONT face="Tahoma, sans-serif">Zwanym dalej 
Zleceniobiorcą.</FONT></P>
<P class=western>1. Zleceniobiorca oświadcza, co następuje</P>
<P>
<TABLE style="WIDTH: auto; TABLE-LAYOUT: fixed; undefined: ">
  <COLGROUP>
  <COL style="WIDTH: 662px">
  <COL style="WIDTH: 42px">
  <COL style="WIDTH: 40px"></COLGROUP>
  <TBODY>
  <TR>
    <TD></TD>
    <TD>TAK</TD>
    <TD>NIE</TD></TR>
  <TR>
    <TD>- jestem zatrudniony(a) na podstawie umowy o pracę i osiągam 
      minimalne,wynagrodzenie :</TD>
    <TD><ea:CheckLabel runat=server ID ="CheckLabel"></ea:CheckLabel></TD>
    <TD><ea:CheckLabel runat=server ID ="CheckLabel1"></ea:CheckLabel></TD></TR>
  <TR>
    <TD>- jestem zatrudniony(a) na podstawie umowy zlecenie i osiągam 
      minimalne wynagrodzenie</TD>
    <TD><ea:CheckLabel runat=server ID ="CheckLabel2"></ea:CheckLabel></TD>
    <TD><ea:CheckLabel runat=server ID ="CheckLabel3"></ea:CheckLabel></TD></TR>
  <TR>
    <TD>- prowadzę,własną działalność gospodarczą</TD>
    <TD><ea:CheckLabel runat=server ID ="CheckLabel4"></ea:CheckLabel></TD>
    <TD><ea:CheckLabel runat=server ID ="CheckLabel5"></ea:CheckLabel></TD></TR>
  <TR>
    <TD>- jestem,studentem lub uczniem i nie przekroczyłem(am) 26 lat</TD>
    <TD><ea:CheckLabel runat=server ID ="CheckLabel6"></ea:CheckLabel></TD>
    <TD><ea:CheckLabel runat=server ID ="CheckLabel7"></ea:CheckLabel></TD></TR>
  <TR>
    <TD>- jestem bezrobotny(a)</TD>
    <TD><ea:CheckLabel runat=server ID ="CheckLabel8"></ea:CheckLabel></TD>
    <TD><ea:CheckLabel runat=server ID ="CheckLabel9"></ea:CheckLabel></TD></TR>
  <TR>
    <TD>- z tej umowy chcę być objęty ubezpieczeniem emerytalnym i 
      rentowym,(zbieg tytułów ubezpieczeń)</TD>
    <TD><ea:CheckLabel runat=server ID ="CheckLabel10"></ea:CheckLabel></TD>
    <TD><ea:CheckLabel runat=server ID ="CheckLabel11"></ea:CheckLabel></TD></TR>
  <TR>
    <TD>- z tytułu tej umowy chcę być objęty(a) ubezpieczeniem chorobowym</TD>
    <TD><ea:CheckLabel runat=server ID ="CheckLabel12"></ea:CheckLabel></TD>
    <TD><ea:CheckLabel runat=server ID ="CheckLabel13"></ea:CheckLabel></TD></TR></TBODY></TABLE></P>
<P align=justify>2. Zleceniobiorca oświadcza, że zapoznał się z regulaminem 
świadczenia usług przez firmę PARETTi sp. z o.o. sp.k. zamieszczonym na odwrocie 
tego dokumentu, przyjął go do wiadomości i do wykonania, zgadza się z nim oraz 
wyraża zgodę na włączenie go do treści umowy.</P>
<P align=left>3. Zleceniobiorca zobowiązuje się do wykonania samodzielnie oraz 
bez nadzoru na zlecenie Zleceniodawcy&nbsp; </P>
<P align=left>następujących czynności: <ea:DataLabel runat=server DataMember="Last.Umowa.Tytul" EncodeHTML="True"></ea:DataLabel></P>
<P align=left>Przedsiębiorca i Miejsce wykonywania zlecenia :&nbsp;<ea:DataLabel runat=server DataMember="Last.Umowa.Wydzial.Nazwa" EncodeHTML="True"></ea:DataLabel></P>
<P align=left>Termin wykonania zlecenia od <ea:datalabel id="Datalabel43" runat="server" DataMember="Okres.From"> </ea:datalabel> do dnia <ea:datalabel id="Datalabel44" runat="server" DataMember="Okres.To"> </ea:datalabel> 

<P align=left>Za wynagrodzeniem : <ea:DataLabel runat=server DataMember="Last.Wartosc" EncodeHTML="True"></ea:DataLabel>&nbsp;<ea:DataLabel runat=server DataMember="TypWartosci" EncodeHTML="True"></ea:DataLabel>&nbsp;( <ea:DataLabel runat=server DataMember="RodzajRozliczenia" EncodeHTML="True"></ea:DataLabel>&nbsp;)</P>
<P align=left>&nbsp;</P>
<P>Podpis Zleceniodawcy _______________________ Podpis Zleceniobiorcy 
_______________________</P>
<P align=center><STRONG></STRONG>&nbsp;</P>
<P align=center><STRONG></STRONG>&nbsp;</P>
<P align=center><STRONG>Regulamin&nbsp; Świadczenia Usług przez firmę PARETTi 
sp. z o.o. sp.k.</STRONG><BR></P>
<OL style="FONT-SIZE: 12px">
  <LI>
  <DIV class=auto-style2 style="MARGIN-RIGHT: 0px" align=justify><FONT 
  size=2>Strony ustalają, że ważnym powodem wypowiedzenia ze skutkiem 
  natychmiastowym niniejszej umowy jest nieprzestrzeganie obowiązującego w 
  Przedsiębiorstwie (§ 3 umowy zlecenia) porządku, organizacji pracy, 
  nieprzestrzeganie harmonogramu wykonywania czynności, spożywanie alkoholu, 
  podjęcie czynności w stanie nietrzeźwym, spowodowanie szkody w mieniu 
  Przedsiębiorstwa.</FONT></DIV>
  <LI>
  <DIV class=auto-style2 align=justify><FONT size=2>Podstawą wypłaty 
  wynagrodzenia jest przedstawienie przez Zleceniobiorcę Raportu Godzin, który 
  jest zaakceptowany przez Zleceniodawcę w terminie do 2-go dnia roboczego 
  miesiąca następującego po miesiącu w którym była świadczona 
  usługa.</FONT></DIV>
  <LI>
  <DIV class=auto-style2 align=justify><FONT size=2>Jeżeli zleceniobiorca nie 
  złoży Raportu Godzin w terminie do 3-go dnia roboczego po miesiącu w którym 
  zostały wykonane usługi, Zleceniodawca zastrzega sobie prawo do przedłużenia 
  terminu przelewu wynagrodzenia o dodatkowe 30 dni.</FONT></DIV>
  <LI>
  <DIV class=auto-style2 align=justify><FONT size=2>Jeżeli Zleceniobiorca w 
  ciągu jednego miesiąca po zakończeniu miesiąca w którym wykonywane było 
  zlecenie nie dostarczy Raportu Godzin, to z uwagi na umowę z Kontrahentem, 
  rozliczenie wynagrodzenia z tytułu umowy zlecenia staje się niemożliwe. Jest 
  to nieprawidłowe wykonanie zlecenia i w związku z tym Zleceniobiorca nie może 
  żądać wypłaty wynagrodzenia.</FONT></DIV>
  <LI>
  <DIV class=auto-style2 align=justify><FONT size=2>Wynagrodzenie o którym mowa 
  w § 3 płatne jest przelewem w terminie 15 dni od zakończenia miesiąca w którym 
  usługa została wykonana.</FONT></DIV>
  <LI>
  <DIV class=auto-style2 align=justify><FONT size=2>Jeżeli Zleceniobiorca nie 
  posiada rachunku bankowego, jego wynagrodzenie będzie przelane przekazem 
  pocztowym na adres podany w umowie po potrąceniu kosztów przesyłki, a termin 
  wypłaty przesunie się o dodatkowe 7 dni.</FONT></DIV>
  <LI>
  <DIV class=auto-style2 align=justify><FONT size=2>W przypadku niestarannego 
  wykonania zlecenia, Zleceniodawca ma prawo do zatrzymania części 
  wynagrodzenia.</FONT></DIV>
  <LI>
  <DIV class=auto-style2 align=justify><FONT size=2>Zleceniobiorca ma obowiązek 
  poinformować Zleceniodawcę o ewentualnej nieobecności na 48 godzin przed 
  wyznaczonym czasem rozpoczęcia wykonania zlecenia. Za niezachowanie tego 
  terminu Zleceniodawca potrąci Zleceniobiorcy karę umowną w wysokości 100 
  zł.</FONT></DIV>
  <LI>
  <DIV class=auto-style2 align=justify><FONT size=2>Zleceniobiorca zobowiązuje 
  się do wykonania zlecenia zgodnie z zasadami obowiązującymi w miejscu 
  wykonywania zlecenia.</FONT></DIV>
  <LI>
  <DIV class=auto-style2 align=justify><FONT size=2>Zleceniobiorca zobowiązuje 
  się do zachowania poufności informacji dotyczących Zleceniodawcy.</FONT></DIV>
  <LI>
  <DIV class=auto-style2 align=justify><FONT size=2>Zleceniobiorca ponosi pełną 
  odpowiedzialność finansową za powierzone mu rzeczy. </FONT></DIV>
  <LI>
  <DIV class=auto-style2 align=justify><FONT size=2>Jeżeli Zleceniobiorcy 
  powierzono prowadzenie kasy, to jest odpowiedzialny za stan gotówki w kasie i 
  prawidłowość przeprowadzanych operacji kasowych i w przypadku niezgodności 
  jest zobowiązany do pokrycia niedoborów. </FONT></DIV>
  <LI>
  <DIV class=auto-style2 align=justify><FONT size=2>Zleceniobiorca traci 
  wynagrodzenie w przypadku dokonania przez niego kradzieży lub innego 
  przestępstwa przeciwko mieniu w miejscu wykonywania zlecenia, oraz jest 
  zobowiązany do zapłacenia kary umownej w wysokości 1000zł na 
  rzecz&nbsp;&nbsp;&nbsp; Zleceniodawcy.</FONT></DIV>
  <LI>
  <DIV class=auto-style2 align=justify><FONT size=2>Zapłata kary umownej p rzez 
  Zleceniobiorcę wynikającą z pkt. 12 nie wyłącza możliwości dochodzenia przez 
  Zleceniodawcę naprawienia szkody powstałej w wyniku kradzieży lub innego 
  przestępstwa przeciwko mieniu.</FONT></DIV>
  <LI>
  <DIV class=auto-style2 align=justify><FONT size=2>Jeżeli Zleceniodawca w celu 
  wykonania zlecenia poniesie dodatkowe koszty np.: koszty badań lekarskich, 
  szkoleń, szkoleń BHP, ubrania roboczego to Zleceniobiorca o ile Zleceniodawca 
  nie postanowi inaczej zostanie obciążony tymi kosztami.</FONT></DIV>
  <LI>
  <DIV class=auto-style2 align=justify><FONT size=2>Zleceniobiorca nie może 
  powierzyć wykonania zlecenia osobie trzeciej bez uprzedniej pisemnej zgody 
  Zleceniodawcy.</FONT></DIV>
  <LI>
  <DIV class=auto-style2 align=justify><FONT size=2>Zleceniobiorca ponosi 
  odpowiedzialność wobec osób trzecich co do jakości i skutków przedmiotu 
  umowy.</FONT></DIV>
  <LI>
  <DIV class=auto-style2 align=justify><FONT size=2>Zleceniodawca nie odpowiada 
  za rzeczy osobiste Zleceniobiorcy pozostawione w miejscu wykonywania zlecenia 
  bez nadzoru ze strony Zleceniobiorcy</FONT></DIV>
  <LI>
  <DIV class=auto-style2 align=justify><FONT size=2>Zleceniodawca nie jest 
  zobowiązany do żadnych świadczeń na rzecz Zleceniobiorcy wynikających ze 
  stosunku pracy.</FONT></DIV>
  <LI>
  <DIV class=auto-style2 align=justify><FONT size=2>Zleceniobiorca oświadcza, że 
  jego świadomą intencją i wolą jest zawarcie umowy cywilnoprawnej a nie umowy o 
  pracę.</FONT></DIV>
  <LI>
  <DIV class=auto-style2 align=justify><FONT size=2>W sprawach nieuregulowanych 
  niniejszą Umową i Regulaminem Świadczenia Usług znajdują zastosowanie przepisy 
  Kodeksu Cywilnego.</FONT></DIV>
  <LI>
  <DIV class=auto-style2 align=justify><FONT size=2>Ewentualne spory wynikłe z 
  realizacji umowy zlecenia strony poddadzą sądowi właściwemu miejscowo ze 
  względu na siedzibę Zleceniodawcy.</FONT></DIV>
  <LI>
  <DIV class=auto-style2 align=justify><FONT size=2>Zleceniobiorcy nie wolno 
  zawierać żadnych umów cywilnoprawnych ani umów o pracę bezpośrednio, ani przez 
  osoby trzecie lub Firmy trzecie z Przedsiębiorcą (§ 3 umowy zlecenia), do 
  którego skierowany jest w ramach niniejszej umowy w okresie jej obowiązywania 
  oraz przez okres 2 lat od jej wygaśnięcia. W przypadku naruszenia tego 
  postanowienia Zleceniobiorca zapłaci Zleceniodawcy karę umowną w wysokości 
  1000zł.</FONT></DIV>
  <LI>
  <DIV align=justify><FONT size=2>Zleceniobiorca oświadcza, że jest świadomy 
  różnic między zatrudnieniem opartym na stosunku pracy, a świadczeniem usług 
  opartym na cywilnoprawnym stosunku zobowiązań stanowiącym podstawę zawarcia 
  niniejszej umowy oraz zgoda na zawarcie niniejszej umowy nie jest 
  zdeterminowana ani wymuszona wskutek ekonomicznej lub jakiejkolwiek zależności 
  od Zleceniodawcy.</FONT></DIV>
  <LI>
  <DIV align=justify><FONT size=2>Zleceniobiorca oświadcza, że wyraża zgodę na 
  przetwarzanie swoich danych osobowych dla potrzeb procesu rekrutacji oraz dla 
  celów marketingowych zgodnie z ustawą z dnia 29.08.1997 r. o ochronie danych 
  osobowych Dz.Ust. Nr 133 poz. 883. Zleceniobiorca oświadcza, że został 
  poinformowany o możliwość wglądu do swoich danych osobowych, ich poprawiania i 
  usuwania.<BR></FONT></DIV></LI></OL>
<P>&nbsp;</P>
<P>Podpis Zleceniobiorcy: _____________________________ </P>
<P>&nbsp;</P></FORM></BODY></HTML>
