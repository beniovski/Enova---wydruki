<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ import Namespace="System.Globalization" %><%@ import Namespace="Soneta.Kadry" %><%@ import Namespace="Soneta.Core" %><%@ import Namespace="Soneta.Business" %><%@ import Namespace="Soneta.Types" %><%@ import Namespace="Soneta.Tools" %><%@ Register TagPrefix="cc1" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %><%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %><%@ Page Language="c#" CodePage="1200" %><HTML><HEAD><TITLE>Umowa o pracę</TITLE>
<SCRIPT runat="server">

	public enum StawkaNettoBrutto {
        brutto, netto
    }

    static string reprez = "";
		    
	public class _SrInfo: SerializableContextBase {

        public _SrInfo(Context context): base(context) {
        }
		
		string reprezentant = "";
        [Priority(10)]
		[Caption("Reprezent. pracodawcę")]
		public string Reprezentant {
            get { return reprezentant; }
			set {
                reprezentant = value;
                reprez = reprezentant;
				OnChanged(EventArgs.Empty);
			}
		}

        bool pelneStanowisko = false;
        [Priority(20)]
        [Caption("Stanowisko pełna nazwa")]
        public bool PelneStanowisko {
            get { return pelneStanowisko; }
            set {
                pelneStanowisko = value;
                OnChanged(EventArgs.Empty);
            }
        }
    
        bool pelnaFunkcja = false;
        [Priority(30)]
        [Caption("Funkcja pełna nazwa")]
        public bool PelnaFunkcja {
            get { return pelnaFunkcja; }
            set {
                pelnaFunkcja = value;
                OnChanged(EventArgs.Empty);
            }


        }
    }

    public class _Info : ContextBase {

        public _Info(Context context) : base(context) {
            stanNaDzien = ((ActualDate)context[typeof(ActualDate)]).Actual;
            if (reprezentant == "")
                reprezentant = KadryModule.GetInstance(context).Config.Wydruki.OsobaReprezentującaPracodawcę;
        }

        string reprezentant = reprez;
        [Priority(10)]
        [Caption("Reprezent. pracodawcę")]
        public string Reprezentant {
            get { return reprezentant; }
            set {
                reprezentant = value;
                OnChanged(EventArgs.Empty);
            }
        }

        StawkaNettoBrutto stawka;
        [Priority(20)]
        [Caption("Stawka")]
        public StawkaNettoBrutto Stawka {
            get { return stawka; }
            set {
                stawka = value;
                OnChanged(EventArgs.Empty);
            }
        }

        int iloscKopii = 1;
        [Priority(30)]
        [Caption("Ilość kopii")]
        public int IloscKopii {
            get { return iloscKopii; }
            set {
                if (value <= 0)
                    value = 1;
                iloscKopii = value;
                OnChanged(EventArgs.Empty);
            }
        }

        Date stanNaDzien;
        [Priority(40)]
        [Caption("Dodatki na dzień")]
        public Date StanNaDzien {
            get { return stanNaDzien; }
            set {
                stanNaDzien = value;
                OnChanged(EventArgs.Empty);
            }
        }
    }

    _Info info;
    [Context]
    public _Info Info {
        set { info = value; }
    }

    _SrInfo srinfo;
    [SettingsContext]
    public _SrInfo SrInfo {
        set { srinfo = value; }
    }

    void dc_ContextLoad(Object sender, EventArgs e) {
        PracHistoria ph = (PracHistoria)dc[typeof(PracHistoria)];
		
		dlReprezentant.EditValue = info.Reprezentant;
        labelNettoBrutto.EditValue = info.Stawka;
        labelStanowisko.EditValue = GetStanowisko(ph);
        labelFunkcja.EditValue = GetFunkcja(ph);
		    
        FromTo okres = ph.Etat.Okres;
        if (okres.To==Date.MaxValue)
            dlNaOkres.EditValue = string.Format("od <strong>{0}</strong>", okres.From);
        else
            dlNaOkres.EditValue = string.Format("od <strong>{0}</strong> do <strong>{1}</strong>", okres.From, okres.To);

        if (ph.Etat.MiejscePracy!="")
            dlMiejsce.EditValue = ph.Etat.MiejscePracy;
        else
            dlMiejsce.EditValue = GetMiejscowosc(ph);
            		
		labelRodzajStawki.EditValue = CaptionAttribute.EnumToString(ph.Etat.Zaszeregowanie.RodzajStawki).ToLower();
        if (ph.Etat.Wymiar == Fraction.One)
            DataLabel20.EditValue = "...............................................................................................................";
        else
            DataLabel20.EditValue = "Norma dobowa: <strong>" + ph.Etat.NormaDobowa + "</strong>" +
                ", norma tygodniowa: <strong>" + ph.Etat.NormaTygodniowa + "/" + ph.Etat.NormaDobowaTygodniowa + "</strong>";
		
		string ss = "";
		foreach (Dodatek d in ph.Pracownik.Dodatki) {
			DodHistoria dh = d[info.StanNaDzien];
            if (dh.Okres.Contains(info.StanNaDzien) && dh.Element.Dodatkowe.DodatekDoEtatu) 
				ss += string.Format("&nbsp;&nbsp;&nbsp;{0}{1}<br>", dh.Element.Nazwa, WarunkuDodatku(dh));
		}
		labelDodatki.EditValue = ss;			
            
        ReportHeader1["MIEJSCOWOSC"] = GetMiejscowosc(ph);
        DaneFirmy(ph);

        ArrayList al = new ArrayList();
        for (int i = 0; i < info.IloscKopii; i++)
            al.Add(ph);
        DataRepeater1.DataSource = al;
    }

    string GetStanowisko(PracHistoria ph) {
        string stanowiskoPelne = "";
        if (srinfo.PelneStanowisko)
            stanowiskoPelne = ph.Etat.StanowiskoPełne;
        if (stanowiskoPelne.Length == 0)
            stanowiskoPelne = ph.Etat.Stanowisko;
        return stanowiskoPelne;
    }

    string GetFunkcja(PracHistoria ph) {
        string funkcjaPelna = "";
        if (srinfo.PelnaFunkcja)
            funkcjaPelna = ph.Etat.FunkcjaPełna;
        if (funkcjaPelna.Length == 0)
            funkcjaPelna = ph.Etat.Funkcja;
        return funkcjaPelna;
    }

    string GetMiejscowosc(PracHistoria ph) {
        CoreModule core = CoreModule.GetInstance(dc);
        string miejscowosc = ReportHeader.GetPieczątka(dc).Adres.Miejscowosc;
        if (miejscowosc.Length == 0)
            miejscowosc = core.Config.Firma.AdresSiedziby.Miejscowosc;
        if (ph.Etat.Wydzial != null && ph.Etat.Wydzial.Oddzial != null) {
            OddzialFirmy of = ph.Etat.Wydzial.Oddzial;
            if (!string.IsNullOrEmpty(of.Adres.Miejscowosc)) miejscowosc = of.Adres.Miejscowosc;
        }                
        return miejscowosc;
    }
    
    void DaneFirmy(PracHistoria ph) {
        CoreModule core = CoreModule.GetInstance(dc);
        string regon = core.Config.Firma.Pieczątka.REGON;
        string nazwa = core.Config.Firma.Pieczątka.Nazwa;
        string adres = core.Config.Firma.AdresSiedziby.ToString();
        if (ph.Etat.Wydzial != null && ph.Etat.Wydzial.Oddzial != null) {
            OddzialFirmy of = ph.Etat.Wydzial.Oddzial;
            if (!string.IsNullOrEmpty(of.Deklaracje.REGON)) regon = of.Deklaracje.REGON;
            if (!string.IsNullOrEmpty(of.Nazwa)) nazwa = of.Nazwa;
            if (!string.IsNullOrEmpty(of.Adres.ToString())) adres = of.Adres.ToString();
        }
        PieczątkaREGON.EditValue = regon;
        PieczątkaNazwa.EditValue = nazwa;
        PieczątkaAdres.EditValue = adres;
    }

    void DataRepeater1_BeforeRow(Object sender, EventArgs args) {
    }

	string WarunkuDodatku(DodHistoria dh) {
		string ss = "";
		
		if (dh.Procent!=Percent.Zero)
			ss = DodajParametr(ss, dh.Element.Algorytm.DodProcent, dh.Procent);
			
		if (dh.Ulamek!=Fraction.Zero)
			ss = DodajParametr(ss, dh.Element.Algorytm.DodUlamek, dh.Ulamek);
			
		if (dh.Wspolczynnik!=0m)
			ss = DodajParametr(ss, dh.Element.Algorytm.DodWspolczynnik, dh.Wspolczynnik);

		if (dh.Podstawa!=Currency.Zero)
			ss = DodajParametr(ss, dh.Element.Algorytm.DodPodstawa, dh.Podstawa.ToString("u", CultureInfo.CurrentCulture));
			
		if (dh.Czas!=Time.Zero)
			ss = DodajParametr(ss, dh.Element.Algorytm.DodCzas, dh.Czas);
			
		if (dh.Dni!=0)
			ss = DodajParametr(ss, dh.Element.Algorytm.DodDni, dh.Dni);
			
		if (ss=="")
			return "";
		return "&nbsp;(" + ss + ")";
    }
    
    string DodajParametr(string ss, string label, object value) {
		if (ss!="")
			ss += ",&nbsp;";
		ss += string.Format("<strong>{1}</strong>", label.ToLower(), value);
		return ss;
    }

	static void Msg(object value) {
    }
		        
		</SCRIPT>

<META content="text/html; charset=unicode" http-equiv=Content-Type>
<META name=GENERATOR content="Microsoft Visual Studio 7.0">
<META name=CODE_LANGUAGE content=C#>
<META name=vs_defaultClientScript content=JavaScript>
<META name=vs_targetSchema 
content=http://schemas.microsoft.com/intellisense/ie5></HEAD>
<BODY>
<FORM id=UmowaOPracę method=post runat="server"><ea:DataContext runat="server" ID="dc" TypeName="Soneta.Kadry.PracHistoria,Soneta.KadryPlace" PageSize=""></ea:DataContext><ea:DataRepeater ID="DataRepeater1" runat="server" OnBeforeRow="DataRepeater1_BeforeRow"
                RowTypeName="Soneta.Kadry.PracHistoria, Soneta.KadryPlace" Width="100%" Height="161px">
            <ea:SectionMarker ID="SectionMarker9" runat="server"></ea:SectionMarker>
		    <ea:PageBreak ID="PageBreak1" runat="server" BreakFirstTimes="False" 
				ResetPageCounter="True"></ea:PageBreak>
			<cc1:ReportHeader NagłówekOddziału="NagłówekOddziału" id="ReportHeader1" 
                title="&lt;center&gt;UMOWA O PRACĘ&lt;/center&gt;|%MIEJSCOWOSC%, {0}" 
                DataMember0="Context.ActualDate.Actual"
                runat="server"></cc1:ReportHeader>
			<p></p>
            <font face="Tahoma" size="2">
			<table id="Table1" cellSpacing="0" width="100%" style="font-size: 10pt; font-family: tahoma">
				<tr>
					<td valign="top" align="left">
			            REGON-EKD:
                        <ea:datalabel id="PieczątkaREGON" runat="server"></ea:datalabel> 
                    </td>
                </tr>
				<tr>
					<td valign="top" align="left">
			            <br/>zawarta w dniu
				        <ea:datalabel id="DataLabel10" runat="server" DataMember="Etat.DataZawarcia"></ea:datalabel>
                    </td>
                </tr>
				<tr>
					<td>
                        <br/>między
					    <ea:datalabel id="PieczątkaNazwa" runat="server"></ea:datalabel>
					    , z siedzibą w
					    <ea:datalabel id="PieczątkaAdres" runat="server"></ea:datalabel>
					    reprezentowanym przez
						    <ea:datalabel id="dlReprezentant" runat="server" CssClass="style1"></ea:datalabel>
                    </td>
                </tr>
				<tr>
					<td>
                        <br/>a
						<ea:datalabel id="DataLabel5" runat="server" DataMember="Plec" Bold="False">
							<ValuesMap>
								<ea:ValuesPair Key="Kobieta" Value="Panią"></ea:ValuesPair>
								<ea:ValuesPair Key="Mężczyzna" Value="Panem"></ea:ValuesPair>
							</ValuesMap>
						</ea:datalabel>
				        <ea:datalabel id="DataLabel1" runat="server" 
                            DataMember="Pracownik.ImięNazwisko" ></ea:datalabel>
					        <ea:datalabel id="DataLabel6" runat="server" DataMember="Plec" Bold="False">
						        <ValuesMap>
							        <ea:ValuesPair Key="Kobieta" Value="zamieszkałą"></ea:ValuesPair>
							        <ea:ValuesPair Key="Mężczyzna" Value="zamieszkałym"></ea:ValuesPair>
						        </ValuesMap>
					        </ea:datalabel>
					        w 
				        <ea:datalabel id="DataLabel3" runat="server" DataMember="Adres"></ea:datalabel>.<br />
                        Numer ewidencyjny PESEL
                        <ea:datalabel id="Datalabel18" runat="server" DataMember="PESEL"></ea:datalabel>.
                    </td>
                </tr>
				<tr>
					<td>
                        <br/>
					    <ea:datalabel id="DataLabel13" runat="server" DataMember="Etat.TypUmowy"></ea:datalabel>
                        <ea:datalabel id="dlNaOkres" runat="server" Bold="False"></ea:datalabel>
					</td>
                </tr>
				<tr>
					<td>
                        <br/>1. Strony ustalają następujące warunki zatrudnienia:
					</td>
                </tr>
				<tr>
					<td>
                        <br/>1) rodzaj umówionej pracy:
					    <ea:datalabel id="labelStanowisko" runat="server"></ea:datalabel>
					    <ea:datalabel id="labelFunkcja" runat="server"></ea:datalabel>
                        <ea:datalabel DataMember="Etat.Specjalosc" runat="server"></ea:datalabel>
                    </td>
                </tr>
				<tr>
					<td>
                        <br/>2) miejsce wykonywania pracy:
					    <ea:datalabel id="dlMiejsce" runat="server"></ea:datalabel>
                    </td>
                </tr>
				<tr>
					<td>
                        <br/>3) wymiar czasu pracy:
					    <ea:datalabel id="DataLabel7" runat="server" DataMember="Etat.Zaszeregowanie.Wymiar"></ea:datalabel>
                    </td>
                </tr>
				<tr>
					<td>
                        <br/>4) wynagrodzenie:
					    <ea:datalabel id="DataLabel8" runat="server" DataMember="Etat.Zaszeregowanie.Stawka" Format="{0:u}"></ea:datalabel>
					    <ea:datalabel id="labelRodzajStawki" runat="server"></ea:datalabel>
					    <ea:datalabel id="labelNettoBrutto" runat="server"></ea:datalabel>
					    <br/>
						<ea:datalabel id="labelDodatki" runat="server" Bold="False"></ea:datalabel>
						...................................................................................................................
						<br/>
						...................................................................................................................
						<br/>
						(składniki wynagrodzenia i ich wysokość oraz podstawa prawna ich ustalenia)
                    </td>
                </tr>
				<tr>
					<td>
                        <br/>5) inne warunki zatrudnienia ........................................................................
						<br/>
						...................................................................................................................
						<br/>
						...................................................................................................................
                    </td>
                </tr>
				<tr>
					<td>
                        <br/>6) 
					    <ea:datalabel id="DataLabel20" runat="server" Bold="False"></ea:datalabel>
                        <br/> 
						...................................................................................................................
                        <br/> 
						...................................................................................................................
                        <br/>(dopuszczalna liczba godzin pracy ponad określony w umowie wymiar czasu pracy, których
                        przekroczenie uprawnia pracownika, oprócz normalnego wynagrodzenia, do dodatku do
                        wynagrodzenia, o którym mowa w art. 151<sup>1</sup> § 1 Kodeksu pracy *)
                    </td>
                </tr>
    		    <tr>
					<td>
                        <br/>2. Termin rozpoczęcia pracy
					    <ea:datalabel id="DataLabel9" runat="server" DataMember="Etat.DataRozpPracy"></ea:datalabel>
                    </td>
                </tr>
    		    <tr>
					<td>
                        <br/>3. Przyczyny uzasadniające zawarcie umowy
					    <ea:datalabel id="DataLabel2" runat="server" DataMember="Etat.ZawarcieUmowy.PrzyczynaZawUmowyOpis"></ea:datalabel>
                        <br/>(informacja, o której mowa w art. 29 § 1<sup>1</sup> Kodeksu pracy, o obiektywnych
                        przyczynach uzasadniających zawarcie umowy o pracę na czas określony **)
                    </td>
                </tr>
            </table>
            <br />
	        <ea:pagebreak id="PageBreak2" runat="server" Required="False"></ea:pagebreak>
			<cc1:ReportFooter id="ReportFooter1" runat="server" TheEnd="False">
				<Subtitles>
					<cc1:FooterSubtitle Caption="data i podpis pracownika" Width="50"></cc1:FooterSubtitle>
					<cc1:FooterSubtitle Caption="(podpis pracodawcy lub osoby reprezentującej pracodawcę albo osoby upoważnionej do składania oświadczeń w imieniu pracodawcy)" Width="50"></cc1:FooterSubtitle>
				</Subtitles>
			</cc1:ReportFooter>
            <p>
            * Dotyczy umowy o pracę z pracownikiem zatrudnianym w niepełnym wymiarze czasu pracy.
            </p>
            <p>
            ** Dotyczy umowy o pracę z pracownikiem zatrudnianym na podstawie umowy o pracę na czas określony w
            celu, o którym mowa w art. 25<sup>1</sup> § 4 pkt 1–3 Kodeksu pracy, lub w przypadku, o którym mowa w art. 25<sup>1</sup> § 4
            pkt 4 Kodeksu pracy.                
            </p>
        </font>
		<ea:SectionMarker ID="SectionMarker8" runat="server" SectionType="Footer"></ea:SectionMarker>
        </ea:DataRepeater> 
</FORM></BODY></HTML>
