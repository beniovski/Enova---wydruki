<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ Page Language="c#" CodePage="1200" %><%@ Register TagPrefix="cc1" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %><%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %><%@ import Namespace="Soneta.Types" %><%@ import Namespace="Soneta.Tools" %><%@ import Namespace="Soneta.Kadry" %><%@ Import Namespace="Soneta.Core" %><%@ import Namespace="Soneta.Business" %><HTML 
xmlns:o = "urn:schemas-microsoft-com:office:office"><HEAD><TITLE>Badania lekarskie - wstępne</TITLE>
<SCRIPT runat="server">

    public class SrParams : SerializableContextBase {
        public SrParams(Context context) : base(context) {
        }

        bool pelneStanowisko = false;
        [Priority(1)]
        [Caption("Stanowisko pełna nazwa")]
        public bool PelneStanowisko {
            get { return pelneStanowisko; }
            set {
                pelneStanowisko = value;
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

    public enum RodzajBadań {
        wstępne, okresowe, kontrolne
    }

    public class Params : ContextBase {
        public Params(Context context) : base(context) {
        }

        RodzajBadań rodzaj = RodzajBadań.wstępne;
        [Priority(1)]
        [Caption("Rodzaj badań")]
        public RodzajBadań Rodzaj {
            get { return rodzaj; }
            set {
                rodzaj = value;
                OnChanged(EventArgs.Empty);
            }
        }

        int iloscKopii = 2;
        [Priority(2)]
        [Caption("Ilość kopii")]
        public int IloscKopii {
            get { return iloscKopii; }
            set {
                if (value <= 0)
                    value = 2;
                iloscKopii = value;
                OnChanged(EventArgs.Empty);
            }
        }
    }

    Params pars;
    [Context]
    public Params Pars {
        get { return pars; }
        set { pars = value; }
    }

    string przekreśl = "<font style=\"text-decoration: line-through\">{0}</font>";

    protected void dc_ContextLoad(object sender, EventArgs e) {
        PracHistoria ph = (PracHistoria)dc[typeof(PracHistoria)];
        string rodzaj = string.Format(pars.Rodzaj != RodzajBadań.wstępne ? przekreśl : "{0}", RodzajBadań.wstępne) + "/" +
            string.Format(pars.Rodzaj != RodzajBadań.okresowe ? przekreśl : "{0}", RodzajBadań.okresowe) + "/" +
            string.Format(pars.Rodzaj != RodzajBadań.kontrolne ? przekreśl : "{0}", RodzajBadań.kontrolne);
        ReportHeader1["RODZAJ"] = rodzaj;
        
        ReportHeader1["MIEJSCOWOSC"] = GetMiejscowosc(ph);
        if (ph.PESEL != "")
            fieldPESEL.EditValue = ph.PESEL;
        else
            fieldPESEL.EditValue = ph.Dokument.SeriaNumer;
        if (ph.AdresZamieszkania.Ulica.Length > 0) {
            fieldUlica.EditValue = "ul." + ph.AdresZamieszkania.Ulica;
            fieldNrDomuLokalu.EditValue = ph.AdresZamieszkania.NrDomu;
            fieldNrDomuLokalu.EditValue += (ph.AdresZamieszkania.NrLokalu.Length > 0) ? ("/" + ph.AdresZamieszkania.NrLokalu) : "";
            fieldMiejscowosc.EditValue = ph.AdresZamieszkania.Miejscowosc;
            fieldKodPocztowy.EditValue = ph.AdresZamieszkania.KodPocztowyS;
            fieldPoczta.EditValue = ph.AdresZamieszkania.Poczta;
        } else {
            fieldUlica.EditValue = "ul." + ph.AdresZameldowania.Ulica;
            fieldNrDomuLokalu.EditValue = ph.AdresZameldowania.NrDomu;
            fieldNrDomuLokalu.EditValue += (ph.AdresZameldowania.NrLokalu.Length > 0) ? ("/" + ph.AdresZameldowania.NrLokalu) : "";
            fieldMiejscowosc.EditValue = ph.AdresZameldowania.Miejscowosc;
            fieldKodPocztowy.EditValue = ph.AdresZameldowania.KodPocztowyS;
            fieldPoczta.EditValue = ph.AdresZameldowania.Poczta;
        }
        labelStanowisko.EditValue = GetStanowisko(ph);

        ArrayList al = new ArrayList();
        for (int i = 0; i < pars.IloscKopii; i++)
            al.Add(ph);
        DataRepeater1.DataSource = al;
    }

    string GetStanowisko(PracHistoria ph) {
        string stanowiskoPelne = "";
        if (srpars.PelneStanowisko)
            stanowiskoPelne = ph.Etat.StanowiskoPełne;
        if (stanowiskoPelne.Length == 0)
            stanowiskoPelne = ph.Etat.Stanowisko;
        return stanowiskoPelne;
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
</SCRIPT>

<META name=GENERATOR content="Microsoft Visual Studio 7.0">
<META name=CODE_LANGUAGE content=C#>
<META name=vs_defaultClientScript content=JavaScript>
<META name=vs_targetSchema 
content=http://schemas.microsoft.com/intellisense/ie5></HEAD>
<BODY>
<FORM id=BadaniaLekarskieWstępne method=post runat="server"><ea:datacontext id="dc" runat="server" TypeName="Soneta.Kadry.PracHistoria, Soneta.KadryPlace" OnContextLoad="dc_ContextLoad"></ea:datacontext><ea:DataRepeater ID="DataRepeater1" runat="server" RowTypeName="Soneta.Kadry.PracHistoria, Soneta.KadryPlace" Width="100%">
        <ea:SectionMarker ID="SectionMarker1" runat="server"></ea:SectionMarker>
	    <ea:PageBreak ID="PageBreak1" runat="server" BreakFirstTimes="False" ResetPageCounter="True"></ea:PageBreak>
        <cc1:ReportHeader NagłówekOddziału="NagłówekOddziału" id="ReportHeader1" title="SKIEROWANIE NA BADANIA LEKARSKIE|(%RODZAJ%*)|%MIEJSCOWOSC%, {0}" runat="server" DataMember0="Context.ActualDate.Actual"></cc1:ReportHeader>
        <font face="Tahoma" size="2">
        <p style="text-align:justify">
            <br />
            Działając na podstawie art. 229 § 4a ustawy z dnia 26 czerwca 1974 r. – Kodeks pracy (Dz. U. z 2016 r. poz. 1666), kieruję na badania lekarskie:
            <br />
            <ea:DataLabel id="DataLabel6" runat="server" DataMember="Plec" Bold="False">
                <ValuesMap>
                    <ea:ValuesPair Key="Kobieta" Value="Panią"></ea:ValuesPair>
                    <ea:ValuesPair Key="Mężczyzna" Value="Pana"></ea:ValuesPair>
                </ValuesMap>
            </ea:DataLabel>
            <ea:DataLabel id="DataLabel5" runat="server" DataMember="Pracownik.ImięNazwisko"></ea:DataLabel>,
            <br />
            nr PESEL **)
            <ea:DataLabel id="fieldPESEL" runat="server"></ea:DataLabel>,
            <br />
            <ea:DataLabel id="DataLabel22" runat="server" DataMember="Plec" Bold="False">
                <ValuesMap>
                    <ea:ValuesPair Key="Kobieta" Value="zamieszkałą"></ea:ValuesPair>
                    <ea:ValuesPair Key="Mężczyzna" Value="zamieszkałego"></ea:ValuesPair>
                </ValuesMap>
            </ea:DataLabel>
            <ea:DataLabel id="fieldUlica" runat="server"></ea:DataLabel>
            <ea:DataLabel id="fieldNrDomuLokalu" runat="server"></ea:DataLabel>
            <ea:DataLabel id="fieldMiejscowosc" runat="server"></ea:DataLabel>,
            <ea:DataLabel id="fieldKodPocztowy" runat="server"></ea:DataLabel>
            <ea:DataLabel id="fieldPoczta" runat="server"></ea:DataLabel>,
            <br />
            <ea:DataLabel id="DataLabel1" runat="server" DataMember="Plec" Bold="False">
                <ValuesMap>
                    <ea:ValuesPair Key="Kobieta" Value="zatrudnioną"></ea:ValuesPair>
                    <ea:ValuesPair Key="Mężczyzna" Value="zatrudnionego"></ea:ValuesPair>
                </ValuesMap>
            </ea:DataLabel>
            lub
            <ea:DataLabel id="DataLabel4" runat="server" DataMember="Plec" Bold="False">
                <ValuesMap>
                    <ea:ValuesPair Key="Kobieta" Value="podejmującą"></ea:ValuesPair>
                    <ea:ValuesPair Key="Mężczyzna" Value="podejmującego"></ea:ValuesPair>
                </ValuesMap>
            </ea:DataLabel>
            pracę na stanowisku lub stanowiskach pracy
            <ea:DataLabel id="labelStanowisko" runat="server"></ea:DataLabel>
            <br />
            określenie stanowiska/stanowisk*) pracy***): 
            . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
            . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
            . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
            . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
            . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
            . . . . . . . . . . . . . . . . . . . . . .
            <br /><br />
            Opis warunków pracy uwzględniający informacje o występowaniu na stanowisku lub stanowiskach pracy czynników niebezpiecznych,
            szkodliwych dla zdrowia lub czynników uciążliwych i innych wynikających ze sposobu wykonywania pracy, z podaniem wielkości narażenia
            oraz aktualnych wyników badań i pomiarów czynników szkodliwych dla zdrowia, wykonanych na tym stanowisku/stanowiskach – należy wpisać
            nazwę czynnika/czynników i wielkość/wielkości narażenia****):
            <br /><br /><br />
            I.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Czynniki fizyczne:
            <br /><br />
            II.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Pyły:
            <br /><br />
            III.&nbsp;&nbsp;&nbsp;&nbsp;Czynniki chemiczne:
            <br /><br />
            IV.&nbsp;&nbsp;&nbsp;&nbsp;Czynniki biologiczne:
            <br /><br />
            V.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Inne czynniki, w tym niebezpieczne:
            <br /><br />
            Łączna liczba czynników niebezpiecznych, szkodliwych dla zdrowia lub czynników uciążliwych i innych wynikających ze sposobu wykonywania pracy wskazanych w skierowaniu:
        </p>
    	</font>
        <br /><br /><br />
        <cc1:ReportFooter id="ReportFooter2" runat="server" TheEnd="False">
            <Subtitles>
                <cc1:FooterSubtitle SubtitleType="Empty" Width="50"></cc1:FooterSubtitle>
                <cc1:FooterSubtitle Caption="podpis pracodawcy" Width="50"></cc1:FooterSubtitle>
            </Subtitles>
        </cc1:ReportFooter>
        <br /><br /><br />
		<font face="Tahoma" size="1">
        <p style="text-align:left">
            Objaśnienia:
            <br />
            *) Niepotrzebne skreślić.
            <br />
            **) W przypadku osoby, której nie nadano numeru PESEL – seria, numer i nazwa dokumentu potwierdzającego tożsamość, a w przypadku osoby przyjmowanej do pracy – data urodzenia.
            <br />
            ***) Opisać: rodzaj pracy, podstawowe czynności, sposób i czas ich wykonywania.
            <br />
            ****) Opis warunków pracy uwzględniający w szczególności przepisy:
            <br />
            &nbsp;&nbsp;&nbsp;1) wydane na podstawie: 
            <br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;a) art. 222 § 3 ustawy z dnia 26 czerwca 1974 r. – Kodeks pracy dotyczące wykazu substancji chemicznych, ich mieszanin, czynników lub procesów technologicznych o działaniu rakotwórczym lub mutagennym,
            <br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;b) art. 222<span style="vertical-align: super">1)</span> § 3 ustawy z dnia 26 czerwca 1974 r. – Kodeks pracy dotyczące wykazu szkodliwych czynników biologicznych,
            <br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;c) art. 227 § 2 ustawy z dnia 26 czerwca 1974 r. – Kodeks pracy dotyczące badań i pomiarów czynników szkodliwych dla zdrowia, 
            <br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;d) art. 228 § 3 ustawy z dnia 26 czerwca 1974 r. – Kodeks pracy dotyczące wykazu najwyższych dopuszczalnych stężeń i natężeń czynników szkodliwych dla zdrowia 
            w środowisku pracy,
            <br />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;e) art. 25 pkt 1 ustawy z dnia 29 listopada 2000 r. – Prawo atomowe (Dz. U. z 2014 r. poz. 1512, z późn. zm.) dotyczące dawek granicznych promieniowania jonizującego; 
            <br />
            &nbsp;&nbsp;&nbsp;2) załącznika nr 1 do rozporządzenia Ministra Zdrowia i Opieki Społecznej z dnia 30 maja 1996 r. 
            w sprawie przeprowadzania badań lekarskich pracowników, zakresu profilaktycznej opieki zdrowotnej nad pracownikami oraz orzeczeń lekarskich wydawanych do celów przewidzianych 
            w Kodeksie pracy (Dz. U. z 2016 r. poz. 2067)
            <br /><br /><br />
            Skierowanie na badania lekarskie jest wydawane w dwóch egzemplarzach, z których jeden otrzymuje osoba kierowana na badania. 
        </p>
	</font>
    </ea:DataRepeater> 
</FORM></BODY></HTML>
