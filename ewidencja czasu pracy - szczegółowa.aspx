<%@ Page Language="c#" autoeventwireup="false" CodePage="1200" %>
<%@ Register TagPrefix="cc1" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %>
<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %>
<%@ import Namespace="Soneta.Kadry" %>
<%@ import Namespace="Soneta.Kalend" %>
<%@ import Namespace="Soneta.Place" %>
<%@ import Namespace="Soneta.Business" %>
<%@ import Namespace="Soneta.Tools" %>
<%@ import Namespace="Soneta.Types" %>
<%@ import Namespace="System.ComponentModel" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Diagnostics" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<HTML>
	<HEAD>
		<title>Ewidencja czasu pracy</title>
		<script runat="server">

		//Informacje dodatkowe z RCP
		    //Definicje dodatkowych kolumn do umieszczenia PO kolumnie 'w godz. nadliczbowych'.
		    //Jako kolejne jnapisy należy umiezzczać pary "nagłówek|nazwa definicji strefy".
		    //Na przykład:             
            //static string[] czas_przepracowany = new string[] { 
		    //      "CZAS PRZEPRACOWANY W GODZINACH - ODPOWIEDNIO~na dyżurze|dyżur" };		    		    
            static string[] czas_przepracowany = new string[] { };
		    
            //Definicje dodatkowych kolumn do umieszczenia PO kolumnie 'godz. nadliczbowe 100%'.
            //Składnia taka sama jak do czas_przepracowany.
            //Na przykład:             
		    //static string[] dodatkowe_dane = new string[] { 
	        //      "DODATKOWE DANE~Czas pracy młod. ***)|Praca młodocianego" };
            static string[] dodatkowe_dane = new string[] { };

            public class PrnParams : ContextBase {
                
                public PrnParams(Context context) : base(context) {
                    Date data = ((ActualDate)context[typeof(ActualDate)]).Actual;
                    ym = new YearMonth(data);
                }
                
                YearMonth ym;
                [Required]
                [Priority(1)]
                public YearMonth Miesiąc {
                    get { return ym; }
                    set {
                        ym = value;
                        OnChanged(EventArgs.Empty);
                    }
                }
			}

            public class SrParams : SerializableContextBase {
                public SrParams(Context context) : base(context) {
                }

                //static bool wejściaWyjścia = true;
                bool wejsciaWyjscia = true;
                [Priority(1)]
                [Caption("Wejścia/wyjścia")]
                public bool WejsciaWyjscia {
                    get { return wejsciaWyjscia; }
                    set {
                        wejsciaWyjscia = value;
                        OnChanged(EventArgs.Empty);
                    }
                }

                //Drukuj podsumowanie nadgodzin pod wydrukiem. Dla poszczególnych dni drukowane są 
                //wyłącznie informacje o nadgodzinach dobowych.    
                //static bool podsumowanieNadgodzin = true;
                bool podsumowanieNadgodzin = true;
                [Priority(2)]
                [Caption("Podsum. nadgodzin")]
                public bool PodsumowanieNadgodzin {
                    get { return podsumowanieNadgodzin; }
                    set {
                        podsumowanieNadgodzin = value;
                        OnChanged(EventArgs.Empty);
                    }
                }

                //Licz nadgodziny wg wypłat zamiast wg kalendarza
                //działa tylko jeżeli podsumowanieNadgodzin==true.
                //static bool nadgodzWgWyplat = false;    
                bool nadgodzWgWyplat = false;
                [Priority(3)]
                [Caption("Nadgodziny wg wypłat")]
                public bool NadgodzWgWyplat {
                    get { return nadgodzWgWyplat; }
                    set {
                        nadgodzWgWyplat = value;
                        OnChanged(EventArgs.Empty);
                    }
                }

                bool pelneStanowisko = false;
                [Priority(4)]
                [Caption("Stanowisko pełna nazwa")]
                public bool PelneStanowisko {
                    get { return pelneStanowisko; }
                    set {
                        pelneStanowisko = value;
                        OnChanged(EventArgs.Empty);
                    }
                }                
            }
		    		              
            PrnParams pars;
            [Context]
            public PrnParams Params {
                set { pars = value; }
            }

            SrParams srpars;
            [SettingsContext]
            public SrParams SrPars {
                get { return srpars; }
                set { srpars = value; }
            }		
		        
            Dictionary<DefinicjaStrefy, GridColumn> dodatkowe_kolumny = new Dictionary<DefinicjaStrefy, GridColumn>();

            string title;
		        
            void OnContextLoad(Object sender, EventArgs args) {
                report = ReportHeader1;
                ReportHeader1["MIESIĄC"] = pars.Miesiąc.ToString().ToUpper();
                title = ReportHeader1.Title;

                DodajKolumny(colNadlicz, czas_przepracowany);
                DodajKolumny(colNad100, dodatkowe_dane);
                DodajWiersze();

                colRcpIn.Visible = srpars.WejsciaWyjscia;
                colRcpOut.Visible = srpars.WejsciaWyjscia;

                if (srpars.PodsumowanieNadgodzin) {
                    colNad50.Visible = false;
                    colNad100.Visible = false;
                    colNN.RightBorder = BorderStyles.NotSet;
                }

                DataRepeater1.DataSource = (Row[])dc[typeof(Row[])];
            }

            void DodajKolumny(GridColumn poprzednia, string[] opisy) {
                int idx = Grid1.Columns.IndexOf(poprzednia);
                KalendModule kalend = KalendModule.GetInstance(dc);
                DefinicjeStref definicje = kalend.DefinicjeStref;
                foreach (string opis in opisy) {
                    string[] ss = opis.Split('|');
                    DefinicjaStrefy definicja = definicje.WgNazwy[ss[1]];
                    if (definicja == null)
                        throw new BusException("Definicja strefy kalendarza o nazwie " + ss[1] + " nie została znaleziona.");
                    GridColumn nowa = new GridColumn();
                    nowa.Caption = ss[0];
                    nowa.Align = HorizontalAlign.Center;
                    nowa.Total = Total.Sum;
                    nowa.RightBorder = poprzednia.RightBorder;
                    poprzednia.RightBorder = BorderStyles.NotSet;
                    poprzednia = nowa;
                    
                    Grid1.Columns.Insert(++idx, nowa);
                    dodatkowe_kolumny.Add(definicja, nowa);
                }
            }

            void DodajWiersze() {
                Date[] days = new Date[pars.Miesiąc.Days];
                for (int i = 0; i < pars.Miesiąc.Days; i++)
                    days[i] = pars.Miesiąc.FirstDay + i;
                Grid1.DataSource = days;
            }
		    
            Periods okresy_zatrudnienia;
            KalkulatorPracy kalkulator;
            KalkulatorNadgodzin nadgodziny;
            Time mies50;
            Time mies100;
            Time prev50;
            Time prev100;

            protected void DataRepeater1_BeforeRow(object sender, EventArgs e) {
                string msg = Msg(true);
                ReportHeader1.Title = title + (msg != "" ? "|" + msg : "");
                Pracownik pracownik = (Pracownik)DataRepeater1.CurrentRow;

                ReportHeader1["PRACOWNIK"] = pracownik.ImięNazwisko;
                ReportHeader1["KOD"] = pracownik.Kod;

                okresy_zatrudnienia = Periods.Empty;
                foreach (PracHistoria ph in pracownik.Historia.GetIntersectedRows(pars.Miesiąc.ToFromTo()))
                    if (ph.Etat.EfektywnyOkres != FromTo.Empty)
                        okresy_zatrudnienia += ph.Etat.EfektywnyOkres;
                okresy_zatrudnienia *= pars.Miesiąc.ToFromTo();
                okresy_zatrudnienia = okresy_zatrudnienia.ToFlat();

                PracHistoria historia = pracownik[okresy_zatrudnienia == Periods.Empty ? pars.Miesiąc.LastDay : okresy_zatrudnienia.To];
                ReportHeader1["STANOWISKO"] = GetStanowisko(historia);
                CzasDni cd = pracownik.Czasy.KalkPlanu.Norma(okresy_zatrudnienia);
                ReportHeader1["NORMAD"] = cd.Dni.ToString();
                ReportHeader1["NORMAT"] = cd.Czas.ToString();

                kalkulator = pracownik.Czasy.KalkPracy;
                nadgodziny = new KalkulatorNadgodzin(kalkulator);

                kalkulator.LoadOkres(pars.Miesiąc.ToFromTo());

                if (srpars.PodsumowanieNadgodzin) {
                    Time n50 = Time.Zero;
                    Time n100 = Time.Zero;

                    foreach (FromTo oz in okresy_zatrudnienia)
                        if (srpars.NadgodzWgWyplat) {
                            try {
                                foreach (WypElement element in pracownik.Elementy[oz])
                                    switch (element.RodzajZrodla) {
                                        case RodzajŹródłaWypłaty.NadgodzinyI:
                                            n50 += element.Czas; break;
                                        case RodzajŹródłaWypłaty.NadgodzinyII:
                                        case RodzajŹródłaWypłaty.NadgodzinyŚw:
                                            n100 += element.Czas; break;
                                    }
                            }
                            catch { Msg(false); }
                        }
                        else {
                            ZestawienieNadgodzin zn = nadgodziny.Nadgodziny(oz);
                            n50 += zn.N50;
                            n100 += zn.N100 + zn.NSW;
                        }

                    dlNadgodziny.EditValue = string.Format("Nadgodziny 50%: <strong>{0}</strong>, nadgodziny 100%: <strong>{1}</strong><br/>", n50, n100);
                    nadgodziny.TrybRozliczania = KalkulatorNadgodzin.TrybRozliczaniaNadgodzin.TylkoDobowe;
                }
                else {
                    prev50 = Time.Zero;
                    prev100 = Time.Zero;
                    ZestawienieNadgodzin zn = nadgodziny.Nadgodziny(pars.Miesiąc.ToFromTo());
                    mies50 = zn.N50;
                    mies100 = zn.N100 + zn.NSW;
                }
            }

            string GetStanowisko(PracHistoria ph) {
                string stanowiskoPelne = "";
                if (srpars.PelneStanowisko)
                    stanowiskoPelne = ph.Etat.StanowiskoPełne;
                if (stanowiskoPelne.Length == 0)
                    stanowiskoPelne = ph.Etat.Stanowisko;
                return stanowiskoPelne;
            }        
            
            static string[] nazwaDnia = new string[] { "N", "P", "W", "Ś", "C", "P", "S" };

            static readonly string wolnyFormat = "<SPAN style='FONT-SIZE: 8pt; WIDTH: 100%; FONT-FAMILY: Tahoma; BACKGROUND-COLOR: yellow; TEXT-ALIGN: center'>{0}</SPAN>";
            static readonly string swietoFormat = "<SPAN style='FONT-SIZE: 8pt; WIDTH: 100%; FONT-FAMILY: Tahoma; BACKGROUND-COLOR: gold; TEXT-ALIGN: center'>{0}</SPAN>";
            static readonly string normalFormat = "<SPAN style='FONT-SIZE: 8pt; WIDTH: 100%; FONT-FAMILY: Tahoma; TEXT-ALIGN: center'>{0}</SPAN>";
            static readonly string nieobecFormat = "<SPAN style='FONT-SIZE: 8pt; WIDTH: 100%; FONT-FAMILY: Tahoma; BACKGROUND-COLOR: silver; TEXT-ALIGN: center'>{0}</SPAN>";
            static readonly string zwolnFormat = "<SPAN style='FONT-SIZE: 8pt; WIDTH: 100%; FONT-FAMILY: Tahoma; BACKGROUND-COLOR: gainsboro; TEXT-ALIGN: center'>{0}</SPAN>";
            
            void Grid1_BeforeRow(Object sender, RowEventArgs args) {
                try {
                    Date data = (Date)args.Row;

                    if (!okresy_zatrudnienia.Contains(data)) {
                        colDM.EditValue = string.Format(zwolnFormat, data.Day);
                        return;
                    }

                    Dzien dzień = kalkulator[data];

                    string format = normalFormat;
                    switch (dzień.Definicja.Typ) {
                        case TypDnia.Pracy:
                            format = normalFormat; break;
                        case TypDnia.Świąteczny:
                            format = swietoFormat; break;
                        case TypDnia.Wolny:
                            format = wolnyFormat; break;
                    }
                    Nieobecnosc nb = dzień.Tag as Nieobecnosc;
                    if (nb != null && nb.Definicja.Typ != TypNieobecnosci.Storno)
                        format = nieobecFormat;

                    colDM.EditValue = string.Format(format, data.Day);
                    colDT.EditValue = string.Format(format, nazwaDnia[(int)data.DayOfWeek]);
                                        
                    colOd.EditValue = dzień.OdGodziny;
                    colDo.EditValue = Dzien.DoGodziny(dzień);
                    colCzas.EditValue = dzień.Czas;
                    colNocne.EditValue = kalkulator.Nocne(new FromTo(data, data));

                    if (srpars.PodsumowanieNadgodzin) {
                        FromTo okres = new FromTo(data, data);
                        ZestawienieNadgodzin zn = nadgodziny.Nadgodziny(okres);
                        colNadlicz.EditValue = zn.N50 + zn.N100 + zn.NSW;
                    }
                    else {
                        FromTo okres = new FromTo(data - (data.Day - 1), data);
                        ZestawienieNadgodzin zn = nadgodziny.Nadgodziny(okres);

                        Time n50 = zn.N50;
                        if (n50 < prev50)
                            n50 = prev50;
                        else if (n50 > mies50)
                            n50 = mies50;

                        Time n100 = zn.N100 + zn.NSW;
                        if (n100 < prev100)
                            n100 = prev100;
                        else if (n100 > mies100)
                            n100 = mies100;

                        colNadlicz.EditValue = n50 + n100 - prev50 - prev100;
                        colNad50.EditValue = n50 - prev50;
                        colNad100.EditValue = n100 - prev100;
                        prev50 = n50;
                        prev100 = n100;
                    }

                    foreach (DefinicjaStrefy definicja in dodatkowe_kolumny.Keys)
                        dodatkowe_kolumny[definicja].EditValue = PracaWStrefie(dzień, definicja);

                    switch (dzień.Definicja.Typ) {
                        case TypDnia.Świąteczny:
                            colŚwięta.EditValue = dzień.Czas; break;
                        case TypDnia.Wolny:
                            colWolne.EditValue = dzień.Czas; break;
                    }

                    Time czasNie = Time.Zero;
                    foreach (INieobecnosc nie in kalkulator.Nieobecnosci(FromTo.Day(data), true)) {
                        Nieobecnosc nieobecność = (Nieobecnosc)((OkresNieobecności)nie);
                        if (nieobecność != null && nieobecność.Definicja.Typ != TypNieobecnosci.Storno) {
                            GridColumn kolumna;

                            switch (nieobecność.Definicja.Przyczyna) {
                                case PrzyczynaNieobecnosci.NieusprawiedliwionaNiepłatna:
                                    kolumna = colNN; break;

                                case PrzyczynaNieobecnosci.UrlopWypoczynkowy:
                                    kolumna = colUw; break;

                                case PrzyczynaNieobecnosci.UrlopOkolicznościowy:
                                    kolumna = colUok; break;

                                case PrzyczynaNieobecnosci.UrlopBezpłatny:
                                    kolumna = colUb; break;

                                case PrzyczynaNieobecnosci.UrlopWychowawczy:
                                case PrzyczynaNieobecnosci.UrlopWychowawczyZUS:
                                    kolumna = colWych; break;

                                case PrzyczynaNieobecnosci.ZwolnienieChorobowe:
                                    kolumna = colCh; break;

                                case PrzyczynaNieobecnosci.UrlopOpiekuńczy:
                                case PrzyczynaNieobecnosci.UrlopMacierzyński:
                                case PrzyczynaNieobecnosci.UrlopRehabilitacyjny:
                                case PrzyczynaNieobecnosci.UrlopRodzicielski:
                                case PrzyczynaNieobecnosci.UrlopOjcowski:
                                    kolumna = colOp; break;

                                default:
                                    switch (nieobecność.Definicja.Guid.ToString()) {
                                        case "00000000-0006-0005-0029-000000000000": //"Urlop wypoczynkowy dodatkowy"
                                            kolumna = colUwd; break;
                                        case "00000000-0006-0005-0012-000000000000": //"Urlop opiekuńczy (art 188 kp, dni)"
                                        case "00000000-0006-0005-0046-000000000000": //"Urlop opiekuńczy (art 188 kp, godz.)"
                                            kolumna = colUOp; break;
                                        default:
                                            kolumna = colNU; break;
                                    }
                                    break;
                            }

                            for (int i = 0; i < 2; i++) {
                                if (nieobecność.Definicja.TypDni == TypyDni.Kalendarzowe)
                                    kolumna.EditValue = 1;
                                else if (nieobecność.Okres.Days == 1 && nieobecność.Norma != Time.Empty) {
                                    czasNie += nieobecność.Norma;
                                    kolumna.EditValue = czasNie;
                                }
                                else
                                    kolumna.EditValue = kalkulator.Plan[data].Czas;

                                if (nieobecność.Urlop.Przyczyna != PrzyczynaUrlopu.NaŻądanie)
                                    break;

                                kolumna = colUwNz;
                            }
                        }
                    }

                    if (srpars.WejsciaWyjscia) {
                        DzienPracy dzieńPracy = (DzienPracy)kalkulator.Pracownik.DniPracy[data];
                        if (dzieńPracy != null) {
                            bool first = true;
                            Time wyjście = Time.Empty;
                            foreach (WejscieWyjscie wewy in dzieńPracy.WeWy) {
                                switch (wewy.Typ) {
                                    case TypWejsciaWyjscia.Wejscie:
                                    case TypWejsciaWyjscia.WejscieSluzbowe:
                                        if (first) {
                                            first = false;
                                            colRcpIn.EditValue = wewy.Godzina;
                                        }
                                        wyjście = Time.Empty;
                                        break;

                                    case TypWejsciaWyjscia.Wyjscie:
                                    case TypWejsciaWyjscia.WyjscieSluzbowe:
                                        wyjście = wewy.Godzina;
                                        break;
                                }
                            }

                            colRcpOut.EditValue = wyjście;
                        }
                    }
                }
                catch (Soneta.Kalend.KalkulatorPracy.ZestPracyException ex) {
                    throw new RowException(ex, kalkulator.Pracownik, "Próba wykonania raportu dla pracownika rozliczanego wg zestawień czasu pracy.");
                }
            }

            static Time PracaWStrefie(Dzien dzień, DefinicjaStrefy def) {
                if (def == null)
                    return Time.Empty;

                bool any = false;
                Time result = Time.Zero;
                foreach (Dzien.Strefa s in dzień)
                    if (s.Definicja == def) {
                        result += s.Czas;
                        any = true;
                    }

                return any ? result : Time.Empty;
            }
		        
    
       public static void Msg(object obj) {
       }

       public static ReportHeader report;

       public static string Msg(bool flag) {
           string msg = "Wydruk przygotowany na podstawie danych, do których operator ma prawa dostępu";
           if (report != null && !report.Title.Contains(msg))
               if (flag)
                   msg = "";
               else
                   report.Title += "|" + msg;
           return msg;
       }

</script>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<meta content="Microsoft Visual Studio 7.0" name="GENERATOR">
		<meta content="C#" name="CODE_LANGUAGE">
		<meta content="JavaScript" name="vs_defaultClientScript">
		<meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema">
	</HEAD>
	<body>
		<form id="EwidencjaCzasuPracy" method="post" runat="server">
			<ea:datacontext id="dc" runat="server" TypeName="Soneta.Business.Row[], Soneta.Business" oncontextload="OnContextLoad" BottomMargin="-1" LeftMargin="-1" RightMargin="-1" TopMargin="-1" Landscape="True"></ea:datacontext>
        <ea:DataRepeater ID="DataRepeater1" runat="server" OnBeforeRow="DataRepeater1_BeforeRow"
            RowTypeName="Soneta.Kadry.Pracownik,Soneta.KadryPlace" Width="100%" Height="161px">
            <ea:SectionMarker ID="SectionMarker9" runat="server">
            </ea:SectionMarker>
            <ea:PageBreak ID="PageBreak1" runat="server" BreakFirstTimes="False" ResetPageCounter="True">
            </ea:PageBreak>
				<cc1:reportheader NagłówekOddziału="NagłówekOddziału" id="ReportHeader1" title="KARTA EWIDENCJI CZASU PRACY ZA %MIESIĄC%|</strong>Imię i nazwisko:<strong> %PRACOWNIK%</strong>, Kod pracownika:<strong> %KOD%</strong>, stanowisko pracy:<strong> %STANOWISKO%|</strong>Normatywny czas pracy w dniach:<strong> %NORMAD%</strong>, w godzinach:<strong> %NORMAT%" runat="server"></cc1:reportheader>
				<ea:grid id="Grid1" runat="server" OnBeforeRow="Grid1_BeforeRow" DataMember="DataSource">
					<Columns>
                        <ea:GridColumn runat="server" Align="Center" Caption="OZNACZENIE DNIA~dzień miesiąca" ID="colDM">
                        </ea:GridColumn>
                        <ea:GridColumn runat="server" Align="Center" Caption="OZNACZENIE DNIA~dzień tygodnia"
                            RightBorder="Double" ID="colDT">
                        </ea:GridColumn>
                        <ea:GridColumn runat="server" Align="Center" 
                            Caption="FAKTYCZNY CZAS PRACY~od godziny" ID="colOd" Format="{0:+}">
                        </ea:GridColumn>
                        <ea:GridColumn runat="server" Align="Center" 
                            Caption="FAKTYCZNY CZAS PRACY~do godziny" ID="colDo" Format="{0:+}">
                        </ea:GridColumn>
                        <ea:GridColumn runat="server" Align="Center" Caption="FAKTYCZNY CZAS PRACY~ilość godzin"
                            RightBorder="Double" ID="colCzas" HideZero="True" Total="Sum">
                        </ea:GridColumn>
                        <ea:GridColumn ID="colRcpIn" runat="server" Caption="RCP~Wejście"
                            HideZero="True" Align="Center" Format="{0:+}">
                        </ea:GridColumn>
                        <ea:GridColumn ID="colRcpOut" runat="server" Caption="RCP~Wyjście"
                            HideZero="True" Align="Center" RightBorder="Double" Format="{0:+}">
                        </ea:GridColumn>
                        <ea:GridColumn ID="colŚwięta" runat="server" Caption="CZAS PRZEPRACOWANY W GODZINACH - ODPOWIEDNIO~w niedziele i święta"
                            HideZero="True" Align="Center" Total="Sum">
                        </ea:GridColumn>
                        <ea:GridColumn ID="colWolne" runat="server" Caption="CZAS PRZEPRACOWANY W GODZINACH - ODPOWIEDNIO~w dodat-|kowe dni wolne"
                            HideZero="True" Align="Center" Total="Sum">
                        </ea:GridColumn>
                        <ea:GridColumn ID="colNocne" runat="server" Caption="CZAS PRZEPRACOWANY W GODZINACH - ODPOWIEDNIO~w porze nocnej"
                            HideZero="True" Total="Sum" Align="Center">
                        </ea:GridColumn>
                        <ea:GridColumn ID="colNadlicz" runat="server" Caption="CZAS PRZEPRACOWANY W GODZINACH - ODPOWIEDNIO~w godz. nadlicz-|bowych"
                            HideZero="True" Total="Sum" Align="Center" RightBorder="Double">
                        </ea:GridColumn>
                        <ea:GridColumn ID="colUw" runat="server" Caption="CZAS NIEOBECNOŚCI W PRACY W *)|według przyczyn~Uw"
                            HideZero="True" Total="Sum" Align="Center">
                        </ea:GridColumn>
                        <ea:GridColumn ID="colUwd" runat="server" Caption="CZAS NIEOBECNOŚCI W PRACY W *)|według przyczyn~UWD"
                            HideZero="True" Total="Sum" Align="Center">
                        </ea:GridColumn>
                        <ea:GridColumn ID="colUwNz" runat="server" Caption="CZAS NIEOBECNOŚCI W PRACY W *)|według przyczyn~nż"
                            HideZero="True" Total="Sum" Align="Center">
                        </ea:GridColumn>
                        <ea:GridColumn ID="colUok" runat="server" Caption="CZAS NIEOBECNOŚCI W PRACY W *)|według przyczyn~Uok"
                            HideZero="True" Total="Sum" Align="Center">
                        </ea:GridColumn>
                        <ea:GridColumn ID="colUOp" runat="server" Caption="CZAS NIEOBECNOŚCI W PRACY W *)|według przyczyn~UOp"
                            HideZero="True" Total="Sum" Align="Center">
                        </ea:GridColumn>
                        <ea:GridColumn ID="colUb" runat="server" Caption="CZAS NIEOBECNOŚCI W PRACY W *)|według przyczyn~Ub"
                            HideZero="True" Total="Sum" Align="Center">
                        </ea:GridColumn>
                        <ea:GridColumn ID="colCh" runat="server" Caption="CZAS NIEOBECNOŚCI W PRACY W *)|według przyczyn~Ch"
                            HideZero="True" Total="Sum" Align="Center">
                        </ea:GridColumn>
                        <ea:GridColumn ID="colOp" runat="server" Caption="CZAS NIEOBECNOŚCI W PRACY W *)|według przyczyn~Op|UM|UR|Reh|Uoj"
                            HideZero="True" Total="Sum" Align="Center">
                        </ea:GridColumn>
                        <ea:GridColumn ID="colWych" runat="server" Caption="CZAS NIEOBECNOŚCI W PRACY W *)|według przyczyn~Wych"
                            HideZero="True" Total="Sum" Align="Center">
                        </ea:GridColumn>
                        <ea:GridColumn ID="colNU" runat="server" Align="Center" Caption="CZAS NIEOBECNOŚCI W PRACY W *)|według przyczyn~NU"
                            HideZero="True" Total="Sum">
                        </ea:GridColumn>
                        <ea:GridColumn ID="colNN" runat="server" Align="Center" Caption="CZAS NIEOBECNOŚCI W PRACY W *)|według przyczyn~NN"
                            HideZero="True" Total="Sum" RightBorder="Double">
                        </ea:GridColumn>
					    <ea:GridColumn ID="colNad50" runat="server" Align="Center" 
                            Caption="DODATKOWE DANE~Godz. nadlicz|-bowe 50%" HideZero="True" Total="Sum">
                        </ea:GridColumn>
                        <ea:GridColumn ID="colNad100" runat="server" Align="Center" 
                            Caption="DODATKOWE DANE~Godz. nadlicz|-bowe 100%" HideZero="True" Total="Sum">
                        </ea:GridColumn>
					</Columns>
				</ea:grid>
                <span style="font-size: 8pt; font-family: Verdana">
                <ea:DataLabel ID="dlNadgodziny" runat="server" Bold="False">
                </ea:DataLabel>
                *) w dniach lub w godzinach
            <br />
                    <b>Uw</b> - urlop wypoczynkowy (w tym planowany i na żądanie), (<b>nż</b> - wykorzystany urlop na żądanie),
                    <b>UWD</b> - urlop wypoczynkowy dodatkowy, <b>Uok</b> - urlop okolicznościowy, <b>UOp</b> - urlop opieka (art. 188 kp.),
                    <b>Ub</b> - urlop bezpłatny, <b>Ch</b> - choroba pracownika, <b>Op</b> - opieka nad chorym członkiem rodziny,
                    <b>UM</b> - urlop macierzyński, <b>UR</b> - urlop rodzicielski,
                    <b>Reh</b> - urlop rehabilitacyjny, <b>Wych</b> - urlop wychowawczy,
                    <b>NU</b> - inne nieobecność usprawiedliwiona, <b>NN</b> - nieobecność nieusprawiedliwiona,
                    <b>Uoj</b> - urlop ojcowski (art. 182.3 kp).</span>
            <cc1:reportfooter id="ReportFooter1" runat="server" TheEnd="False"></cc1:reportfooter>
            <ea:SectionMarker ID="SectionMarker8" runat="server" SectionType="Footer">
            </ea:SectionMarker>
        </ea:DataRepeater>
        </form>
	</body>
</HTML>
