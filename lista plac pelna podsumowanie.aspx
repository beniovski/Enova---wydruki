<%@ Page Language="c#" CodePage="1200" %>
<%@ Register TagPrefix="cc1" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %>
<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %>
<%@ import Namespace="Soneta.Place" %>
<%@ import Namespace="Soneta.Kadry" %>
<%@ import Namespace="Soneta.Types" %>
<%@ import Namespace="Soneta.Tools" %>
<%@ import Namespace="Soneta.Business" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<HTML>
	<HEAD>
		<title>Pełna lista płac</title>
		<script runat="server">
        
    public class Elem : IComparable {
        int counter = 0;
        string name;
        decimal dodatki = 0;
        decimal potrącenia = 0;
    
        public Elem(DefinicjaElementu definicja) {
            this.name = definicja.Nazwa;
        }
    
        public void Add(decimal wartość) {
            ++counter;
            if (wartość>0)
                dodatki += wartość;
            else
                potrącenia -= wartość;
        }
    
        public int Counter { get { return counter; } }
        public string Name { get { return name; } }
        public decimal Dodatki { get { return dodatki; } }
        public decimal Potrącenia { get { return potrącenia; } }
        public decimal Razem { get { return dodatki-potrącenia; } }
    
        public int CompareTo(object v) {
            return string.Compare(Name, ((Elem)v).Name, true);
        }
    }
    
    class PitTotal {
        readonly string nazwa;
        decimal brutto;
        decimal zaliczka;
    
        public PitTotal(string nazwa) {
            this.nazwa = nazwa;
        }
        public void Add(WypElement element) {
            brutto += element.Wartosc;
            zaliczka += element.Podatki.ZalFIS;
        }
        public string Nazwa {
            get { return nazwa; }
        }
        public decimal Brutto {
            get { return brutto; }
        }
        public decimal Zaliczka {
            get { return zaliczka; }
        }
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

		ListaPlacPodatkiWorker lpp = new ListaPlacPodatkiWorker(lista);
		
        cellBrutto.EditValue = new Currency(lpp.Brutto);
        cellNetto.EditValue = new Currency(lpp.DoWypłaty);
		
        labelEmerPrac.EditValue = lpp.Emerytalna.Prac;
        labelRentPrac.EditValue = lpp.Rentowa.Prac;
        labelChorPrac.EditValue = lpp.Chorobowa.Prac;
        labelWypadPrac.EditValue = lpp.Wypadkowa.Prac;
        labelZdrowPrac.EditValue = lpp.Zdrowotna.Prac;
        labelEmerFirma.EditValue = lpp.Emerytalna.Firma;
        labelRentFirma.EditValue = lpp.Rentowa.Firma;
        labelChorFirma.EditValue = lpp.Chorobowa.Firma;
        labelWypadFirma.EditValue = lpp.Wypadkowa.Firma;
        labelZdrowFirma.EditValue = lpp.Zdrowotna.Firma;
        labelFP.EditValue = lpp.FP.Firma;
        labelFGSP.EditValue = lpp.FGSP.Firma;
        labelFEP.EditValue = lpp.FEP.Firma;
        labelZaliczka.EditValue = lpp.ZalFis;
        labelKoszty.EditValue = lpp.Koszty + lpp.KosztyProcent + lpp.Koszty50;
        labelUlga.EditValue = lpp.Ulga;
			
        labelPrac.EditValue = lpp.Emerytalna.Prac + lpp.Rentowa.Prac + lpp.Chorobowa.Prac + lpp.Wypadkowa.Prac;
        labelFirma.EditValue = lpp.Emerytalna.Firma + lpp.Rentowa.Firma + lpp.Chorobowa.Firma + lpp.Wypadkowa.Firma + lpp.FP.Firma + lpp.FGSP.Firma + lpp.FEP.Firma;
			
		decimal wartosc = 0m;
		decimal ror = 0m;		
		Hashtable elements = new Hashtable();
		PitTotal[] pitTotal = new PitTotal[] { new PitTotal("PIT 4"), new PitTotal("PIT 8A"), new PitTotal("PIT 8B"), new PitTotal("Inne") } ;
            		
		foreach (Wyplata wyplata in lista.Wyplaty) {
			bool umowa = wyplata is WyplataUmowa;
			wartosc += wyplata.Wartosc.Value;
			ror += wyplata.Inne.Value;
			foreach (WypElement element in wyplata.Elementy) {
				Elem elem = (Elem)elements[element.Definicja];
				if (elem==null)
					elements.Add(element.Definicja, elem = new Elem(element.Definicja));
				elem.Add(element.Wartosc);

				if (element.Definicja.Info.Opodatkowany) {
					PozycjaPIT pozpit = element.Definicja.Deklaracje.PozycjaPIT;
					if (pozpit!=null)
						if (umowa && pozpit.PIT8A>0)
							pitTotal[1].Add(element);
						else if (umowa && pozpit.PIT8B>0)
							pitTotal[2].Add(element);
						else if (pozpit.PIT4>0)
							pitTotal[0].Add(element);
						else
							pitTotal[4].Add(element);
	            
				}
			}
		}

        labelGotowka.EditValue = wartosc - ror;
        labelROR.EditValue = ror;
			
        ArrayList arr = new ArrayList(elements.Values);
        arr.Sort();
        Grid2.DataSource = arr;
    
        arr = new ArrayList();
        foreach (PitTotal pt in pitTotal)
			if (pt.Brutto>0)
				arr.Add(pt);
        Grid3.DataSource = arr;
    }

		</script>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<meta content="Microsoft Visual Studio 7.0" name="GENERATOR">
		<meta content="C#" name="CODE_LANGUAGE">
		<meta content="JavaScript" name="vs_defaultClientScript">
		<meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema">
	</HEAD>
	<body>
		<form id="PełnaListaPłac" method="post" runat="server">
			<ea:datacontext id="dc" runat="server" OnContextLoad="dc_ContextLoad" TypeName="Soneta.Place.ListaPlac, Soneta.KadryPlace"
				LeftMargin="-1" RightMargin="-1"></ea:datacontext>
			<cc1:reportheader NagłówekOddziału="NagłówekOddziału" id="ReportHeader1" title="Podsumowanie listy płac {0}|%NAZWA%%BUFOR%</strong>Wydział:<strong> {1}|</strong>Za okres:<strong> {2}|</strong>Data wypłaty:<strong> {3}"
				runat="server" DataMember0="Numer" DataMember1="Wydzial" DataMember2="Okres" DataMember3="DataWyplaty"></cc1:reportheader>
			<p>
				<STRONG><font face="Tahoma" size="2">Podsumowanie:</font> </STRONG>
				<table id="Table4" style="FONT-SIZE: 8pt; FONT-FAMILY: Tahoma; BORDER-COLLAPSE: collapse"
					borderColor="silver" width="60%" border="1">
					<tbody>
						<tr>
							<td align="center" width="20%">Składka</td>
							<td align="center" width="20%">Składki pracownika</td>
							<td align="center" width="20%">Składki pracodawcy</td>
							<td align="center" width="20%"></td>
							<td align="center" width="20%"></td>
						</tr>
						<tr>
							<td>Emerytalna:</td>
							<td align="right"><ea:datalabel id="labelEmerPrac" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td align="right"><ea:datalabel id="labelEmerFirma" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td>Zaliczka podatku:</td>
							<td align="right"><ea:datalabel id="labelZaliczka" runat="server" Format="{0:n}"></ea:datalabel></td>
						</tr>
						<tr>
							<td>Rentowa:</td>
							<td align="right"><ea:datalabel id="labelRentPrac" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td align="right"><ea:datalabel id="labelRentFirma" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td>Koszty uzyskania:</td>
							<td align="right"><ea:datalabel id="labelKoszty" runat="server" Format="{0:n}"></ea:datalabel></td>
						</tr>
						<tr>
							<td>Chorobowa:</td>
							<td align="right"><ea:datalabel id="labelChorPrac" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td align="right"><ea:datalabel id="labelChorFirma" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td>Ulga podatkowa:</td>
							<td align="right"><ea:datalabel id="labelUlga" runat="server" Format="{0:n}"></ea:datalabel></td>
						</tr>
						<tr>
							<td>Wypadkowa:</td>
							<td align="right"><ea:datalabel id="labelWypadPrac" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td align="right"><ea:datalabel id="labelWypadFirma" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td><strong>Gotówka:</strong></td>
							<td align="right"><ea:datalabel id="labelGotowka" runat="server" Format="{0:n}"></ea:datalabel></td>
						</tr>
						<tr>
							<td>FP:</td>
							<td></td>
							<td align="right"><ea:datalabel id="labelFP" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td><strong>ROR:</strong></td>
							<td align="right"><ea:datalabel id="labelROR" runat="server" Format="{0:n}"></ea:datalabel></td>
						</tr>
						<tr>
							<td>FGŚP:</td>
							<td></td>
							<td align="right"><ea:datalabel id="labelFGSP" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td><STRONG>Razem:</STRONG></td>
							<td align="right"><ea:datalabel id="labelRazem" runat="server" Format="{0:n}"></ea:datalabel></td>
						</tr>
						<tr>
							<td>FEP:</td>
							<td align="right">&nbsp;</td>
							<td align="right"><ea:datalabel id="labelFEP" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td>&nbsp;</td>
							<td>&nbsp;</td>
						</tr>
						<tr>
							<td><strong>Razem składki:</strong></td>
							<td align="right"><ea:datalabel id="labelPrac" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td align="right"><ea:datalabel id="labelFirma" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td></td>
							<td></td>
						</tr>
						<tr>
							<td>Zdrowotna:</td>
							<td align="right"><ea:datalabel id="labelZdrowPrac" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td align="right"><ea:datalabel id="labelZdrowFirma" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td></td>
							<td></td>
						</tr>
					</tbody>
				</table>
			</p>
			<p>
				<font face="Tahoma" size="2"><STRONG>Zestawienie elementów:</STRONG></font><br>
				<ea:Grid id="Grid2" runat="server">
					<COLUMNS>
						<ea:GridColumn id="col2LP" DataMember="#" Caption="Lp" Align="Right" Width="4"></ea:GridColumn>
						<ea:GridColumn id="col2Name" DataMember="Name" Caption="Nazwa" Width="35" Total="Info"></ea:GridColumn>
						<ea:GridColumn id="col2Counter" DataMember="Counter" Caption="Liczba" Align="Right" Width="10"
							Total="Sum"></ea:GridColumn>
						<ea:GridColumn id="col2Dodatki" DataMember="Dodatki" Format="{0:n}" Align="Right" Width="12" Total="Sum"></ea:GridColumn>
						<ea:GridColumn id="col2Potr" DataMember="Potrącenia" Format="{0:n}" Align="Right" Width="12" Total="Sum"></ea:GridColumn>
						<ea:GridColumn id="col2Razem" DataMember="Razem" Format="{0:n}" Align="Right" Width="12" Total="Sum"></ea:GridColumn>
					</COLUMNS>
				</ea:Grid>
			</p>
			<ea:PageBreak id="PageBreak2" runat="server" Required="False"></ea:PageBreak>
			<p>
				<font face="Tahoma" size="2"><STRONG>Zestawienie zaliczki podatku lub podatku wg 
						deklaracji PIT:</STRONG></font><BR>
				<ea:Grid id="Grid3" runat="server" WithSections="False">
					<COLUMNS>
						<ea:GridColumn DataMember="#" Caption="Lp" Align="Right" Width="4"></ea:GridColumn>
						<ea:GridColumn DataMember="Nazwa" Caption="Deklaracja" Width="35" Total="Info"></ea:GridColumn>
						<ea:GridColumn DataMember="Brutto" Format="{0:n}" Caption="Brutto" Align="Right" Width="12" Total="Sum"></ea:GridColumn>
						<ea:GridColumn DataMember="Zaliczka" Format="{0:n}" Caption="Zaliczka podatku lub podatek" Align="Right"
							Width="12" Total="Sum"></ea:GridColumn>
					</COLUMNS>
				</ea:Grid>
			</p>
			<cc1:reportfooter id="ReportFooter1" runat="server">
				<CELLS>
					<cc1:FooterCell id="cellBrutto" Caption="Opodatkowane (brutto):" Format1="{0:u},"></cc1:FooterCell>
					<cc1:FooterCell id="cellNetto" Caption="Do wypłaty (netto):" Format1="{0:u},"></cc1:FooterCell>
				</CELLS>
				<SUBTITLES>
					<cc1:FooterSubtitle Caption="Sprawdzono pod względem merytorycznym" Width="50" SubtitleType="DataPodpis"></cc1:FooterSubtitle>
					<cc1:FooterSubtitle Caption="Sprawdzono pod względem formalno prawnym" Width="50" SubtitleType="DataPodpis"></cc1:FooterSubtitle>
					<cc1:FooterSubtitle id="stOperator" SubtitleType="Operator"></cc1:FooterSubtitle>
					<cc1:FooterSubtitle Caption="data"></cc1:FooterSubtitle>
					<cc1:FooterSubtitle Caption="główny księgowy"></cc1:FooterSubtitle>
					<cc1:FooterSubtitle Caption="kierownik jednostki"></cc1:FooterSubtitle>
				</SUBTITLES>
			</cc1:reportfooter>
		</form>
	</body>
</HTML>
