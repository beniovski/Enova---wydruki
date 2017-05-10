<%@ Page Language="c#" CodePage="1200" %>
<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %>
<%@ Register TagPrefix="cc1" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %>
<%@ import Namespace="Soneta.Tools" %>
<%@ import Namespace="Soneta.Types" %>
<%@ import Namespace="Soneta.Business" %>
<%@ import Namespace="Soneta.Kadry" %>
<%@ import Namespace="Soneta.Place" %>
<%@ Import Namespace="Soneta.Core" %>

<script runat="server">

    public class _SrInfo : SerializableContextBase {
        public _SrInfo(Context context) : base(context) {
            if (pracodowca1 == "")
                pracodowca1 = KadryModule.GetInstance(context).Config.Wydruki.OsobaReprezentującaPracodawcę;
        }

        string pracodowca1 = "";
        [Caption("Reprez. pracodawcę 1")]
        [Priority(10)]
        public string Pracodowca1 {
            get { return pracodowca1; }
            set {
                if (pracodowca1.Length > 80)
                    pracodowca1 = pracodowca1.Substring(0, 80);
                pracodowca1 = value;
                OnChanged(EventArgs.Empty);
            }
        }

        string pracodowca2 = "";
        [Caption("Reprez. pracodawcę 2")]
        [Priority(20)]
        public string Pracodowca2 {
            get { return pracodowca2; }<asp:Menu runat="server"></asp:Menu>
            set {
                if (pracodowca2.Length > 80)
                    pracodowca2 = pracodowca2.Substring(0, 80);
                pracodowca2 = value;
                OnChanged(EventArgs.Empty);
            }
        }

        bool nrUmowa = false;
        [Caption("Numer umowy")]
        [Priority(30)]
        public bool NrUmowa {
            get { return nrUmowa; }
            set {
                nrUmowa = value;
                OnChanged(EventArgs.Empty);
            }
        }
    
        bool krs = true;
        [Caption("KRS")]
        [Priority(40)]
        public bool KRS {
            get { return krs; }
            set {
                krs = value;
                OnChanged(EventArgs.Empty);
            }
        }

        string sadPracy = "";
        [Caption("Sąd")]
        [Priority(50)]
        public string SadPracy {
            get { return sadPracy; }
            set {
                sadPracy = value;
                OnChanged(EventArgs.Empty);
            }
        }        
    }
    
    public class _Info : ContextBase {
        public _Info(Context context) : base(context) {
        }

        bool student = false;
        [Caption("Student poniżej 26 lat")]
        [Priority(10)]
        public bool Student {
            get { return student; }
            set {
                student = value;
                OnChanged(EventArgs.Empty);
            }
        }
		
        int iloscKopii = 2;
        [Priority(20)]
        [Caption("Ilość kopii umowy")]
        [ControlEdit("Soneta.Forms.Controls.ComboBox,Soneta.Forms")]
        public int IloscKopii {
            get { return iloscKopii; }
            set {
                iloscKopii = value;
                OnChanged(EventArgs.Empty);
            }
        }

        public object GetListIloscKopii() {
            return new int[]{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
        }

        bool rachunekUmowa = (umowaID != 0);
        [Caption("Rachunek do umowy")]
        [Priority(30)]
        public bool RachunekUmowa {
            get { return rachunekUmowa; }
            set {
                rachunekUmowa = value;
                OnChanged(EventArgs.Empty);
            }
        }

        public bool IsReadOnlyRachunekUmowa() {
            return (umowaID != 0);
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
    
    void dc_ContextLoad(Object sender, EventArgs e) {
        UmowaHistoria umowaHist = (UmowaHistoria)dc[typeof(UmowaHistoria)];
        Umowa umowa = umowaHist.Umowa;
        int paragraf = 0;

        PracHistoria ph = umowa.PracHistoria;
        DaneFirmy(ph);
        
        Datalabel2.Visible = ph.Dokument.Rodzaj != KodRodzajuDokumentu.Niezdefiniowany;
        KRSSection.Visible = srinfo.KRS;
        
        dlkopie.EditValue = info.IloscKopii;
        string kopieSl = "";
        switch (info.IloscKopii) {
            case 1: kopieSl = "jednym"; break;
            case 2: kopieSl = "dwóch"; break;
            case 3: kopieSl = "trzech"; break;
            case 4: kopieSl = "czterech"; break;
            case 5: kopieSl = "pięciu"; break;
            case 6: kopieSl = "sześciu"; break;
            case 7: kopieSl = "siedmiu"; break;
            case 8: kopieSl = "ośmiu"; break;
            case 9: kopieSl = "dziewięciu"; break;
            case 10: kopieSl = "dziesięciu"; break;
            default: kopieSl = "..."; break;
        }
        dlkopieslownie.EditValue = kopieSl;

        if (srinfo.NrUmowa)
            NumerUmowy.EditValue = "NR " + umowa.Numer.ToString();
        else
            NumerUmowy.Visible = false;
        
        if (umowa.Opis == "")
            tytul.EditValue = umowa.Tytul;
        else
            tytul.EditValue = umowa.Tytul + "<br>" + umowa.Opis;

        string strPkt1 = "</strong>1.&nbsp;&nbsp;<strong>";
        string strPkt2 = "</strong>2.&nbsp;&nbsp;<strong>";
        if (srinfo.Pracodowca1.Length > 0 && srinfo.Pracodowca2.Length == 0) {
            fieldPracodawca2.Visible = false;
            strPkt1 = "";
        }
        if (srinfo.Pracodowca2.Length > 0 && srinfo.Pracodowca1.Length == 0) {
            fieldPracodawca1.Visible = false;
            strPkt2 = "";
        }
       
        if (srinfo.Pracodowca1.Length > 0)
            fieldPracodawca1.EditValue = strPkt1 + srinfo.Pracodowca1;
        else
            fieldPracodawca1.EditValue = strPkt1 + ". . . . . . . . . . . . . . . . . . . . . . . . . . . . - [stanowisko służbowe] . . . . . . . . . . . . . . . . . . . . ,<br/>";
        if (fieldPracodawca1.Visible && fieldPracodawca2.Visible)
            fieldPracodawca1.EditValue += "<br/>";
        if (srinfo.Pracodowca2.Length > 0)
            fieldPracodawca2.EditValue = strPkt2 + srinfo.Pracodowca2;
        else
            fieldPracodawca2.EditValue = strPkt2 + ". . . . . . . . . . . . . . . . . . . . . . . . . . . . - [stanowisko służbowe] . . . . . . . . . . . . . . . . . . . . ,<br/>";
                
        if (info.Student) {
            DodatkowyParagraf.Visible = true;
            paragraf = 4;
        }
        else {
            DodatkowyParagraf.Visible = false;
            paragraf = 3;
        }
        paragraf1.EditValue = "§ " + (paragraf + 0).ToString();
        paragraf2.EditValue = "§ " + (paragraf + 1).ToString();
        paragraf3.EditValue = "§ " + (paragraf + 2).ToString();
        paragraf4.EditValue = "§ " + (paragraf + 3).ToString();
        paragraf5.EditValue = "§ " + (paragraf + 4).ToString();
        paragraf6.EditValue = "§ " + (paragraf + 5).ToString();
        paragraf7.EditValue = "§ " + (paragraf + 6).ToString();
        paragraf8.EditValue = "§ " + (paragraf + 7).ToString();
       
        string strRodzaj1 = "", strRodzaj2 = "";
        switch (umowa.RodzajRozliczenia) {
            case RodzajeRozliczeniaUmowy.KwotaDoWypłaty:
                strRodzaj1 = "Za wykonanie zlecenia jego Wykonawca otrzyma";
                break;
            case RodzajeRozliczeniaUmowy.StawkaZaGodzinę:
                strRodzaj1 = "Zleceniodawca zapłaci, a Zleceniobiorca otrzyma z tytułu wykonania zleconej pracy";
                strRodzaj2 = "za godzinę";
                break;
            case RodzajeRozliczeniaUmowy.StawkaZaOkres:
                strRodzaj1 = "Za wykonanie zlecenia jego Wykonawca będzie otrzymywał";
                strRodzaj2 = "miesięcznie";
                break;
        }
        lbRodzaj1.EditValue = strRodzaj1;
        lbRodzaj2.EditValue = strRodzaj2;
        
        if (umowaHist.TypWartosci == TypWartosciUmowy.Brutto) {
            KwotaSłownieUpr.EditValue = umowaHist.BruttoSłownieUpr;
            KwotaSłownie.EditValue = umowaHist.BruttoSłownie;
        }
        else {
            KwotaSłownieUpr.EditValue = umowaHist.SłownieUpr;
            KwotaSłownie.EditValue = umowaHist.Słownie;
        }
        KwotaRodzaj.EditValue = umowaHist.TypWartosci.ToString().ToLower();

        string sadPracy = srinfo.SadPracy;
        if (sadPracy == "")
            sadPracy = KadryModule.GetInstance(dc).Config.Wydruki.SądPracy;
        if (sadPracy == "")
            sadPracy = "[oznaczenie sądu] ..............................";
        sadpracy.EditValue = sadPracy;

        ArrayList al = new ArrayList();
        for (int i = 0; i < info.IloscKopii; i++)
            al.Add(umowa);
        DataRepeater1.DataSource = al;

        if (info.RachunekUmowa && umowaID == 0) {
            Hashtable wyplaty = new Hashtable();
            foreach (WypElement elem in umowa.Elementy)
                wyplaty[elem.Wyplata] = true;

            ArrayList alw = new ArrayList(wyplaty.Keys);
            foreach (Wyplata wyp in alw)
                dc.FollowingReports.Add(new FollowingReport(string.Format("Place/umowa zlecenie - rachunek.aspx?WyplataID={0}", wyp.ID)));
        }
    }

    void DaneFirmy(PracHistoria ph) {
		CoreModule core = CoreModule.GetInstance(dc);
        string nip = core.Config.Firma.Pieczątka.NIP;
        string krs = core.Config.Firma.Rejestracja.Numer;
        string miejscowosc = core.Config.Firma.AdresSiedziby.Miejscowosc;
        string nazwa = core.Config.Firma.Pieczątka.Nazwa;
        string ulica = core.Config.Firma.AdresSiedziby.Ulica;
        string nrDomu = core.Config.Firma.AdresSiedziby.NrDomu;
        string nrLokalu = core.Config.Firma.AdresSiedziby.NrLokalu;
        string kodP = core.Config.Firma.AdresSiedziby.KodPocztowyS;
        if (ph.Etat.Wydzial != null && ph.Etat.Wydzial.Oddzial != null) {
            OddzialFirmy of = ph.Etat.Wydzial.Oddzial;
            if (!string.IsNullOrEmpty(of.Deklaracje.NIP)) nip = of.Deklaracje.NIP;
            if (!string.IsNullOrEmpty(of.Deklaracje.KRS)) krs = of.Deklaracje.KRS;
            if (!string.IsNullOrEmpty(of.Adres.Miejscowosc)) miejscowosc = of.Adres.Miejscowosc;
            if (!string.IsNullOrEmpty(of.Nazwa)) nazwa = of.Nazwa;
            if (!string.IsNullOrEmpty(of.Adres.Ulica)) ulica = of.Adres.Ulica;
            if (!string.IsNullOrEmpty(of.Adres.NrDomu)) nrDomu = of.Adres.NrDomu;
            if (!string.IsNullOrEmpty(of.Adres.NrLokalu)) nrLokalu = of.Adres.NrLokalu;
            if (!string.IsNullOrEmpty(of.Adres.KodPocztowyS)) kodP = of.Adres.KodPocztowyS;
        }
        PieczątkaNIP.EditValue = nip;
        PieczątkaKRS.EditValue = krs;
        PieczątkaMiejscowosc1.EditValue = miejscowosc;
        PieczątkaMiejscowosc2.EditValue = miejscowosc;
        PieczątkaNazwa.EditValue = nazwa;
        PieczątkaUlica.EditValue = ulica;
        PieczątkaNrDomu.EditValue = nrDomu;
        PieczątkaNrLokalu.EditValue = nrLokalu;
        PieczątkaKodPocztowyS.EditValue = kodP;
        NumerLokalu.Visible = (nrLokalu.Length > 0);
    }

</script>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<html>
<head>
    <title>Umowa zlecenie</title> 
    <meta content="False" name="vs_showGrid" />
    <meta content="Microsoft Visual Studio 7.0" name="GENERATOR" />
    <meta content="C#" name="CODE_LANGUAGE" />
    <meta content="JavaScript" name="vs_defaultClientScript" />
    <meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema" />
</head>
<body>
    <form id="UmowaOPracę" method="post" runat="server">
        <EA:DATACONTEXT id="dc" runat="server" OnContextLoading="dc_ContextLoading" OnContextLoad="dc_ContextLoad" TypeName="Soneta.Kadry.Umowa, Soneta.KadryPlace"></EA:DATACONTEXT>
        <ea:DataRepeater ID="DataRepeater1" runat="server" RowTypeName="Soneta.Kadry.Umowa, Soneta.KadryPlace" Width="100%" Height="161px">
        <ea:SectionMarker ID="SectionMarker9" runat="server"></ea:SectionMarker>
		<ea:PageBreak ID="PageBreak1" runat="server" BreakFirstTimes="False" 
			ResetPageCounter="True"></ea:PageBreak>
		<font face="Tahoma" size="3">
            <p align="center"><b>UMOWA ZLECENIE</b>
                <ea:datalabel id="NumerUmowy" runat="server"></ea:datalabel>
            </p>
        </font>
		<font face="Tahoma" size="2">
        <p style="text-align:justify">
        zawarta w dniu&nbsp;
        <ea:datalabel id="Datalabel25" runat="server" DataMember="Data"></ea:datalabel>
        w&nbsp;
        <ea:datalabel id="PieczątkaMiejscowosc1" runat="server"></ea:datalabel>
        &nbsp;pomiędzy: prowadzącym/ą działalność gospodarczą pod nazwą&nbsp;
        <ea:datalabel id="PieczątkaNazwa" runat="server"></ea:datalabel>
            <p style="text-align:justify">
                &nbsp;<ea:Section ID="KRSSection" runat="server">
                    &nbsp;wpisanym/ą do rejestru przedsiębiorców pod numerem&nbsp;
                    <ea:DataLabel ID="PieczątkaKRS" runat="server">
                    </ea:DataLabel>
                    , [podmioty zarejestrowane po dniu 1 stycznia 2001, podlegają wpisowi do Krajowego Rejestru Sądowego]
                </ea:Section>
                z siedzibą <b>ul.</b>&nbsp;
                <ea:DataLabel ID="PieczątkaUlica" runat="server">
                </ea:DataLabel>
                &nbsp;
                <ea:DataLabel ID="PieczątkaNrDomu" runat="server">
                </ea:DataLabel>
                <ea:Section ID="NumerLokalu" runat="server" Width="100%">
                    /<ea:DataLabel ID="PieczątkaNrLokalu" runat="server">
                    </ea:DataLabel>
                </ea:Section>
                ,&nbsp;
                <ea:DataLabel ID="PieczątkaKodPocztowyS" runat="server">
                </ea:DataLabel>
                &nbsp;
                <ea:DataLabel ID="PieczątkaMiejscowosc2" runat="server">
                </ea:DataLabel>
                &nbsp;reprezentowaną przez:&nbsp;
                <ol>
                    <ea:DataLabel ID="fieldPracodawca1" runat="server">
                    </ea:DataLabel>
                    <ea:DataLabel ID="fieldPracodawca2" runat="server">
                    </ea:DataLabel>
                    <br/>
                    <br/>
                    NIP:&nbsp;
                    <ea:DataLabel ID="PieczątkaNIP" runat="server">
                    </ea:DataLabel>
                    &nbsp;zwanym/ą w dalszej części umowy <u>Zleceniodawcą</u>,&nbsp;
                </ol>
                a&nbsp;
                <ea:DataLabel ID="Datalabel34" runat="server" DataMember="PracHistoria.Nazwisko">
                </ea:DataLabel>
                &nbsp;
                <ea:DataLabel ID="Datalabel35" runat="server" DataMember="PracHistoria.Imie">
                </ea:DataLabel>
                &nbsp;
                <ea:DataLabel ID="DataLabe51" runat="server" Bold="False" DataMember="PracHistoria.Plec">
                    <ValuesMap>
                        <ea:ValuesPair Key="Kobieta" Value="zamieszkałą" />
                        <ea:ValuesPair Key="Mężczyzna" Value="zamieszkałym" />
                    </ValuesMap>
                </ea:DataLabel>
                &nbsp;
                <ea:DataLabel ID="Datalabel36" runat="server" DataMember="PracHistoria.Adres">
                </ea:DataLabel>
                ,&nbsp;
                <ea:DataLabel ID="DataLabe52" runat="server" Bold="False" DataMember="PracHistoria.Plec">
                    <ValuesMap>
                        <ea:ValuesPair Key="Kobieta" Value="legitymującą" />
                        <ea:ValuesPair Key="Mężczyzna" Value="legitymującym" />
                    </ValuesMap>
                </ea:DataLabel>
                &nbsp;się dokumentem&nbsp;
                <ea:DataLabel ID="Datalabel2" runat="server" bold="false" DataMember="PracHistoria.Dokument.Rodzaj">
                </ea:DataLabel>
                <ea:DataLabel ID="Datalabel40" runat="server" DataMember="PracHistoria.Dokument.SeriaNumer">
                </ea:DataLabel>
                &nbsp;wydanym przez&nbsp;
                <ea:DataLabel ID="Datalabel41" runat="server" DataMember="PracHistoria.Dokument.WydanyPrzez">
                </ea:DataLabel>
                ,&nbsp;
                <ea:DataLabel ID="DataLabel1" runat="server" Bold="False" DataMember="PracHistoria.Plec">
                    <ValuesMap>
                        <ea:ValuesPair Key="Kobieta" Value="zwaną" />
                        <ea:ValuesPair Key="Mężczyzna" Value="zwanym" />
                    </ValuesMap>
                </ea:DataLabel>
                &nbsp;w dalszej części umowy <u>Zleceniobiorcą</u> o treści następującej:&nbsp;
                <p>
                </p>
                <p>
                </p>
                <p align="center">
                    <strong>§ 1</strong>
                </p>
                <p style="text-align:left">
                    Zleceniodawca zleca, a Zleceniobiorca przyjmuje wykonanie pracy polegającej na:<br />
                    <ea:DataLabel ID="tytul" runat="server">
                    </ea:DataLabel>
                </p>
                <p align="center">
                    <strong>§ 2</strong>
                </p>
                <p style="text-align:justify">
                    Zleceniobiorca będzie wykonywać zlecenie w terminie ustalonym przez Strony, tj. od dnia&nbsp;
                    <ea:DataLabel ID="Datalabel43" runat="server" DataMember="Okres.From">
                    </ea:DataLabel>
                    &nbsp;do dnia&nbsp;
                    <ea:DataLabel ID="Datalabel44" runat="server" DataMember="Okres.To">
                        <ValuesMap>
                            <ea:ValuesPair Key="(max)" Value=". . . . . . . . . ." />
                        </ValuesMap>
                    </ea:DataLabel>
                    .
                </p>
                <ea:Section ID="DodatkowyParagraf" runat="server" Width="100%">
                    <p align="center">
                        <strong>§ 3</strong>
                    </p>
                    <p style="text-align:justify">
                        Zleceniobiorca nie podlega obowiązkowo ubezpieczeniom społecznym zgodnie z art. 6 ust. 4 ustawy z dnia 13 października 1998 r. o systemie ubezpieczeń społecznych (Dz. U. z 2009 r. nr 205, poz. 1585 ze zm.) oraz ubezpieczeniu zdrowotnemu zgodnie z art. 66 ust. 1 pkt 1 lit. e ustawy z dnia 27 sierpnia 2004 r. o świadczeniach opieki zdrowotnej finansowanych ze środków publicznych (Dz. U. z 2008 r. nr 164, poz. 1027 ze zm.)
                    </p>
                </ea:Section>
                <p align="center">
                    <strong>
                    <ea:DataLabel ID="paragraf1" runat="server">
                    </ea:DataLabel>
                    </strong>
                </p>
                <p style="text-align:justify">
                    <ea:DataLabel ID="lbRodzaj1" runat="server" Bold="false">
                    </ea:DataLabel>
                    wynagrodzenie w wysokości&nbsp;
                    <ea:DataLabel ID="KwotaSłownieUpr" runat="server" Format="{0:n}">
                    </ea:DataLabel>
                    <ea:DataLabel ID="KwotaRodzaj" runat="server">
                    </ea:DataLabel>
                    &nbsp;(słownie:&nbsp;
                    <ea:DataLabel ID="KwotaSłownie" runat="server" Format="{0:t}">
                    </ea:DataLabel>
                    )
                    <ea:DataLabel ID="lbRodzaj2" runat="server" Bold="false">
                    </ea:DataLabel>
                    .
                </p>
                <p align="center">
                    <strong>
                    <ea:DataLabel ID="paragraf2" runat="server">
                    </ea:DataLabel>
                    </strong>
                </p>
                <p style="text-align:justify">
                    Zleceniobiorca zobowiązuje się do realizacji zadań wymienionych w § 1 samodzielnie i nie powierzania ich wykonania osobie trzeciej.
                </p>
                <p align="center">
                    <strong>
                    <ea:DataLabel ID="paragraf3" runat="server">
                    </ea:DataLabel>
                    </strong>
                </p>
                <p style="text-align:justify">
                    Wypłata wynagrodzenia nastąpi w ciągu 14 dni po wystawieniu rachunku przez Zleceniobiorcę i stwierdzeniu przez Zleceniodawcę terminowego i prawidłowego wykonania zleconej pracy będącej przedmiotem niniejszej umowy.
                </p>
                <p align="center">
                    <strong>
                    <ea:DataLabel ID="paragraf4" runat="server">
                    </ea:DataLabel>
                    </strong>
                </p>
                <p style="text-align:justify">
                    Umowa może zostać wypowiedziana przez każdą ze stron z zachowaniem jednomiesięcznego terminu wypowiedzenia.
                </p>
            </p>
        </p>
        </font>
	    <ea:PageBreak ID="PageBreak2" runat="server" Required="false"></ea:PageBreak>
		<font face="Tahoma" size="2">
        <p align="center">
            <strong><ea:datalabel id="paragraf5" runat="server"></ea:datalabel></strong>
        </p>
        <p style="text-align:justify">
        W sprawach nieuregulowanych umową mają zastosowanie odpowiednie
        przepisy Kodeksu cywilnego.
        </p>
        </font>
	    <ea:PageBreak ID="PageBreak3" runat="server" Required="false"></ea:PageBreak>
		<font face="Tahoma" size="2">
        <p align="center">
            <strong><ea:datalabel id="paragraf6" runat="server"></ea:datalabel></strong>
        </p>
        <p style="text-align:justify">
        Zmiany umowy wymagają formy pisemnej, pod rygorem nieważności.
        </p>
        <p align="center">
            <strong><ea:datalabel id="paragraf7" runat="server"></ea:datalabel></strong>
        </p>
        <p style="text-align:justify">
        Wszelkie ewentualne spory wynikające z niniejszej umowy
        lub jej dotyczące będą rozstrzygane przez właściwy rzeczowo Sąd - <ea:datalabel runat="server" ID="sadpracy" Bold="false"></ea:datalabel>
        
        </p>
        <p align="center">
            <strong><ea:datalabel id="paragraf8" runat="server"></ea:datalabel></strong>
        </p>
        <p style="text-align:justify">
        Umowa została sporządzona w <ea:datalabel runat="server" ID="dlkopie" Bold="false"></ea:datalabel>
        (słownie: <ea:datalabel runat="server" ID="dlkopieslownie" Bold="false"></ea:datalabel>)
        jednobrzmiących egzemplarzach, po jednym dla każdej ze stron.
        </p>
        <p></p>
        <cc1:ReportFooter id="ReportFooter1" runat="server" TheEnd="False">
            <Subtitles>
                <cc1:FooterSubtitle Caption="zleceniodawca" Width="50"></cc1:FooterSubtitle>
                <cc1:FooterSubtitle Caption="zleceniobiorca" Width="50"></cc1:FooterSubtitle>
            </Subtitles>
        </cc1:ReportFooter>
		<ea:SectionMarker ID="SectionMarker8" runat="server" SectionType="Footer"></ea:SectionMarker>
        </ea:DataRepeater>
	</font>
    </form>
</body>
</html>
