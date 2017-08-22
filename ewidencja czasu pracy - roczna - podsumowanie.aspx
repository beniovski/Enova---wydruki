<%@ import Namespace="System.Diagnostics" %>
<%@ import Namespace="System.ComponentModel" %>
<%@ import Namespace="Soneta.Types" %>
<%@ import Namespace="Soneta.Tools" %>
<%@ import Namespace="Soneta.Business" %>
<%@ import Namespace="Soneta.Kalend" %>
<%@ import Namespace="Soneta.Place" %>
<%@ import Namespace="Soneta.Kadry" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %>
<%@ Register TagPrefix="cc1" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %>
<%@ Page Language="c#" autoeventwireup="false" CodePage="1200" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<HTML>
	<HEAD>
		<title>Ewidencja czasu pracy - podsumowanie</title>
		<script runat="server">
		
		class Item {
			readonly string nazwa;
			readonly protected object[] items = new object[12];
			
			public Item(string nazwa) {
				this.nazwa = nazwa;
			}
			public string Nazwa {
				get { return nazwa; }
			}
			public object M1 {
				get { return items[0]; }
			}
			public object M2 {
				get { return items[1]; }
			}
			public object M3 {
				get { return items[2]; }
			}
			public object M4 {
				get { return items[3]; }
			}
			public object M5 {
				get { return items[4]; }
			}
			public object M6 {
				get { return items[5]; }
			}
			public object M7 {
				get { return items[6]; }
			}
			public object M8 {
				get { return items[7]; }
			}
			public object M9 {
				get { return items[8]; }
			}
			public object M10 {
				get { return items[9]; }
			}
			public object M11 {
				get { return items[10]; }
			}
			public object M12 {
				get { return items[11]; }
			}
			public virtual object MR { 
				get { return ""; }
			}
	   }
	   
	   class DblItem: Item {
			public DblItem(string nazwa): base(nazwa) {
                for (int i = 0; i < 12; i++)
                    items[i] = (Double)0;
			}
			public override object MR { 
				get {
					Double razem = 0;
					foreach (Double d in items)
						razem += d;
					return razem;
				}
			}
			public void Add(int m, Double v) {
                items[m-1] = (Double)items[m-1] + v;
			}
	   }
	   
	   class TimeItem: Item {
			public TimeItem(string nazwa): base(nazwa) {
				for (int i = 0; i < 12; i++)
					items[i] = Time.Zero;
			}
			public override object MR { 
				get {
					Time razem = Time.Zero;
					foreach (Time i in items)
						razem += i;
					return razem;
				}
			}
			public void Add(int m, Time t) {
				items[m-1] = (Time)items[m-1] + t;
			}
		}	
	   
		public class PrnParams: ContextBase {
       
			public PrnParams(Context context): base(context) {
				Date data = ((ActualDate)context[typeof(ActualDate)]).Actual;
				okres = FromTo.Year(data.Year);
			}
        
			FromTo okres;
			[Required]
			[Priority(1)]
			public FromTo Okres {
				get { return okres; }
				set {
					okres = value;
					OnChanged(EventArgs.Empty);
				}
			}
		}

        public class SrParams : SerializableContextBase {
            public SrParams(Context context) : base(context) {
            }

			//Licz nadgodziny wg wypłat zamiast wg kalendarza
			//static bool nadgodzWgWyplat = false;
			bool nadgodzWgWyplat = false;
            [Priority(3)]
			[Caption("Nadgodz. wg wypłat")]
			public bool NadgodzWgWyplat {
				get { return nadgodzWgWyplat; }
				set {
					nadgodzWgWyplat = value;
					OnChanged(EventArgs.Empty);
				}
			}

			//Umieść dodatkowe informacje o nadgodzinach do i z przeniesienia    
			//static bool infoORozliczeniu = false;
			bool infoORozliczeniu = false;
            [Priority(4)]
			[Caption("Info o rozliczeniu")]
			public bool InfoORozliczeniu {
				get { return infoORozliczeniu; }
				set {
					infoORozliczeniu = value;
					OnChanged(EventArgs.Empty);
				}
			}
        }
		
        PrnParams pars;
        [Context(Required=true)]
        public PrnParams Params {
            get { return pars; }
            set { pars = value; }
        }
    
        SrParams srpars;
        [SettingsContext]
        public SrParams SrPars {
            get { return srpars; }
            set { srpars = value; }
        }		
    
		static readonly string prefix = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
    
		void AddDblItem(ArrayList lista, Hashtable ht, string kod, string nazwa) {
			DblItem item = new DblItem(nazwa);
			lista.Add(item);
			ht.Add(kod, item);
		}
		    
        void AddTimeItem(ArrayList lista, Hashtable ht, string kod, string nazwa) {
            TimeItem item = new TimeItem(nazwa);
            lista.Add(item);
            ht.Add(kod, item);
        }

        void Add(ArrayList lista, Hashtable ht, INieobecnosc nie, int m, Time dzieńPlan, Time czasNie) {
            string kod = KategoriaZUS(nie);
            string nazwa = "";

            if (!ht.ContainsKey(kod)) {
                switch (kod) {
                    case "NN": nazwa = "Nieobec.nieusprawiedliwione (NN)"; break;
                    case "OP": nazwa = "Opieka nad chorym dzieckiem (OP)"; break;
                    case "UM": nazwa = "Urlopy macierzyńskie (UM)"; break;
                    case "W": nazwa = "Urlopy wychowawcze (W)"; break;
                    case "Ch": nazwa = "Zwolnienie lekarskie (Ch)"; break;
                    case "Cs": nazwa = "Leczenie szpitalne (Cs)"; break;
                    case "UOp": nazwa = "Urlopy opieka art. 188 kp (UOp)"; break;
                    case "Uok": nazwa = "Urlopy okolicznościowe (Uok)"; break;
                    case "UW": nazwa = "Urlopy wypoczynkowe (UW)"; break;
                    case "UWD": nazwa = "Urlopy wypoczynkowe dodatkowe (UWD)"; break;
                    case "UB": nazwa = "Urlopy bezpłatne (UB)"; break;
                    case "DS": nazwa = "Delegacje służbowe (DS)"; break;
                    case "BO": nazwa = "Badania lekarskie (BO)"; break;
                    case "Reh": nazwa = "Urlop rehabilitacyjny (Reh)"; break;
                    case "UR": nazwa = "Urlop rodzicielski (UR)"; break;
                    case "Uoj": nazwa = "Urlop ojcowski (Uoj)"; break;
                    default: nazwa = "Nieobec.usprawiedliwione (NU)"; break;
                }
                if (nie.Definicja.TypOkresu == TypOkresuNieobecności.WDniach)
                    AddDblItem(lista, ht, kod, nazwa);
                else
                    AddTimeItem(lista, ht, kod, nazwa);
            }
            
            Item item = (Item)ht[kod];
            DblItem ii = item as DblItem;
            if (ii != null) {
                double czas = 0;
                if (dzieńPlan != Time.Zero)
                    czas = System.Math.Round(czasNie / dzieńPlan, 4);
                else
                    czas = 1;
                ii.Add(m, czas);
            }
            else {
                TimeItem ti = item as TimeItem;
                if (ti != null)
                    ti.Add(m, czasNie);
                else
                    throw new Exception("Suma dla nieobecności typu '" + kod + "' nie została zdefiniowana");
            }
        }
		
       void OnContextLoad(Object sender, EventArgs args) {
            report = ReportHeader1;
			Row[] rows = (Row[])dc[typeof(Row[])];
            
            KalendModule kalend = KalendModule.GetInstance(dc);
            DefinicjaStrefy strefaŚwiąteczne = kalend.DefinicjeStref[DefinicjaStrefy.DniSwiateczne];
            DefinicjaStrefy strefaWolne = kalend.DefinicjeStref[DefinicjaStrefy.DniWolne];

            string nazwaOkresu;
            if (pars.Okres == FromTo.Year(pars.Okres.From.Year))
				nazwaOkresu = pars.Okres.From.Year + " rok";
			else
				nazwaOkresu = "okres " + pars.Okres.ToString();
            ReportHeader1.Title = string.Format("Roczna ewidencja czasu pracy - podsumowanie|za {0}", nazwaOkresu);

            Log log = new Log("Wydruk: Ewidencja czasu pracy - roczna - podsumowanie", true);           
           
			ArrayList items2 = new ArrayList();
			
			DblItem normaD = new DblItem("Normatywny czas pracy - dni");
			items2.Add(normaD);
			TimeItem normaT = new TimeItem(prefix + "- godziny");
			items2.Add(normaT);
			
			DblItem pracaD = new DblItem("Faktyczny czas pracy - dni");
			items2.Add(pracaD);
			TimeItem pracaT = new TimeItem(prefix + "- godziny");
			items2.Add(pracaT);

            TimeItem przeniesienie = new TimeItem("Nadgodziny do/z przeniesienia");
            if (srpars.InfoORozliczeniu)
                items2.Add(przeniesienie);
            TimeItem przeniesienieKorekta = new TimeItem(prefix + "- korekta");
            if (srpars.InfoORozliczeniu)
                items2.Add(przeniesienieKorekta);
           			
			TimeItem św = new TimeItem("Praca w niedziele i święta");
			items2.Add(św);
			
			TimeItem noc = new TimeItem("Praca w porze nocnej");
			items2.Add(noc);
			
			TimeItem nadlicz = new TimeItem("Praca w godz. nadliczbowych");
			items2.Add(nadlicz);
			
			TimeItem wolne = new TimeItem("Praca w dni dodatkowo wolne");
			items2.Add(wolne);

			TimeItem akordy = new TimeItem("Praca na akordach");
			items2.Add(akordy);
					
			TimeItem dyżury = new TimeItem("Dyżury");
			items2.Add(dyżury);

            Hashtable ht = new Hashtable();

            foreach (Pracownik pracownik in rows) {           
                string logInfo = "";
           										
			    FromTo okres = pars.Okres;
			    Periods zatrud = Periods.Empty;
			    Periods wgkalendarza = Periods.Empty;
           
			    foreach (PracHistoria ph in pracownik.Historia.GetIntersectedRows(okres)) {
				    zatrud += ph.Etat.EfektywnyOkres;
				    if (ph.Etat.InterpretacjaKalendarza!=InterpretacjaKalendarza.WgZestawien)
					    wgkalendarza += ph.Etat.EfektywnyOkres;
			    }
				
			    zatrud = zatrud.ToFlat();
			    zatrud *= okres;
			    zatrud = zatrud.BreakByMonth();
                    			
			    KalkulatorPracownika kalk = new KalkulatorPracownika(pracownik);                    
                foreach (FromTo okr in zatrud) {
                    try {
                        int m = okr.From.Month;

                        CzasDni praca = kalk.Praca(okr);
                        pracaD.Add(m, praca.Dni);
                        pracaT.Add(m, praca.Czas);

                        CzasDni norma = kalk.Norma(okr);
                        normaD.Add(m, norma.Dni);
				        normaT.Add(m, norma.Czas);
			
				        św.Add(m, kalk.Praca(okr, Dzien.Świąteczny).Czas + kalk.Praca(okr, strefaŚwiąteczne).Czas);
				        wolne.Add(m, kalk.Praca(okr, Dzien.Wolny).Czas + kalk.Praca(okr, strefaWolne).Czas);
                        				
				        if (srpars.NadgodzWgWyplat) {
					        Time tnad = Time.Zero;
					        Time tnoc = Time.Zero;
                            Dictionary<RodzajŹródłaWypłaty, Dictionary<FromTo, Time>> lista = new Dictionary<RodzajŹródłaWypłaty, Dictionary<FromTo, Time>>();
                            SubTable st = PlaceModule.GetInstance(pracownik).WypElementy.WgPracownik[pracownik];
					        st = new SubTable(st, okr);
                            foreach (WypElement element in st) {
                                try {
                                    if (element.RodzajZrodla != RodzajŹródłaWypłaty.NadgodzinyI &&
                                        element.RodzajZrodla != RodzajŹródłaWypłaty.NadgodzinyII &&
                                        element.RodzajZrodla != RodzajŹródłaWypłaty.NadgodzinyŚw &&
                                        element.RodzajZrodla != RodzajŹródłaWypłaty.Nocne)
                                        continue;
                                    Dictionary<FromTo, Time> nadgodziny;
                                    if (!lista.TryGetValue(element.RodzajZrodla, out nadgodziny)) {
                                        nadgodziny = new Dictionary<FromTo, Time>();
                                        lista.Add(element.RodzajZrodla, nadgodziny);
                                    }
                                    Time czas = element.Czas;
                                    Time nadg = Time.Zero;
                                    if (nadgodziny.TryGetValue(element.Okres, out nadg)) {
                                        nadgodziny[element.Okres] = czas;
                                        czas -= nadg;
                                    }
                                    else
                                        nadgodziny.Add(element.Okres, czas);
                                    switch (element.RodzajZrodla) {
						                case RodzajŹródłaWypłaty.NadgodzinyI:
						                case RodzajŹródłaWypłaty.NadgodzinyII:
						                case RodzajŹródłaWypłaty.NadgodzinyŚw:
							                tnad += czas; break;
						                case RodzajŹródłaWypłaty.Nocne:
							                tnoc += czas; break;
						            }
                                }
                                catch { Msg(); }
                            }
                            noc.Add(m, tnoc);
					        nadlicz.Add(m, tnad);
				        }
				        else {
                            noc.Add(m, kalk.Nocne(okr));
                            FromTo ft = pracownik.WyliczOkresRoliczeniowyNadgodzin(okr.From);
                            ZestawienieNadgodzin zn = kalk.Nadgodziny(ft);
                            if ((zn.N50 + zn.N100 + zn.NSW) != Time.Zero) {
                                zn = kalk.Nadgodziny(okr);
                                nadlicz.Add(m, zn.N50 + zn.N100 + zn.NSW);
                            }
				        }

                        if (srpars.InfoORozliczeniu) {
                            Time p = Time.Zero;
                            Time k = Time.Zero;
                            foreach (Dzien dzn in kalk.KalkPracy[okr]) {
                                p += dzn.ZPrzeniesieniaWsp;
                                p -= dzn.DoPrzeniesienia;
                                k += dzn.ZPrzeniesienia - dzn.ZPrzeniesieniaWsp;
                            }
                            przeniesienie.Add(m, p);
                            przeniesienieKorekta.Add(m, k);
                        }
				
				        akordy.Add(m, kalk.KalkPracy.Odchylki(okr).Akordy);
                        
                        foreach (INieobecnosc nie in kalk.KalkPracy.Nieobecnosci(okr, true))
                            foreach (Date d in nie.Okres) {
                                Time czasNie = ((OkresNieobecności)nie).Norma(new FromTo(d, d)).Czas;
                                Dzien dzieńPlan = kalk.KalkPlanu[d];
                                if (dzieńPlan.Definicja.Typ == TypDnia.Pracy ||
                                    nie.Definicja.Typ == TypNieobecnosci.NieobecnośćZUS) {
                                    Add(items2, ht, nie, m, dzieńPlan.Czas, czasNie);
                                }
                            }
                    }
                    catch {
                        if (logInfo.Length > 0)
                            logInfo += ", ";
                        logInfo += "(" + okr.ToString() + ")";
                    }
                }
                if (log != null && logInfo.Length > 0)
                    log.WriteLine("Błąd dla " + pracownik + " - próba wykonania raportu dla pracownika rozliczanego wg zestawień czasu pracy w okresach: " + logInfo);
            }
			
            Grid2.DataSource = items2;
       }

       string KategoriaZUS(INieobecnosc nie) {
           string skrot = "";
           
            switch (nie.Definicja.Przyczyna) {
                case PrzyczynaNieobecnosci.NieusprawiedliwionaNiepłatna:
                    skrot = "NN"; break;
                case PrzyczynaNieobecnosci.UrlopWypoczynkowy:
                    skrot = "UW"; break;
                case PrzyczynaNieobecnosci.UrlopOkolicznościowy:
                    skrot = "Uok"; break;
                case PrzyczynaNieobecnosci.UrlopBezpłatny:
                    skrot = "UB"; break;
                case PrzyczynaNieobecnosci.UrlopWychowawczy:
                case PrzyczynaNieobecnosci.UrlopWychowawczyZUS:
                    skrot = "W"; break;
                case PrzyczynaNieobecnosci.ZwolnienieChorobowe:
                    if (nie.Zwolnienie.Przyczyna == PrzyczynaZwolnienia.LeczenieSzpitalne)
                        skrot = "Cs";
                    else
                        skrot = "Ch";
                    break;
                case PrzyczynaNieobecnosci.UrlopOpiekuńczy:
                    skrot = "OP"; break;
                case PrzyczynaNieobecnosci.UrlopMacierzyński:
                    skrot = "UM"; break;
                case PrzyczynaNieobecnosci.UrlopRehabilitacyjny:
                    skrot = "Reh"; break;
                case PrzyczynaNieobecnosci.BadanieLekarskie:
                    skrot = "BO"; break;
                case PrzyczynaNieobecnosci.DelegacjaSłużbowa:
                    skrot = "DS"; break;
                case PrzyczynaNieobecnosci.UrlopRodzicielski:
                    skrot = "UR"; break;
                case PrzyczynaNieobecnosci.UrlopOjcowski:
                    skrot = "Uoj"; break;
                default:
                    switch (nie.Definicja.Guid.ToString()) {
                        case "00000000-0006-0005-0029-000000000000": //"Urlop wypoczynkowy dodatkowy"
                            skrot = "UWD"; break;
                        case "00000000-0006-0005-0012-000000000000": //"Urlop opiekuńczy (art 188 kp, dni)"
                        case "00000000-0006-0005-0046-000000000000": //"Urlop opiekuńczy (art 188 kp, godz.)"
                            skrot = "UOp"; break;
                        default:
                            skrot = "NU"; break;
                    }
                    break;
            }

           return skrot;
       }
       
       public static void Msg(object obj) {
       }

       public static ReportHeader report;

       public static void Msg() {
           string msg = "Wydruk przygotowany na podstawie danych, do których operator ma prawa dostępu";
           if (report != null && !report.Title.Contains(msg))
               report.Title += "|" + msg;
       }

		</script>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<meta content="Microsoft Visual Studio 7.0" name="GENERATOR">
		<meta content="C#" name="CODE_LANGUAGE">
		<meta content="JavaScript" name="vs_defaultClientScript">
		<meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema">
	</HEAD>
	<body>
		<form id="EwidencjaCzasuPracyPodsumowanie" method="post" runat="server">
			<ea:datacontext id="dc" runat="server" oncontextload="OnContextLoad" TypeName="Soneta.Business.Row[], Soneta.Business" Landscape="True"></ea:datacontext>
            <cc1:reportheader NagłówekOddziału="NagłówekOddziału" id="ReportHeader1" title="Karta ewidencji czasu pracy - podsumowanie" runat="server"></cc1:reportheader>
				<ea:grid id="Grid2" runat="server" DataMember="DataSource">
					<Columns>
						<ea:GridColumn Width="30" DataMember="Nazwa" Caption=" "></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M1" Caption="I" HideZero="True" NoWrap="false"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M2" Caption="II" HideZero="True" NoWrap="false"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M3" Caption="III" HideZero="True" NoWrap="false"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M4" Caption="IV" HideZero="True" NoWrap="false"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M5" Caption="V" HideZero="True" NoWrap="false"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M6" Caption="VI" HideZero="True" NoWrap="false"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M7" Caption="VII" HideZero="True" NoWrap="false"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M8" Caption="VIII" HideZero="True" NoWrap="false"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M9" Caption="IX" HideZero="True" NoWrap="false"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M10" Caption="X" HideZero="True" NoWrap="false"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M11" Caption="XI" HideZero="True" NoWrap="false"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M12" Caption="XII" HideZero="True" NoWrap="false"></ea:GridColumn>
						<ea:GridColumn Width="8" Align="Right" DataMember="MR" Caption="Razem" HideZero="True"></ea:GridColumn>
					</Columns>
				</ea:grid>
				<cc1:reportfooter id="ReportFooter1" runat="server"></cc1:reportfooter>
			</form>
	</body>
</HTML>
