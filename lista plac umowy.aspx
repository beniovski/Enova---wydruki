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
		<title>Prosta lista płac</title>
		<script runat="server">

    private void Grid_AfterRender(object sender, System.EventArgs e) {
        cellBrutto.EditValue = (Currency)(decimal)colBrutto.GetTotalValue(0m);
        cellDoWypłaty.EditValue = (Currency)(decimal)colDoWypłaty.GetTotalValue(0m);
    }
    
    private void Grid_BeforeRow(object sender, Soneta.Web.RowEventArgs args) {
        WyplataUmowa wypłata = args.Row as WyplataUmowa;
        if (wypłata==null)
            throw new InvalidOperationException("Lista płac umów może być drukowana tylko dla wypłat umów. "+args.Row);
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
			<ea:datacontext id="dc" runat="server" TopMargin="-1" BottomMargin="-1" RightMargin="-1" LeftMargin="-1"
				TypeName="Soneta.Place.ListaPlac, Soneta.KadryPlace" OnContextLoad="dc_ContextLoad"></ea:datacontext>
			<cc1:reportheader NagłówekOddziału="NagłówekOddziału" id="ReportHeader1" title="Lista płac {0}|%NAZWA%%BUFOR%</strong>Wydział:<strong> {1}|</strong>Za okres:<strong> {2}|</strong>Data wypłaty:<strong> {3}"
				runat="server" DataMember2="Okres" DataMember1="Wydzial" DataMember0="Numer" DataMember3="DataWyplaty"></cc1:reportheader>
			<ea:Grid id="Grid" runat="server" onafterrender="Grid_AfterRender" onbeforerow="Grid_BeforeRow"
				RowsInRow="3" DataMember="Wyplaty" RowTypeName="Soneta.Place.WyplataUmowa,Soneta.KadryPlace">
				<Columns>
					<ea:GridColumn Width="4" Align="Right" DataMember="Numer.Numer" Caption="Lp" RowSpan="3"></ea:GridColumn>
					<ea:GridColumn Width="25" DataMember="PracHistoria.Nazwisko" Total="Info" Caption="Nazwisko" Format="&lt;strong&gt;{0}&lt;/strong&gt;"></ea:GridColumn>
					<ea:GridColumn DataMember="PracHistoria.Imie" Caption="Imię"></ea:GridColumn>
					<ea:GridColumn DataMember="Umowa.Numer" Caption="Nr umowy" Format="&lt;strong&gt;{0}&lt;/strong&gt;"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Workers.WyplataUmowa.Brutto" Total="Sum" Caption="Umowa"
						Format="{0:n}"></ea:GridColumn>
					<ea:GridColumn></ea:GridColumn>
					<ea:GridColumn></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Workers.WyplataUmowa.Dodatki" Total="Sum" Caption="Dodatki/B"
						Format="{0:n}"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Workers.WyplataUmowa.Potrącenia" Total="Sum" Caption="Potrącenia/B"
						Format="{0:n}"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Workers.WyplataUmowa.Zasiłki" Total="Sum" Caption="Zasiłki/B"
						Format="{0:n}"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Workers.PITInfo.Brutto" Total="Sum" Caption="Brutto" Format="{0:n}"
						ID="colBrutto"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Workers.PITInfo.KosztyFIS" Total="Sum" Caption="Koszty uzysk."
						Format="{0:n}"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Workers.PITInfo.SkładkiZUS" Total="Sum" Caption="Skł. ZUS"
						Format="{0:n}"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Workers.PITInfo.ZdrowotneDoOdliczenia" Total="Sum" Caption="NFZ odlicz."
						Format="{0:n}"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Workers.PITInfo.ZdrowotnePracownika" Total="Sum" Caption="NFZ nie odl."
						Format="{0:n}"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Workers.PITInfo.ZalFIS" Total="Sum" Caption="Zal. PIT"
						Format="{0:n}"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Workers.WyplataUmowa.NDodatki" Total="Sum" Caption="Dodatki/N"
						Format="{0:n}"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Workers.WyplataUmowa.NPotrącenia" Total="Sum" Caption="Potrącenia/N"
						Format="{0:n}"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Workers.WyplataUmowa.NZasiłki" Total="Sum" Caption="Zasiłki/N"
						Format="{0:n}"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Wartosc.Value" Total="Sum" Caption="Do wypłaty" Format="{0:n}"
						ID="colDoWypłaty"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Got&#243;wka" Total="Sum" Caption="Got&#243;wka" Format="{0:n}"></ea:GridColumn>
					<ea:GridColumn Align="Right" DataMember="Inne" Total="Sum" Caption="ROR" Format="{0:n}"></ea:GridColumn>
					<ea:GridColumn Width="16" Align="Center" Caption="Data i podpis" Format="...................."
						RowSpan="3" VAlign="Bottom"></ea:GridColumn>
				</Columns>
			</ea:Grid>
			<cc1:reportfooter id="ReportFooter1" runat="server">
				<Cells>
					<cc1:FooterCell Caption="Opodatkowane (brutto):" Format1="{0:u}," ID="cellBrutto"></cc1:FooterCell>
					<cc1:FooterCell Caption="Do wypłaty (netto):" Format1="{0:u}," ID="cellDoWypłaty"></cc1:FooterCell>
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
