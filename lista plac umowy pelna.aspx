        <%@ import Namespace="Soneta.Core" %>
<%@ import Namespace="Soneta.Business" %>
<%@ import Namespace="Soneta.Tools" %>
<%@ import Namespace="Soneta.Types" %>
<%@ import Namespace="Soneta.Kadry" %>
<%@ import Namespace="Soneta.Place" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %>
<%@ Register TagPrefix="cc1" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %>
<%@ Page Language="c#" CodePage="1200" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<HTML>
	<HEAD>
		<title>Pełna lista płac</title>
		<script runat="server">
    
    public class Params : ContextBase {
    
        public Params(Context cx) : base(cx) {
        }
    
        bool paski = false;
    
        [Caption("Osobne paski wypłat")]
        [Priority(2)]
        public bool Paski {
            get { return paski; }
            set { paski = value; }
        }
    
        bool sumy = false;
    
        [Caption("Suma dla pracownika")]
        [Priority(3)]
        public bool Sumy {
            get { return sumy; }
            set { sumy = value; }
        }
    }

    public class SrParams : SerializableContextBase {
        public SrParams(Context context): base(context) {
        }

        //static bool fundusze = false;
        bool fundusze = false;
        [Priority(1)]
        [Caption("Fundusze")]
        public bool Fundusze {
            get { return fundusze; }
            set {
                fundusze = value;
                OnChanged(EventArgs.Empty);
            }
        }
        
        //static bool hideOperator = false;
        bool hideOperator = false;
        [Priority(2)]
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
        [Priority(3)]
        [Caption("Nazwa w nagłówku")]
        public bool NazwaWNaglowku {
            get { return nazwaWNaglowku; }
            set {
                nazwaWNaglowku = value;
                OnChanged(EventArgs.Empty);
            }
        }
        
        //Na wydruku umieszczaj numer umowy
        //static bool tytulUmowy = false;
        bool tytulUmowy = false;
        [Priority(4)]
        [Caption("Numer umowy")]
        public bool TytulUmowy {
            get { return tytulUmowy; }
            set {
                tytulUmowy = value;
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
		                
    Currency brutto = 0;
    Currency wyplata = 0;
    Hashtable elements = new Hashtable();
    
    decimal sumaEmerPrac = 0;
    decimal sumaRentPrac = 0;
    decimal sumaChorPrac = 0;
    decimal sumaWypadPrac = 0;
    decimal sumaZdrowPrac = 0;
    decimal sumaEmerFirma = 0;
    decimal sumaRentFirma = 0;
    decimal sumaChorFirma = 0;
    decimal sumaWypadFirma = 0;
    decimal sumaZdrowFirma = 0;
    decimal sumaFP = 0;
    decimal sumaFGSP = 0;
    decimal sumaFEP = 0;
    decimal sumaZaliczka = 0;
    decimal sumaKoszty = 0;
    decimal sumaUlga = 0;
    decimal sumaVAT = 0;
    Currency sumaGotowka = 0;
    Currency sumaROR = 0;
    
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

    PitTotal[] pitTotal = new PitTotal[] { new PitTotal("PIT-4R"), new PitTotal("PIT-8AR"), new PitTotal("Inne") };

            class PodsumowanieVAT : IComparable<PodsumowanieVAT> {
                DefinicjaStawkiVat definicjaStawki;
                decimal netto, vat;
                public PodsumowanieVAT(DefinicjaStawkiVat definicjaStawki) {
                    this.definicjaStawki = definicjaStawki;
                }
                public void Add(WypElement element) {
                    if (element.Podatki.VAT.DefinicjaStawki != definicjaStawki)
                        throw new ArgumentException("Element z niezgodną definicją stawki VAT " + element + ".");
                    netto += element.Podatki.VAT.Podstawa;
                    vat += element.Podatki.VAT.Podatek;
                }
                public DefinicjaStawkiVat Stawka {
                    get { return definicjaStawki; }
                }

                public decimal Netto {
                    get { return netto; }
                }
                public decimal VAT {
                    get { return vat; }
                }
                public decimal Brutto {
                    get { return netto + vat; }
                }
                public int CompareTo(PodsumowanieVAT other) {
                    if (other == null)
                        return 1;
                    return definicjaStawki.Kod.CompareTo(other.definicjaStawki.Kod);
                }
            }

            Dictionary<DefinicjaStawkiVat, PodsumowanieVAT> podsumowanieVAT = new Dictionary<DefinicjaStawkiVat, PodsumowanieVAT>();
		    
    private void Grid_BeforeRow(object sender, Soneta.Web.RowEventArgs args) {
        WyplataUmowa wypłata = args.Row as WyplataUmowa;
        if (wypłata==null)
            throw new InvalidOperationException("Lista płac umów może być drukowana tylko dla wypłat umów. "+args.Row);
    
		string nazimie = string.Format("<strong>{0}</strong><br>{1}", 
			wypłata.PracHistoria.Nazwisko,
			wypłata.PracHistoria.Imie);
		if (wypłata.Umowa!=null) {
			nazimie += "<br><br>" + wypłata.Umowa.Numer;
			if (srpars.TytulUmowy)
				nazimie += "<br>" + wypłata.Umowa.Tytul;
		}
				
        colNazImie.EditValue = nazimie;
        colOkres.EditValue = wypłata.ListaPlac.Okres;
    
        decimal emerP = 0, rentP = 0, chorP = 0, wypadP = 0;
        decimal emerF = 0, rentF = 0, chorF = 0, wypadF = 0;
        decimal fis = 0, zdrow = 0, koszty = 0, ulga = 0, vat = 0;
        decimal sumaOpodat = 0, sumaNieOpodat = 0;
        decimal fp = 0, fgsp = 0, fep=0;
        foreach (WypElement element in wypłata.ElementyWgKolejności) {
            colElementy.AddLine(element.Nazwa);
            if (element.Definicja.Deklaracje.Zaliczka.Typ == TypZaliczkiPodatku.NieNaliczać) {
                colNieOpodat.AddLine("{0:n}", element.Wartosc);
                colOpodat.AddLine();
                sumaNieOpodat += element.Wartosc;
            }
            else {
                brutto += element.Wartosc;
                colOpodat.AddLine("{0:n}", element.Wartosc);
                colNieOpodat.AddLine();
                sumaOpodat += element.Wartosc;

                PozycjaPIT pozpit = element.Definicja.Deklaracje.PozycjaPIT;
                if (pozpit != null)
                    /*if (pozpit.PIT8A>0)
                        pitTotal[0].Add(element);
                    else if (pozpit.PIT8B>0)
                        pitTotal[1].Add(element);
                    else
                        pitTotal[2].Add(element);*/
                    if (pozpit.PIT8AR > 0 && element.Podatek)            //TID: 7342
                        pitTotal[1].Add(element);
                    else if (pozpit.PIT4R > 0 && element.ZaliczkaPodatku)
                        pitTotal[0].Add(element);
                    else
                        pitTotal[2].Add(element);
            }

            if (element.Podatki.VAT.DefinicjaStawki != null) {
                PodsumowanieVAT ep;
                if (!podsumowanieVAT.TryGetValue(element.Podatki.VAT.DefinicjaStawki, out ep))
                    podsumowanieVAT.Add(element.Podatki.VAT.DefinicjaStawki, ep = new PodsumowanieVAT(element.Podatki.VAT.DefinicjaStawki));
                ep.Add(element);
            }                    
            
            emerP += element.Podatki.Emerytalna.Prac;
            rentP += element.Podatki.Rentowa.Prac;
            chorP += element.Podatki.Chorobowa.Prac;
            wypadP += element.Podatki.Wypadkowa.Prac;
    
            emerF += element.Podatki.Emerytalna.Firma;
            rentF += element.Podatki.Rentowa.Firma;
            chorF += element.Podatki.Chorobowa.Firma;
            wypadF += element.Podatki.Wypadkowa.Firma;
    
            fis += element.Podatki.ZalFIS;
            zdrow += element.Podatki.Zdrowotna.Prac;
            koszty += element.Podatki.KosztyPIT;
            ulga += element.Podatki.Ulga;
            vat += element.Podatki.VAT.Podatek;
    
            fp += element.Podatki.FP.Skladka;
            fgsp += element.Podatki.FGSP.Skladka;
            fep += element.Podatki.FEP.Skladka;
    
            Elem elem = (Elem)elements[element.Definicja];
            if (elem==null) {
                elem = new Elem(element.Definicja);
                elements[element.Definicja] = elem;
            }
            elem.Add(element.Wartosc);
    
            sumaEmerPrac += element.Podatki.Emerytalna.Prac;
            sumaRentPrac += element.Podatki.Rentowa.Prac;
            sumaChorPrac += element.Podatki.Chorobowa.Prac;
            sumaWypadPrac += element.Podatki.Wypadkowa.Prac;
            sumaZdrowPrac += element.Podatki.Zdrowotna.Prac;
    
            sumaEmerFirma += element.Podatki.Emerytalna.Firma;
            sumaRentFirma += element.Podatki.Rentowa.Firma;
            sumaChorFirma += element.Podatki.Chorobowa.Firma;
            sumaWypadFirma += element.Podatki.Wypadkowa.Firma;
            sumaZdrowFirma += element.Podatki.Zdrowotna.Firma;
    
            sumaFP += element.Podatki.FP.Skladka;
            sumaFGSP += element.Podatki.FGSP.Skladka;
            sumaFEP += element.Podatki.FEP.Skladka;
    
            sumaZaliczka += element.Podatki.ZalFIS;
            sumaKoszty += element.Podatki.KosztyPIT;
            sumaUlga += element.Podatki.Ulga;
            sumaVAT += element.Podatki.VAT.Podatek;
        }
        colNieOpodatSum.EditValue = sumaNieOpodat;
        colOpodatSum.EditValue = sumaOpodat;
    
        colZUS.AddLine("{0:n} E", emerP);
        colZUS.AddLine("{0:n} R", rentP);
        colZUS.AddLine("{0:n} C", chorP);
        if (wypadP!=0)
            colZUS.AddLine("{0:n} W", wypadP);
        colZUSSum.EditValue = emerP+rentP+chorP+wypadP;
    
        colZUSFirmy.AddLine("{0:n} E", emerF);
        colZUSFirmy.AddLine("{0:n} R", rentF);
        if (chorF!=0)
            colZUSFirmy.AddLine("{0:n} C", chorF);
        colZUSFirmy.AddLine("{0:n} W", wypadF);
        if (srpars.Fundusze) {
            colZUSFirmy.AddLine("{0:n} F", fp);
            colZUSFirmy.AddLine("{0:n} G", fgsp);
            colZUSFirmy.AddLine("{0:n} P", fep);
        }
        colZUSFirmySum.EditValue = emerF + rentF + chorF + wypadF + (srpars.Fundusze ? fp + fgsp + fep: 0m);
    
        colPodatki.AddLine("{0:n} &nbsp;&nbsp;", fis);
        colPodatki.AddLine("{0:n} Z", zdrow);
        colPodatki.AddLine("{0:n} K", koszty);
        colPodatki.AddLine("{0:n} U", ulga);
        colPodatki.AddLine("{0:n} V", vat);
        colPodatkiSum.EditValue = fis+zdrow;
    
        Currency ror = wypłata.Inne;
        colPodpis.AddLine(wypłata.Wartosc-ror);
        colPodpis.AddLine(ror);
        colPodpis.AddLine("");
        if (srpars.Fundusze && chorF!=0)
               colPodpis.AddLine("");
        colPodpis.AddLine("<center>.........................<br>(podpis)</center>");
    
        sumaGotowka += wypłata.Wartosc-ror;
        sumaROR += ror;
    
        wyplata += wypłata.Wartosc;
    }
    
    private void Grid_AfterRender(object sender, System.EventArgs e) {
        cellBrutto.EditValue = brutto;
        cellNetto.EditValue = wyplata;
    
        labelEmerPrac.EditValue = sumaEmerPrac;
        labelRentPrac.EditValue = sumaRentPrac;
        labelChorPrac.EditValue = sumaChorPrac;
        labelWypadPrac.EditValue = sumaWypadPrac;
        labelZdrowPrac.EditValue = sumaZdrowPrac;
        labelEmerFirma.EditValue = sumaEmerFirma;
        labelRentFirma.EditValue = sumaRentFirma;
        labelChorFirma.EditValue = sumaChorFirma;
        labelWypadFirma.EditValue = sumaWypadFirma;
        labelZdrowFirma.EditValue = sumaZdrowFirma;
        labelFP.EditValue = sumaFP;
        labelFGSP.EditValue = sumaFGSP;
        labelFEP.EditValue = sumaFEP;
        labelZaliczka.EditValue = sumaZaliczka;
        labelKoszty.EditValue = sumaKoszty;
        labelUlga.EditValue = sumaUlga;
        labelVAT.EditValue = sumaVAT;
        labelGotowka.EditValue = sumaGotowka;
        labelROR.EditValue = sumaROR;
        labelRazem.EditValue = sumaGotowka + sumaROR;

        labelPrac.EditValue = sumaEmerPrac + sumaRentPrac + sumaChorPrac + sumaWypadPrac;
        labelFirma.EditValue = sumaEmerFirma + sumaRentFirma + sumaChorFirma + sumaWypadFirma + sumaFP + sumaFGSP + sumaFEP;
    
        ArrayList arr = new ArrayList(elements.Values);
        arr.Sort();
        Grid2.DataSource = arr;
        Grid2.RowTypeName = typeof(Elem).AssemblyQualifiedName;
    
        ArrayList al = new ArrayList();
        foreach (PitTotal pt in pitTotal)
               if (pt.Brutto>0)
                   al.Add(pt);
        Grid3.DataSource = al;

        List<PodsumowanieVAT> lstvat = new List<PodsumowanieVAT>(podsumowanieVAT.Values);
        if (lstvat.Count == 0)
            SectionVat.Visible = false;
        else {
            SectionVat.Visible = true;
            lstvat.Sort();
            GridVat.DataSource = lstvat;
        }                    
    }
    
    [Context(Required=true)]
    public Params Parametry {
        set {
            if (value.Paski)
                Grid.ShowHeader = ShowHeader.EveryRow;
    
            if (!value.Sumy) {
                colOkres.Visible = false;
                colElementySum.Visible = false;
                colOpodatSum.Visible = false;
                colNieOpodatSum.Visible = false;
                colZUSSum.Visible = false;
                colZUSFirmySum.Visible = false;
                colPodatkiSum.Visible = false;
                colPodpis.RowSpan = 1;
                Grid.RowsInRow = 1;
            }
        }
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
		<font face="Tahoma">
			<form id="PełnaListaPłac" method="post" runat="server">
				<ea:datacontext id="dc" runat="server" RightMargin="-1" LeftMargin="-1" TypeName="Soneta.Place.ListaPlac, Soneta.KadryPlace"
					OnContextLoad="dc_ContextLoad"></ea:datacontext><cc1:reportheader NagłówekOddziału="NagłówekOddziału" id="ReportHeader1" title="Lista płac {0}|%NAZWA%%BUFOR%</strong>Wydział:<strong> {1}|</strong>Za okres:<strong> {2}|</strong>Data wypłaty:<strong> {3}"
					runat="server" DataMember3="DataWyplaty" DataMember2="Okres" DataMember1="Wydzial" DataMember0="Numer"></cc1:reportheader><ea:grid id="Grid" runat="server" onafterrender="Grid_AfterRender" onbeforerow="Grid_BeforeRow"
					RowsInRow="2" RowTypeName="Soneta.Place.WyplataEtat, Soneta.KadryPlace" DataMember="Wyplaty">
					<Columns>
						<ea:GridColumn Width="4" BottomBorder="Single" Align="Right" DataMember="Numer.Numer" Caption="Lp"
							ID="colLP"></ea:GridColumn>
						<ea:GridColumn ColSpan="2" Format="Za: {0}" ID="colOkres" NoWrap="True"></ea:GridColumn>
						<ea:GridColumn Width="26" BottomBorder="Single" Caption="Nazwisko i imię|Nr umowy" ID="colNazImie"
							VAlign="Top"></ea:GridColumn>
						<ea:GridColumn Width="26" BottomBorder="Single" Caption="Elementy płacy" ID="colElementy" NoWrap="True"
							VAlign="Top"></ea:GridColumn>
						<ea:GridColumn Align="Center" Format="Suma:" ID="colElementySum"></ea:GridColumn>
						<ea:GridColumn BottomBorder="Single" Align="Right" Caption="Elementy~opodatk." ID="colOpodat" VAlign="Top"></ea:GridColumn>
						<ea:GridColumn Align="Right" Format="{0:n}" ID="colOpodatSum"></ea:GridColumn>
						<ea:GridColumn BottomBorder="Single" Align="Right" Caption="Elementy~nieopodatk." ID="colNieOpodat"
							VAlign="Top"></ea:GridColumn>
						<ea:GridColumn Align="Right" Format="{0:n}" ID="colNieOpodatSum"></ea:GridColumn>
						<ea:GridColumn BottomBorder="Single" Align="Right" Caption="Składki ZUS~pracownika" ID="colZUS"
							VAlign="Top"></ea:GridColumn>
						<ea:GridColumn Align="Right" Format="{0:n}" ID="colZUSSum"></ea:GridColumn>
						<ea:GridColumn BottomBorder="Single" Align="Right" Caption="Składki ZUS~pracodawcy" ID="colZUSFirmy"
							VAlign="Top"></ea:GridColumn>
						<ea:GridColumn Align="Right" Format="{0:n}" ID="colZUSFirmySum"></ea:GridColumn>
						<ea:GridColumn BottomBorder="Single" Align="Right" Caption="Zal.US/Zdrow.|Koszty/Ulga|VAT" ID="colPodatki"
							VAlign="Top"></ea:GridColumn>
						<ea:GridColumn Align="Right" Format="{0:n} N" ID="colPodatkiSum"></ea:GridColumn>
						<ea:GridColumn Align="Right" Caption="Got&#243;wka|ROR" ID="colPodpis" RowSpan="2" VAlign="Top"></ea:GridColumn>
					</Columns>
				</ea:grid>
				<h6><font face="Tahoma" size="2"><ea:sectionmarker id="SectionMarker2" runat="server"></ea:sectionmarker>Podsumowanie:</font>
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
								<td style="HEIGHT: 16px">Chorobowa:</td>
								<td align="right"><ea:datalabel id="labelChorPrac" runat="server" Format="{0:n}"></ea:datalabel></td>
								<td align="right"><ea:datalabel id="labelChorFirma" runat="server" Format="{0:n}"></ea:datalabel></td>
								<td>Ulga podatkowa:</td>
								<td align="right"><ea:datalabel id="labelUlga" runat="server" Format="{0:n}"></ea:datalabel></td>
							</tr>
							<TR>
								<td>Wypadkowa:</td>
								<td align="right"><ea:datalabel id="labelWypadPrac" runat="server" Format="{0:n}"></ea:datalabel></td>
								<td align="right"><ea:datalabel id="labelWypadFirma" runat="server" Format="{0:n}"></ea:datalabel></td>
								<td>VAT:</td>
								<td align="right"><ea:datalabel id="labelVAT" runat="server" Format="{0:n}"></ea:datalabel></td>
							</TR>
							<tr>
								<td>FP:</td>
								<td></td>
								<td align="right"><ea:datalabel id="labelFP" runat="server" Format="{0:n}"></ea:datalabel></td>
								<td><strong>Gotówka:</strong></td>
								<td align="right"><ea:datalabel id="labelGotowka" runat="server" Format="{0:n}"></ea:datalabel></td>
							</tr>
							<tr>
								<td>FGŚP:</td>
								<td></td>
								<td align="right"><ea:datalabel id="labelFGSP" runat="server" Format="{0:n}"></ea:datalabel></td>
								<td><STRONG>ROR:</STRONG></td>
								<td align="right">
									<ea:datalabel id="labelROR" runat="server" Format="{0:n}"></ea:datalabel></td>
							</tr>
							<tr>
								<td>FEP:</td>
								<td align="right">&nbsp;</td>
								<td align="right">
		<font face="Tahoma">
			                        <ea:datalabel id="labelFEP" runat="server" Format="{0:n}"></ea:datalabel>
		</font>
		                        </td>
								<td>
		<font face="Tahoma">
			                        <STRONG>Razem:</STRONG></font></td>
								<td align="right">
		<font face="Tahoma">
			                        <ea:datalabel id="labelRazem" runat="server" Format="{0:n}"></ea:datalabel>
		</font>
		                        </td>
							</tr>
							<tr>
								<td><strong>Razem składki:</strong></td>
								<td align="right"><ea:datalabel id="labelPrac" runat="server" Format="{0:n}"></ea:datalabel></td>
								<td align="right"><ea:datalabel id="labelFirma" runat="server" Format="{0:n}"></ea:datalabel></td>
								<td>&nbsp;</td>
								<td align="right">&nbsp;</td>
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
				</h6>
				<h6><font face="Tahoma" size="2"><ea:sectionmarker id="SectionMarker1" runat="server"></ea:sectionmarker>Zestawienie 
						elementów:</font>
					<br>
					<ea:grid id="Grid2" runat="server">
						<Columns>
							<ea:GridColumn Width="4" Align="Right" DataMember="#" Caption="Lp" ID="col2LP"></ea:GridColumn>
							<ea:GridColumn Width="35" DataMember="Name" Total="Info" Caption="Nazwa" ID="col2Name"></ea:GridColumn>
							<ea:GridColumn Width="10" Align="Right" DataMember="Counter" Total="Sum" Caption="Liczba" ID="col2Counter"></ea:GridColumn>
							<ea:GridColumn Width="12" Align="Right" DataMember="Dodatki" Total="Sum" Format="{0:n}" ID="col2Dodatki"></ea:GridColumn>
							<ea:GridColumn Width="12" Align="Right" DataMember="Potrącenia" Total="Sum" Format="{0:n}" ID="col2Potr"></ea:GridColumn>
							<ea:GridColumn Width="12" Align="Right" DataMember="Razem" Total="Sum" Format="{0:n}" ID="col2Razem"></ea:GridColumn>
						</Columns>
					</ea:grid></h6>
		</font>
		<h6><ea:sectionmarker id="SectionMarker3" runat="server"></ea:sectionmarker><font face="Tahoma" size="2">Zestawienie 
				zaliczki podatku lub podatku wg deklaracji PIT: </font>
			<br>
			<ea:grid id="Grid3" runat="server">
				<Columns>
					<ea:GridColumn Width="4" Align="Right" DataMember="#" Caption="Lp"></ea:GridColumn>
					<ea:GridColumn Width="35" DataMember="Nazwa" Total="Info" Caption="Deklaracja"></ea:GridColumn>
					<ea:GridColumn Width="12" Align="Right" DataMember="Brutto" Total="Sum" Caption="Brutto" Format="{0:n}"></ea:GridColumn>
					<ea:GridColumn Width="12" Align="Right" DataMember="Zaliczka" Total="Sum" Caption="Zaliczka podatku lub podatek"
						Format="{0:n}"></ea:GridColumn>
				</Columns>
			</ea:grid><font face="Tahoma">
                <ea:Section ID="SectionVat" runat="server" Width="100%">
                    <p>
                        &nbsp;<ea:sectionmarker id="Sectionmarker5" runat="server">
                        </ea:SectionMarker>
                        <strong><font face="Tahoma" size="2">Zestawienie podatku VAT wg stawki</font> </strong>
                        <ea:Grid ID="GridVat" runat="server" WithSections="False">
                            <Columns>
                                <ea:GridColumn runat="server" Align="Right" Caption="Lp" DataMember="#" Width="4">
                                </ea:GridColumn>
                                <ea:GridColumn runat="server" Caption="Stawka" DataMember="Stawka" Total="Info" Width="35">
                                </ea:GridColumn>
                                <ea:GridColumn runat="server" Align="Right" Caption="Netto" DataMember="Netto" Format="{0:n}"
                                    Total="Sum" Width="12">
                                </ea:GridColumn>
                                <ea:GridColumn runat="server" Align="Right" Caption="VAT" DataMember="VAT" Format="{0:n}"
                                    Total="Sum" Width="12">
                                </ea:GridColumn>
                                <ea:GridColumn runat="server" Align="Right" Caption="Brutto" DataMember="Brutto"
                                    Format="{0:n}" Total="Sum" Width="12">
                                </ea:GridColumn>
                            </Columns>
                        </ea:Grid>
                    </p>
                </ea:Section>
                <ea:sectionmarker id="SectionMarker4" runat="server"></ea:sectionmarker><cc1:reportfooter id="ReportFooter1" runat="server">
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
				</cc1:reportfooter></font></h6>
			</form>
	</body>
</HTML>
