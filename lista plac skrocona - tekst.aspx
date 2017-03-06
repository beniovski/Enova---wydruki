<%@ import Namespace="Soneta.Types" %>
<%@ import Namespace="Soneta.Kadry" %>
<%@ import Namespace="Soneta.Place" %>
<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %>
<%@ Register TagPrefix="cc1" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %>
<%@ Page Language="c#" CodePage="1200" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<HTML>
	<HEAD>
		<title></title>
		<script runat="server">

            static bool hideOperator = false;
            static bool nazwaWNaglowku = false;

            void Grid_BeforeRow(object sender, Soneta.Web.RowEventArgs args) {
                WyplataEtat wypłata = args.Row as WyplataEtat;
                if (wypłata == null)
                    throw new InvalidOperationException("Lista płac skrócona może być drukowana tylko dla wypłat etatowych. " + args.Row);

                WyplataEtatWorker worker = new WyplataEtatWorker();
                worker.Wypłata = wypłata;

                colNadgodziny.EditValue = worker.Nadgodziny50 + worker.Nadgodziny100;
                colDodatkiB.EditValue = worker.Dodatki + worker.NieZUS;
                colDodatkiN.EditValue = worker.NDodatki + worker.RozlPit;
            }

            void Grid_AfterRender(object sender, System.EventArgs e) {
                Currency brutto = (decimal)colBrutto.GetTotalValue(0m);
                labelBrutto.EditValue = brutto;
                labelBrutto2.EditValue = brutto;

                Currency netto = (Currency)colGotowka.GetTotalValue(0m) + (Currency)colROR.GetTotalValue(Currency.Zero);
                labelNetto.EditValue = netto;
                labelNetto2.EditValue = netto;
            }

            void dc_ContextLoad(Object sender, EventArgs e) {
                ListaPlac lista = (ListaPlac)dc[typeof(ListaPlac)];

                if (lista.Bufor)
                    dlBufor.EditValue = "\n&nbsp;&nbsp;&nbsp;&nbsp;<i><u>Lista nie została zatwierdzona!</u></i>";

                if (nazwaWNaglowku)
                    dlNazwa.EditValue = "\n&nbsp;&nbsp;&nbsp;&nbsp;" + lista.Definicja.Nazwa;

                if (!hideOperator) {
                    labelData.EditValue = "Data wydruku: " + dc.Session.Login.CurrentDate;
                    labelOperator.EditValue = "Operator: " + dc.Session.Login.Operator.Name;
                }

                if (lista.Definicja.WalutaPlatnosci != null && lista.Definicja.WalutaPlatnosci.Symbol != Currency.SystemSymbol) {
                    colWartość.Format = "";
                    colROR.Format = "";
                    colGotowka.Format = "";
                }                             
                
                labelCopyright.EditValue = dc.Copyright;
            }

            static void Msg(object value) {
            }
		    
		</script>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<meta content="Microsoft Visual Studio 7.0" name="GENERATOR">
		<meta content="C#" name="CODE_LANGUAGE">
		<meta content="JavaScript" name="vs_defaultClientScript">
		<meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema">
	</HEAD>
	<body>
		<font face="Courier New" size="smaller">
		<form id="form" method="post" runat="server">
			<ea:datacontext id="dc" runat="server" TypeName="Soneta.Place.ListaPlac, Soneta.KadryPlace"
				OnContextLoad="dc_ContextLoad"></ea:datacontext>
			    <small></small><u></u><b></b>
				<ea:Section id="Section3" runat="server" Width="100%">
				    &nbsp;&nbsp;&nbsp;&nbsp; Lista płac:&nbsp;&nbsp;&nbsp; 
                    <ea:datalabel id="Datalabel1" runat="server" Format="<u>{0}</u>" DataMember="Numer"></ea:datalabel>
                    <ea:datalabel id="dlNazwa" runat="server"></ea:datalabel>
                    <ea:datalabel id="dlBufor" runat="server"></ea:datalabel><BR>&nbsp;&nbsp;&nbsp;&nbsp; 
                    Wydział:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
                    <ea:datalabel id="Datalabel2" runat="server" DataMember="Wydzial" EncodeHTML="True"></ea:datalabel><BR>&nbsp; 
                    &nbsp;&nbsp;&nbsp;Za okres:&nbsp;&nbsp;&nbsp;&nbsp; 
                    <ea:datalabel id="Datalabel3" runat="server" DataMember="Okres" EncodeHTML="True"></ea:datalabel><BR>&nbsp;&nbsp;&nbsp;&nbsp; 
                    Data wypłaty: 
                    <ea:datalabel id="Datalabel4" runat="server" DataMember="DataWyplaty" EncodeHTML="True"></ea:datalabel><BR><SMALL>
					+--------------------------------------------------------------------------------------------------------------------------------+</SMALL><BR>
                    <ea:datalabel id="DataLabel8" runat="server" DataMember="Session.Core.Config.Firma.Pieczątka.NazwaWieleLinii"
						EncodeHTML="True" LeftMargin="4"></ea:datalabel><BR>
                    <ea:datalabel id="DataLabel9" runat="server" DataMember="Session.Core.Config.Firma.AdresSiedziby.Linia1"
						EncodeHTML="True" LeftMargin="4"></ea:datalabel><BR>
                    <ea:datalabel id="DataLabel10" runat="server" DataMember="Session.Core.Config.Firma.AdresSiedziby.Linia2"
						EncodeHTML="True" LeftMargin="4"></ea:datalabel><BR>&nbsp;&nbsp;&nbsp;&nbsp;NIP: 
                    <ea:datalabel id="DataLabel11" runat="server" DataMember="Session.Core.Config.Firma.Pieczątka.NIP"></ea:datalabel><br>
				</ea:Section>
				<small>
			<ea:TextGrid id="Grid" runat="server" DataMember="Wyplaty" AroundBorder="Single" RowsInRow="3"
				RowTypeName="Soneta.Place.WyplataEtat,Soneta.KadryPlace" onbeforerow="Grid_BeforeRow" onafterrender="Grid_AfterRender">
				<Columns>
					<ea:GridColumn Width="4" Align="Right" DataMember="Numer.Numer" Caption="Lp" RowSpan="3" runat="server"></ea:GridColumn>
					<ea:GridColumn Width="25" DataMember="PracHistoria.Nazwisko" Total="Info" Caption="Nazwisko" Format="{0}" runat="server"></ea:GridColumn>
					<ea:GridColumn DataMember="PracHistoria.Imie" Caption="Imię" runat="server"></ea:GridColumn>
					<ea:GridColumn runat="server"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Workers.WyplataEtat.Zasadnicze" Total="Sum" Caption="Zasadnicze"
						Format="{0:n}" runat="server"></ea:GridColumn>
					<ea:GridColumn Align="Right" Total="Sum" Caption="Nadgodziny" Format="{0:n}" ID="colNadgodziny" runat="server"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Workers.WyplataEtat.Nocne" Total="Sum" Caption="Nocne"
						Format="{0:n}" runat="server"></ea:GridColumn>
					<ea:GridColumn Align="Right" Total="Sum" Caption="Dodatki/B" Format="{0:n}" ID="colDodatkiB" runat="server"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Workers.WyplataEtat.Potrącenia" Total="Sum" Caption="Potrącenia/B"
						Format="{0:n}" runat="server"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Workers.WyplataEtat.Zasiłki" Total="Sum" Caption="Zasiłki/B"
						Format="{0:n}" runat="server"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Workers.WyplataEtat.Brutto" Total="Sum" Caption="Brutto"
						Format="{0:n}" ID="colBrutto" runat="server"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Workers.WyplataEtat.SkładkiZUS" Total="Sum" Caption="Skł. ZUS"
						Format="{0:n}" ID="colZusPrac" runat="server"></ea:GridColumn>
					<ea:GridColumn runat="server"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Workers.PITInfo.ZdrowotneDoOdliczenia" Total="Sum" Caption="NFZ odlicz."
						Format="{0:n}" runat="server"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Workers.PITInfo.ZdrowotnePracownika" Total="Sum" Caption="NFZ nie.odl."
						Format="{0:n}" runat="server"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Workers.WyplataEtat.Podatek" Total="Sum" Caption="Zal. PIT"
						Format="{0:n}" ID="colZalPIT" runat="server"></ea:GridColumn>
					<ea:GridColumn Align="Right" Total="Sum" Caption="Dodatki/N" Format="{0:n}" ID="colDodatkiN" runat="server"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Workers.WyplataEtat.NPotrącenia" Total="Sum" Caption="Potrącenia/N"
						Format="{0:n}" runat="server"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Workers.WyplataEtat.NZasiłki" Total="Sum" Caption="Zasiłki/N"
						Format="{0:n}" runat="server"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="WartoscCy" Total="Sum" Caption="Do wypłaty" Format="{0:n}" runat="server" ID="colWartość"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Got&#243;wka" Total="Sum" Caption="Got&#243;wka"
						Format="{0:n}" ID="colGotowka" runat="server"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Inne" Total="Sum" Caption="ROR" Format="{0:n}" ID="colROR" runat="server"></ea:GridColumn>
					<ea:GridColumn Width="16" Align="Center" Caption="Data|Podpis" Format="||.............."
						ID="colPodpis" RowSpan="3" VAlign="Bottom" runat="server"></ea:GridColumn>
				</Columns>
			</ea:TextGrid></small><br>
            <ea:Section id="Section4" runat="server" Width="100%">
				Zatwierdzono na kwotę:<BR>Opodatkowane (brutto):
<ea:datalabel id="labelBrutto" runat="server" Format="{0:u}" Align="Right" WidthChars="17"></ea:datalabel><BR>&nbsp;&nbsp;&nbsp;<SMALL>
						słownie:
						<ea:datalabel id="labelBrutto2" runat="server" Format="{0:t}" Align="Right"></ea:datalabel></SMALL><BR>
                        Do wypłaty (netto): &nbsp;
<ea:datalabel id="labelNetto" runat="server" Format="{0:u}" Align="Right" WidthChars="17"></ea:datalabel><BR>&nbsp;&nbsp;&nbsp;<SMALL>
						słownie:
						<ea:datalabel id="labelNetto2" runat="server" Format="{0:t}" Align="Right"></ea:datalabel></SMALL><SMALL><BR>
						<BR>
						+--------------------------------------------------------------------------------------------------------------------------------+<BR>
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Sprawdzono pod względem 
						merytorycznym&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						Sprawdzono pod względem formalno 
						prawnym&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|<BR>
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|<BR>
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;...............&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						...............&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;...............&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						...............&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|<BR>
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						data&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;podpis&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						data&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;podpis&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|<BR>
						+--------------------------------------------------------------------------------------------------------------------------------+<BR>
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|<BR>
						|
						<ea:datalabel id="labelData" runat="server" Format="{0:n}" Align="Left" WidthChars="31"></ea:datalabel>|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|<BR>
						|
						<ea:datalabel id="labelOperator" runat="server" Format="{0:n}" Align="Left" WidthChars="31"></ea:datalabel>|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						...............&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						...............&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						...............&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |<BR>
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;data&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;główny 
						księgowy&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;kierownik 
						jednostki&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |<BR>
						+--------------------------------------------------------------------------------------------------------------------------------+</SMALL><BR><SMALL>
						<ea:datalabel id="labelCopyright" runat="server" Align="Right" WidthChars="130" Bold="False"></ea:datalabel></SMALL>
				</ea:Section>
				<ea:PageBreak id="PageBreak1" runat="server"></ea:PageBreak>
		</form>
		</font>
	</body>
</HTML>

