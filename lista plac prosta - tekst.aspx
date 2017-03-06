<%@ import Namespace="Soneta.Types" %>
<%@ import Namespace="Soneta.Kadry" %>
<%@ import Namespace="Soneta.Place" %>
<%@ Register TagPrefix="cc1" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %>
<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %>
<%@ Page Language="c#" CodePage="1200" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<HTML>
	<HEAD>
		<title></title>
		<script runat="server">

            static bool hideOperator = false;
            static bool nazwaWNaglowku = false;

            void Grid_BeforeRow(object sender, Soneta.Web.RowEventArgs args) {
                Wyplata wypłata = (Wyplata)args.Row;

                colNazImie.EditValue = string.Format("{0} {1}",
                    wypłata.PracHistoria.Nazwisko, wypłata.PracHistoria.Imie);
            }

            void Grid_AfterRender(object sender, System.EventArgs e) {
                Currency suma = (decimal)colSuma.GetTotalValue(0m);
                labelSuma.EditValue = suma;
                labelSuma2.EditValue = suma;

                Currency netto = (Currency)colGotowka.GetTotalValue(0m) + (Currency)colROR.GetTotalValue(0m);
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
		<form id="ProstaListaPłac" method="post" runat="server">
			<ea:datacontext id="dc" runat="server" TypeName="Soneta.Place.ListaPlac, Soneta.KadryPlace" OnContextLoad="dc_ContextLoad"></ea:datacontext>
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
			<ea:TextGrid id="Grid" runat="server" onafterrender="Grid_AfterRender" onbeforerow="Grid_BeforeRow"
				DataMember="Wyplaty" RowTypeName="Soneta.Place.Wyplata, Soneta.KadryPlace">
				<Columns>
					<ea:GridColumn Width="4" Align="Right" DataMember="Numer.Numer" Caption="Lp" VAlign="Top" runat="server"></ea:GridColumn>
					<ea:GridColumn Width="30" Total="Info" Caption="Nazwisko i imię" ID="colNazImie" runat="server"></ea:GridColumn>
					<ea:GridColumn Width="12" Align="Right" DataMember="Workers.PITInfo.Razem" Total="Sum" Caption="Suma|wypłat"
						Format="{0:n}" ID="colSuma" runat="server"></ea:GridColumn>
					<ea:GridColumn Width="12" Align="Right" DataMember="Workers.WyplataSkładki.Razem.KosztyZUS" Total="Sum"
						Caption="Składki|ZUS" Format="{0:n}" runat="server"></ea:GridColumn>
					<ea:GridColumn Width="12" Align="Right" DataMember="Workers.PITInfo.ZalFIS" Total="Sum" Caption="Zaliczka|podatku"
						Format="{0:n}" runat="server"></ea:GridColumn>
					<ea:GridColumn Width="12" Align="Right" DataMember="Workers.WyplataSkładki.Razem.Zdrowotna.Prac"
						Total="Sum" Caption="Składka|zdrowotna" Format="{0:n}" runat="server"></ea:GridColumn>
					<ea:GridColumn Width="12" Align="Right" DataMember="Got&#243;wka" Total="Sum" Caption="Do wypłaty|got&#243;wka"
						Format="{0:n}" ID="colGotowka" runat="server"></ea:GridColumn>
					<ea:GridColumn Width="12" Align="Right" DataMember="Inne" Total="Sum" Caption="Do wypłaty|ROR"
						Format="{0:n}" ID="colROR" runat="server"></ea:GridColumn>
					<ea:GridColumn Align="Right" Caption="Data|podpis" runat="server"></ea:GridColumn>
				</Columns>
			</ea:TextGrid><br>
			</small>
				<ea:Section id="Section4" runat="server" Width="100%">
				Zatwierdzono 
na kwotę:<BR>
                    Suma wypłat: &nbsp;&nbsp; 
<ea:datalabel id="labelSuma" runat="server" Format="{0:u}" Align="Right" WidthChars="17"></ea:datalabel><BR>&nbsp;&nbsp;&nbsp;<SMALL>
						słownie:
						<ea:datalabel id="labelSuma2" runat="server" Format="{0:t}" Align="Right"></ea:datalabel></SMALL><BR>
                    Do wypłaty (netto): 
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
            <ea:PageBreak ID="PageBreak1" runat="server">
            </ea:PageBreak>
		</form>
		</font>
	</body>
</HTML>

