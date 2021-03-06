<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ Page Language="c#" autoeventwireup="false" CodePage="1200" %><%@ Register TagPrefix="cc1" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %><%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %><%@ import Namespace="Soneta.Kadry" %><%@ import Namespace="Soneta.Kalend" %><%@ import Namespace="Soneta.Place" %><%@ import Namespace="Soneta.Business" %><%@ import Namespace="Soneta.Tools" %><%@ import Namespace="Soneta.Types" %><%@ import Namespace="System.ComponentModel" %><%@ import Namespace="System.Diagnostics" %><%@ import Namespace="System.Collections.Generic" %><HTML><HEAD><TITLE>Ewidencja czasu pracy</TITLE>
<SCRIPT runat="server">
	
    abstract class Item: IComparable {
    
           public int CompareTo(object obj) {
               if (obj==null)
                   return 1;
               Item item = obj as Item;
               if (item==null)
                   throw new ArgumentException();
               return title.CompareTo(item.title);
           }
    
           protected class NieSum {
               public double kalend;
               public double pracy;
               public void Add(bool dodaj, double pracy) {
                   if (dodaj) kalend++;
                   if (pracy > 0)
                       this.pracy += pracy;
               }
               public void Add(NieSum ns) {
                   kalend += ns.kalend;
                   pracy += ns.pracy;
               }
           }

            
    
           public readonly string title;
           public readonly Hashtable nieobecności = new Hashtable();
           public readonly object[] dni = new object[31];
           public Time pracaCzas;
           public int pracaDni;
           public Time n50;
           public Time n100;
           public Time razem;
           public Time nocne;
           public bool msg; 
    
           protected Item(string title) {
               this.title = title;
           }
           public string NSInfo(string ss) {
               NieSum ns = (NieSum)nieobecności[ss];
               if (ns==null)
                   return "";
               return string.Format("{0}/{1}", ns.pracy, ns.kalend);
           }
       }
    
       class PracItem: Item {

           readonly SrParams srpars;

           public PracItem(Pracownik pracownik, SrParams srpars) : base(pracownik.ToString()) {
               this.srpars = srpars;
           }
           
           public Wydzial Fill(Pracownik pracownik, FromTo okres, Wydzial wydzial) {

				Periods zatr = Periods.Empty;
                Periods wgKalendarza = Periods.Empty;
               
				foreach (PracHistoria ph in pracownik.Historia.GetIntersectedRows(okres)) {
					FromTo eo = ph.Etat.EfektywnyOkres * okres;
                    if (wydzial == null || wydzial == ph.Etat.Wydzial) {
                        zatr += eo;
                        if (ph.Etat.InterpretacjaKalendarza!=InterpretacjaKalendarza.WgZestawien)
                            wgKalendarza += eo;
                    }
				}           
               
				zatr = zatr.ToFlat();
                wgKalendarza = wgKalendarza.ToFlat();
				
				if (zatr.Count==0)
					return null;

                KalkulatorPracownika kalk = new KalkulatorPracownika(pracownik, null);

                foreach (FromTo zatrudniony in zatr) {
                    kalk.KalkPracy.LoadOkres(zatrudniony);
                    Date prev = Date.Empty;
                    Time czasNie = Time.Zero;
                    foreach (INieobecnosc nie in kalk.Nieobecnosci(zatrudniony, true)) {
                        string info = KategoriaZUS(nie);
                        foreach (Date data in nie.Okres) {
                            string v = "";
                            Time cn = ((OkresNieobecności)nie).Norma(new FromTo(data, data)).Czas;
                            czasNie = (prev == data) ? (czasNie + cn) : cn;
                            Dzien dzieńPlan = kalk.KalkPlanu[data];
                            int i = data - okres.From;
                            if (dzieńPlan.Definicja.Typ == TypDnia.Pracy ||
                                nie.Definicja.Typ == TypNieobecnosci.NieobecnośćZUS) {
                                if (dzieńPlan.Czas - czasNie != Time.Zero)
                                    v = (dzieńPlan.Czas - czasNie).ToString() + "/";
                                dni[i] = v + info;
                            }
                            else if (srpars.NazwaMalymiLiterami) {
                                if (dzieńPlan.Czas - czasNie != Time.Zero)
                                    v = (dzieńPlan.Czas - czasNie).ToString() + "/";
                                dni[i] = v + info.ToLower();
                            }
                            else
                                dni[i] = "";

                            NieSum ns = (NieSum)nieobecności[info];
                            if (ns == null)
                                nieobecności.Add(info, ns = new NieSum());
                            double czas = 0;
                            if (dzieńPlan.Czas != Time.Zero)
                                czas = System.Math.Round(cn / dzieńPlan.Czas, 4);
                            ns.Add(prev!=data, czas);
                            prev = data;
                        }
                    }
                }

                foreach (FromTo zatrudniony in wgKalendarza)
                    foreach (Date data in zatrudniony) {
                        int i = data - okres.From;
                        if (dni[i] == null) {
                            Dzien dzieńPracy = kalk.KalkPracy[data];
                            dni[i] = dzieńPracy.Czas.ToString();
                        }
                    }
                
                foreach (Date data in okres) {
                    int i = data - okres.From;
                    if (dni[i] == null)
                        dni[i] = "&nbsp;";
                }

                foreach (FromTo zatrudniony in zatr) {
                    CzasDni cd = kalk.Praca(zatrudniony);
                    pracaDni += cd.Dni;
                    pracaCzas += cd.Czas;

                    if (srpars.NadgodzWgWyplat) {
                        Dictionary<RodzajŹródłaWypłaty, Dictionary<FromTo, Time>> lista = new Dictionary<RodzajŹródłaWypłaty, Dictionary<FromTo, Time>>();
                        SubTable st = PlaceModule.GetInstance(pracownik).WypElementy.WgPracownik[pracownik];
                        st = new SubTable(st, zatrudniony);
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
                                        n50 += czas; break;
                                    case RodzajŹródłaWypłaty.NadgodzinyII:
                                    case RodzajŹródłaWypłaty.NadgodzinyŚw:
                                        n100 += czas; break;
                                    case RodzajŹródłaWypłaty.Nocne:
                                        nocne += czas; break;
                                }
                            }
                            catch { msg = true; }
                        }
                    }
                    else {
                        nocne += kalk.Nocne(zatrudniony);
                        FromTo ft = pracownik.WyliczOkresRoliczeniowyNadgodzin(zatrudniony.From);
                        ZestawienieNadgodzin zn = kalk.Nadgodziny(ft);
                        if ((zn.N50 + zn.N100 + zn.NSW) != Time.Zero) {
                            zn = kalk.Nadgodziny(zatrudniony);
                            n50 += zn.N50;
                            n100 += zn.N100 + zn.NSW;
                        }
                    }
                    razem += n50 + n100;
                }

                Debug.Assert(pracownik[zatr.To].Etat.Wydzial != null);
                return pracownik[zatr.To].Etat.Wydzial;
           }
       }
    
       class SumItem: Item {
           public SumItem(string title): base(title) {
               for(int i=0; i<31; i++)
                   dni[i] = Time.Zero;
           }
           public void Add(Item item) {
               for(int i=0; i<31; i++)
                   if (item.dni[i] is Time)
                       dni[i] = (Time)dni[i] + (Time)item.dni[i];
    
               pracaDni += item.pracaDni;
               pracaCzas += item.pracaCzas;
    
               msg |= item.msg;
               n50 += item.n50;
               n100 += item.n100;
               razem += item.razem;
               nocne += item.nocne;
    
               foreach (string key in item.nieobecności.Keys) {
                   NieSum ns = (NieSum)nieobecności[key];
                   if (ns==null) {
                       ns = new NieSum();
                       nieobecności.Add(key, ns);
                   }
                   ns.Add((NieSum)item.nieobecności[key]);
               }
           }
       }
    
       class WdzItem: SumItem {
           public WdzItem(Wydzial wdz): base(wdz.ToString()) {
           }
       }
    
       void FillRow(Item item) {
           title.EditValue = item.title + (item.msg ? " - Wydruk przygotowany na podstawie danych, do których operator ma prawa dostępu" : "");
           p1.EditValue =  item.dni[0];
           p2.EditValue =  item.dni[1];
           p3.EditValue =  item.dni[2];
           p4.EditValue =  item.dni[3];
           p5.EditValue =  item.dni[4];
           p6.EditValue =  item.dni[5];
           p7.EditValue =  item.dni[6];
           p8.EditValue =  item.dni[7];
           p9.EditValue =  item.dni[8];
           p10.EditValue = item.dni[9];
           p11.EditValue = item.dni[10];
           p12.EditValue = item.dni[11];
           p13.EditValue = item.dni[12];
           p14.EditValue = item.dni[13];
           p15.EditValue = item.dni[14];
           p16.EditValue = item.dni[15];
           p17.EditValue = item.dni[16];
           p18.EditValue = item.dni[17];
           p19.EditValue = item.dni[18];
           p20.EditValue = item.dni[19];
           p21.EditValue = item.dni[20];
           p22.EditValue = item.dni[21];
           p23.EditValue = item.dni[22];
           p24.EditValue = item.dni[23];
           p25.EditValue = item.dni[24];
           p26.EditValue = item.dni[25];
           p27.EditValue = item.dni[26];
           p28.EditValue = item.dni[27];
           p29.EditValue = item.dni[28];
           p30.EditValue = item.dni[29];
           p31.EditValue = item.dni[30];
           
           n50.EditValue = item.n50;
           n100.EditValue = item.n100;
           razem.EditValue = item.razem;
           nocne.EditValue = item.nocne;

           if (item.NSInfo("NU").Length > 0 || item.NSInfo("UB").Length > 0)
               nu.EditValue = (item.NSInfo("NU").Length > 0 ? item.NSInfo("NU") : "-") + ";" +
                   (item.NSInfo("UB").Length > 0 ? item.NSInfo("UB") : "-");
           nn.EditValue = item.NSInfo("NN");
           if (item.NSInfo("OP").Length > 0 || item.NSInfo("Uoj").Length > 0)
               op.EditValue = (item.NSInfo("OP").Length > 0 ? item.NSInfo("OP") : "-") + ";" +
                   (item.NSInfo("Uoj").Length > 0 ? item.NSInfo("Uoj") : "-");
           if (item.NSInfo("UM").Length > 0 || item.NSInfo("UR").Length > 0 || item.NSInfo("Reh").Length > 0)
               um.EditValue = (item.NSInfo("UM").Length > 0 ? item.NSInfo("UM") : "-") + ";" +
                   (item.NSInfo("UR").Length > 0 ? item.NSInfo("UR") : "-") + ";" +
                   (item.NSInfo("Reh").Length > 0 ? item.NSInfo("Reh") : "-");
           w.EditValue = item.NSInfo("W");
           ch.EditValue = item.NSInfo("Ch");
           cs.EditValue = item.NSInfo("Cs");
           if (item.NSInfo("UOp").Length > 0 || item.NSInfo("Uok").Length > 0)
               uo.EditValue = (item.NSInfo("UOp").Length > 0 ? item.NSInfo("UOp") : "-") + ";" +
                   (item.NSInfo("Uok").Length > 0 ? item.NSInfo("Uok") : "-");
           bo.EditValue = item.NSInfo("BO");
           if (item.NSInfo("UW").Length > 0 || item.NSInfo("UWD").Length > 0)
               uw.EditValue = (item.NSInfo("UW").Length > 0 ? item.NSInfo("UW") : "-") + ";" +
                   (item.NSInfo("UWD").Length > 0 ? item.NSInfo("UWD") : "-");
           ds.EditValue = item.NSInfo("DS");

           dni.EditValue = item.pracaDni;
           czas.EditValue = item.pracaCzas;
       }
    
       FromTo okres;
       Wydzial wydzial;
    
       abstract class GridCaption {
           public abstract string Caption { get; }
           public abstract IEnumerable DataSource { get; }
       }
    
       class Prac: GridCaption {
           readonly Row[] rows;
           public override string Caption {
               get { return "Pracownik"; }
           }
           public Prac(Row[] rows) {
               this.rows = rows;
           }
           public override IEnumerable DataSource {
               get { return rows; }
           }
       }
       Prac prac;
    
       class Wydz: GridCaption {
           readonly Hashtable ht = new Hashtable();
           public override string Caption {
               get { return "Wydział"; }
           }
           public Wydz() {
           }
           public void Add(Wydzial wydzial, PracItem item) {
               SumItem sum = (SumItem)ht[wydzial];
               if (sum==null) {
                   sum = new WdzItem(wydzial);
                   ht.Add(wydzial, sum);
               }
               sum.Add(item);
           }
           public override IEnumerable DataSource {
               get {
                   ArrayList list = new ArrayList(ht.Values);
                   list.Sort();
                   return list;
               }
           }
       }
       Wydz wydz;
    
       class Razem: GridCaption {
           readonly SumItem item = new SumItem("Razem");
           public override string Caption {
               get { return "Razem"; }
           }
           public Razem() {
           }
           public void Add(PracItem item) {
               this.item.Add(item);
           }
           public override IEnumerable DataSource {
               get { return new object[] { item }; }
           }
       }
       Razem raz;
    
       public class PrnParams: ContextBase {
           public PrnParams(Context context): base(context) {
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
           Wydzial wydzial;
           [Priority(2)]
           [Browsable(true)]
           public Wydzial Wydzial {
               get { return wydzial; }
               set { 
				   wydzial = value; 
                   OnChanged(EventArgs.Empty);
				}
           }           
           bool pracownicy = true;
           [Priority(3)]
           public bool Pracownicy {
               get { return pracownicy; }
               set { 
					pracownicy = value; 
					OnChanged(EventArgs.Empty);
				}
           }
           bool wydziały = false;
           [Priority(4)]
           public bool Wydziały {
               get { return wydziały; }
               set { 
				   wydziały = value; 
                   OnChanged(EventArgs.Empty);
			   }
           }
           bool razem = false;
           [Priority(5)]
           public bool Razem {
               get { return razem; }
               set { 
				   razem = value; 
                   OnChanged(EventArgs.Empty);
				}
           }
	   }

       public class SrParams : SerializableContextBase {
           public SrParams(Context context) : base(context) {
           }

           //static bool pominNiezat = true;
           bool pominNiezat = true;
           [Priority(1)]
           [Caption("Pomiń niezatrudnionych")]
           public bool PominNiezat {
               get { return pominNiezat; }
               set {
                   pominNiezat = value;
                   OnChanged(EventArgs.Empty);
               }
           }

           //static bool nieZUSmałymiLiterami = true;
           bool nazwaMalymiLiterami = true;
           [Priority(2)]
           [Caption("Nazwa ZUS widoczna")]
           public bool NazwaMalymiLiterami {
               get { return nazwaMalymiLiterami; }
               set {
                   nazwaMalymiLiterami = value;
                   OnChanged(EventArgs.Empty);
               }
           }

           //Licz nadgodziny wg wypłat zamiast wg kalendarza
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
		            
       void OnContextLoad(Object sender, EventArgs args) {
           ReportHeader1["MIESIĄC"] = pars.Miesiąc.ToString();
           ReportHeader1["WYDZIAŁ"] = pars.Wydzial==null ? "" : "</strong>Wydział: <strong>" +pars.Wydzial.ToString();
           okres = pars.Miesiąc.ToFromTo();
           wydzial = pars.Wydzial;
           prac = new Prac((Row[])dc[typeof(Row[])]);
           wydz = new Wydz();
           raz = new Razem();
    
           ArrayList al = new ArrayList();
           if (pars.Pracownicy)
               al.Add(prac);
           else if(pars.Wydziały || pars.Razem)
               foreach (Pracownik idx in prac.DataSource)
                   NewItem(idx);
    
           if (pars.Wydziały)
               al.Add(wydz);
    
           if (pars.Razem)
               al.Add(raz);
    
           DataRepeater1.DataSource = al;
       }
    
       void DataRepeater1_BeforeRow(Object sender, EventArgs args) {
           GridCaption gc = (GridCaption)DataRepeater1.CurrentRow;
           title.Caption = gc.Caption;
       }

        PracItem NewItem(Pracownik idx) {
            PracItem item = new PracItem(idx, srpars);
            Wydzial w = item.Fill(idx, okres, wydzial);
            if (w == null && srpars.PominNiezat)
                return null;
            if (w != null)
                wydz.Add(w, item);
            raz.Add(item);
            return item;
        }
    
        void Grid1_BeforeRow(Object sender, RowEventArgs args) {
               object obj = args.Row;
               if (obj is Pracownik) {
                   PracItem item = NewItem((Pracownik)obj);
                   if (item!=null)
				       FillRow(item);
			       else
			           args.VisibleRow = false;
               }
               else
                   FillRow((SumItem)obj);
        }

        static string KategoriaZUS(INieobecnosc nie) {
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

		</SCRIPT>

<META content="text/html; charset=unicode" http-equiv=Content-Type>
<META name=GENERATOR content="Microsoft Visual Studio 7.0">
<META name=CODE_LANGUAGE content=C#>
<META name=vs_defaultClientScript content=JavaScript>
<META name=vs_targetSchema 
content=http://schemas.microsoft.com/intellisense/ie5></HEAD>
<BODY>
<FORM id=EwidencjaCzasuPracy method=post runat="server"><ea:datacontext id="dc" runat="server" Landscape="true" TypeName="Soneta.Business.Row[], Soneta.Business" oncontextload="OnContextLoad"></ea:datacontext><cc1:reportheader NagłówekOddziału="NagłówekOddziału" id="ReportHeader1" title="Ewidencja czasu pracy za %MIESIĄC%|%WYDZIAŁ%" runat="server"></cc1:reportheader><ea:datarepeater id="DataRepeater1" runat="server" Width="100%" OnBeforeRow="DataRepeater1_BeforeRow">
				<ea:PageBreak id="PageBreak1" runat="server" BreakFirstTimes="False"></ea:PageBreak>
				<ea:grid id="Grid1" runat="server" OnBeforeRow="Grid1_BeforeRow" DataMember="DataSource"
					RowsInRow="5">
					<Columns>
						<ea:GridColumn Width="4" Align="Right" DataMember="#" Caption=" " RowSpan="5"></ea:GridColumn>
						<ea:GridColumn ColSpan="16" BottomBorder="Single" Align="Left" Caption="Pracownik" ID="title" EncodeHTML="true"></ea:GridColumn>
						<ea:GridColumn Align="Right" Caption="1" ID="p1"></ea:GridColumn>
						<ea:GridColumn BottomBorder="Single" Align="Right" Caption="16" ID="p16"></ea:GridColumn>
						<ea:GridColumn Align="Right" Caption="Dni" ID="dni"></ea:GridColumn>
						<ea:GridColumn Align="Right" Caption="Godz." ID="czas"></ea:GridColumn>
						<ea:GridColumn Align="Right" Caption="2" ID="p2"></ea:GridColumn>
						<ea:GridColumn BottomBorder="Single" Align="Right" Caption="17" ID="p17"></ea:GridColumn>
						<ea:GridColumn ColSpan="3" Caption="Godz. nadliczb."></ea:GridColumn>
						<ea:GridColumn Align="Right" Caption="50%" ID="n50"></ea:GridColumn>
						<ea:GridColumn Align="Right" Caption="3" ID="p3"></ea:GridColumn>
						<ea:GridColumn BottomBorder="Single" Align="Right" Caption="18" ID="p18"></ea:GridColumn>
						<ea:GridColumn Align="Right" Caption="100%" ID="n100"></ea:GridColumn>
						<ea:GridColumn Align="Right" Caption="4" ID="p4"></ea:GridColumn>
						<ea:GridColumn BottomBorder="Single" Align="Right" Caption="19" ID="p19"></ea:GridColumn>
						<ea:GridColumn Align="Right" Caption="Razem" ID="razem"></ea:GridColumn>
						<ea:GridColumn Align="Right" Caption="5" ID="p5"></ea:GridColumn>
						<ea:GridColumn BottomBorder="Single" Align="Right" Caption="20" ID="p20"></ea:GridColumn>
						<ea:GridColumn Caption="Godz."></ea:GridColumn>
						<ea:GridColumn Align="Right" Caption="nocne" ID="nocne"></ea:GridColumn>
						<ea:GridColumn Align="Right" Caption="6" ID="p6"></ea:GridColumn>
						<ea:GridColumn BottomBorder="Single" Align="Right" Caption="21" ID="p21"></ea:GridColumn>
						<ea:GridColumn ColSpan="11" Caption=" "></ea:GridColumn>
						<ea:GridColumn Align="Center" Caption="NU;UB" ID="nu"></ea:GridColumn>
						<ea:GridColumn Align="Right" Caption="7" ID="p7"></ea:GridColumn>
						<ea:GridColumn BottomBorder="Single" Align="Right" Caption="22" ID="p22"></ea:GridColumn>
						<ea:GridColumn Align="Center" Caption="NN" ID="nn"></ea:GridColumn>
						<ea:GridColumn Align="Right" Caption="8" ID="p8"></ea:GridColumn>
						<ea:GridColumn BottomBorder="Single" Align="Right" Caption="23" ID="p23"></ea:GridColumn>
						<ea:GridColumn Align="Center" Caption="OP;Uoj" ID="op"></ea:GridColumn>
						<ea:GridColumn Align="Right" Caption="9" ID="p9"></ea:GridColumn>
						<ea:GridColumn BottomBorder="Single" Align="Right" Caption="24" ID="p24"></ea:GridColumn>
						<ea:GridColumn Align="Center" Caption="UM;UR;Reh" ID="um"></ea:GridColumn>
						<ea:GridColumn Align="Right" Caption="10" ID="p10"></ea:GridColumn>
						<ea:GridColumn BottomBorder="Single" Align="Right" Caption="25" ID="p25"></ea:GridColumn>
						<ea:GridColumn Align="Center" Caption="W" ID="w"></ea:GridColumn>
						<ea:GridColumn Align="Right" Caption="11" ID="p11"></ea:GridColumn>
						<ea:GridColumn BottomBorder="Single" Align="Right" Caption="26" ID="p26"></ea:GridColumn>
						<ea:GridColumn Align="Center" Caption="Ch" ID="ch"></ea:GridColumn>
						<ea:GridColumn Align="Right" Caption="12" ID="p12"></ea:GridColumn>
						<ea:GridColumn BottomBorder="Single" Align="Right" Caption="27" ID="p27"></ea:GridColumn>
						<ea:GridColumn Align="Center" Caption="Cs" ID="cs"></ea:GridColumn>
						<ea:GridColumn Align="Right" Caption="13" ID="p13"></ea:GridColumn>
						<ea:GridColumn BottomBorder="Single" Align="Right" Caption="28" ID="p28"></ea:GridColumn>
						<ea:GridColumn Align="Center" Caption="UOp;Uok" ID="uo"></ea:GridColumn>
						<ea:GridColumn Align="Right" Caption="14" ID="p14"></ea:GridColumn>
						<ea:GridColumn BottomBorder="Single" Align="Right" Caption="29" ID="p29"></ea:GridColumn>
						<ea:GridColumn Align="Center" Caption="BO" ID="bo"></ea:GridColumn>
						<ea:GridColumn Align="Right" Caption="15" ID="p15"></ea:GridColumn>
						<ea:GridColumn BottomBorder="Single" Align="Right" Caption="30" ID="p30"></ea:GridColumn>
						<ea:GridColumn Align="Center" Caption="UW;UWD" ID="uw"></ea:GridColumn>
						<ea:GridColumn Align="Right" Caption="X"></ea:GridColumn>
						<ea:GridColumn BottomBorder="Single" Align="Right" Caption="31" ID="p31"></ea:GridColumn>
						<ea:GridColumn Align="Center" Caption="DS" ID="ds"></ea:GridColumn>
					</Columns>
				</ea:grid>
			</ea:datarepeater><cc1:reportfooter id="ReportFooter1" runat="server"></cc1:reportfooter></FORM></BODY></HTML>
