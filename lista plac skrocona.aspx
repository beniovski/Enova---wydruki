<%@ import Namespace="Soneta.Types" %>
<%@ import Namespace="Soneta.Kadry" %>
<%@ import Namespace="Soneta.Place" %>
<%@ import Namespace="Soneta.Business" %>
<%@ import Namespace="Soneta.Tools" %>
<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %>
<%@ Register TagPrefix="cc1" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %>
<%@ Page Language="c#" CodePage="1200" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<HTML>
	<HEAD>
		<title>Skrócona lista płac</title>
		<script runat="server">

    void Grid_BeforeRow(object sender, Soneta.Web.RowEventArgs args) {
        WyplataEtat wypłata = args.Row as WyplataEtat;
        if (wypłata==null)
            throw new InvalidOperationException("Lista płac skrócona może być drukowana tylko dla wypłat etatowych. "+args.Row);
    
        WyplataEtatWorker worker = new WyplataEtatWorker();
        worker.Wypłata = wypłata;
    
        colNadgodziny.EditValue = worker.Nadgodziny50 + worker.Nadgodziny100;
        colDodatkiB.EditValue = worker.Dodatki + worker.NieZUS;
    
        colDodatkiN.EditValue = worker.NDodatki + worker.RozlPit;
    }

    public class SrParams : SerializableContextBase {
        public SrParams(Context context) : base(context) {
        }

        //static bool hideOperator = false;
        bool hideOperator = false;
        [Priority(1)]
        [Caption("Ukryj operatora")]
        public bool HideOperator {
            get { return hideOperator; }
            set {
                hideOperator = value;
                OnChanged(EventArgs.Empty);
            }
        }

        //static bool nazwaWNaglowku = false;
        bool nazwaWNaglowku = false;
        [Priority(2)]
        [Caption("Nazwa w nagłówku")]
        public bool NazwaWNaglowku {
            get { return nazwaWNaglowku; }
            set {
                nazwaWNaglowku = value;
                OnChanged(EventArgs.Empty);
            }
        }
    }

    SrParams srpars;
    [SettingsContext]
    public SrParams SrPars {
        get { return srpars; }
        set { srpars = value; }
    }		

    void dc_ContextLoad(Object sender, EventArgs e) {
        ListaPlac lista = (ListaPlac)dc[typeof(ListaPlac)];
        if (lista.Bufor)
            ReportHeader1["BUFOR"] = "Lista nie została zatwierdzona!|";
        else
            ReportHeader1["BUFOR"] = "";
            
        if (srpars.NazwaWNaglowku)
            ReportHeader1["NAZWA"] = lista.Definicja.Nazwa + "|";
        else
            ReportHeader1["NAZWA"] = "";
            
        if (srpars.HideOperator)
			stOperator.SubtitleType = SubtitleType.Empty;

        if (lista.Definicja.WalutaPlatnosci != null && lista.Definicja.WalutaPlatnosci.Symbol != Currency.SystemSymbol) {
            colWartość.Format = "";
            colROR.Format = "";
            colGotowka.Format = "";
        }                             
    }

            void Grid_AfterRender(object sender, System.EventArgs e) {
                decimal brutto = (decimal)colBrutto.GetTotalValue(0m);
                cellBrutto.EditValue = (Currency)brutto;

                Currency gotówka = (Currency)colGotowka.GetTotalValue(0m);
                Currency ror = (Currency)colROR.GetTotalValue(0m);
                cellNetto.EditValue = gotówka + ror;
            }
    		    
		</script>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<meta content="Microsoft Visual Studio 7.0" name="GENERATOR">
		<meta content="C#" name="CODE_LANGUAGE">
		<meta content="JavaScript" name="vs_defaultClientScript">
		<meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema">
	</HEAD>
	<body>
		<form id="form" method="post" runat="server">
			<ea:datacontext id="dc" runat="server" RightMargin="-1" LeftMargin="-1" TypeName="Soneta.Place.ListaPlac, Soneta.KadryPlace"
				BottomMargin="-1" TopMargin="-1" OnContextLoad="dc_ContextLoad"></ea:datacontext>
			<cc1:reportheader NagłówekOddziału="NagłówekOddziału" id="ReportHeader1" title="Lista płac {0}|%NAZWA%%BUFOR%</strong>Wydział:<strong> {1}|</strong>Za okres:<strong> {2}|</strong>Data wypłaty:<strong> {3}"
				runat="server" DataMember0="Numer" DataMember1="Wydzial" DataMember2="Okres" DataMember3="DataWyplaty"></cc1:reportheader>
			<ea:grid id="Grid" runat="server" DataMember="Wyplaty" AroundBorder="Single" RowsInRow="3"
				RowTypeName="Soneta.Place.WyplataEtat,Soneta.KadryPlace" onbeforerow="Grid_BeforeRow" onafterrender="Grid_AfterRender">
				<Columns>
					<ea:GridColumn Width="4" Align="Right" DataMember="Numer.Numer" Caption="Lp" RowSpan="3" runat="server"></ea:GridColumn>
					<ea:GridColumn Width="25" DataMember="PracHistoria.Nazwisko" Total="Info" Caption="Nazwisko" Format="&lt;strong&gt;{0}&lt;/strong&gt;" runat="server"></ea:GridColumn>
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
					<ea:GridColumn Align="Right" DataMember="WartoscCy" Total="Sum" Caption="Do wypłaty" Format="{0:n}" ID="colWartość" runat="server"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Got&#243;wka" Total="Sum" Caption="Got&#243;wka"
						Format="{0:n}" ID="colGotowka" runat="server"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Inne" Total="Sum" Caption="ROR" Format="{0:n}" ID="colROR" runat="server"></ea:GridColumn>
					<ea:GridColumn Width="16" Align="Center" Caption="Data|Podpis" Format="......................"
						ID="colPodpis" RowSpan="3" VAlign="Bottom" runat="server"></ea:GridColumn>
				</Columns>
			</ea:grid>
			<cc1:reportfooter id="ReportFooter1" runat="server">
				<Cells>
					<cc1:FooterCell Caption="Opodatkowane (brutto):" Format1="{0:u}," ID="cellBrutto"></cc1:FooterCell>
					<cc1:FooterCell Caption="Do wypłaty (netto):" Format1="{0:u}," ID="cellNetto"></cc1:FooterCell>
				</Cells>
				<Subtitles>
					<cc1:FooterSubtitle Caption="Sprawdzono pod względem merytorycznym" SubtitleType="DataPodpis" Width="50"></cc1:FooterSubtitle>
					<cc1:FooterSubtitle Caption="Sprawdzono pod względem formalno prawnym" SubtitleType="DataPodpis" Width="50"></cc1:FooterSubtitle>
					<cc1:FooterSubtitle ID="stOperator" SubtitleType="Operator"></cc1:FooterSubtitle>
					<cc1:FooterSubtitle Caption="data"></cc1:FooterSubtitle>
					<cc1:FooterSubtitle Caption="gł&#243;wny księgowy"></cc1:FooterSubtitle>
					<cc1:FooterSubtitle Caption="kierownik jednostki"></cc1:FooterSubtitle>
				</Subtitles>
			</cc1:reportfooter>
		</form>
	</body>
</HTML>
