<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ Page Language="c#" autoeventwireup="false" CodePage="1200" %><%@ Register TagPrefix="cc1" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %><%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %><%@ import Namespace="System.Diagnostics" %><%@ import Namespace="Soneta.Tools" %><%@ import Namespace="Soneta.Business" %><%@ import Namespace="Soneta.Kalend" %><%@ import Namespace="Soneta.Place" %><%@ import Namespace="Soneta.Kadry" %><%@ import Namespace="Soneta.Types" %><HTML><HEAD><TITLE>Karta wynagrodzeń</TITLE>
<SCRIPT runat="server">

            public enum WgParametr {
                WgDatyWypłaty,
                WgOkresuElementu,
                WgOkresuListyPłac,
                [Caption("Wg miesiąca ZUS")]
                WgMiesiącaZUS,                
            }
  
            public class StaticParams : SerializableContextBase {
                public StaticParams(Context context): base(context) {
                }
                                
                //Czy na wydruku ma być drukowana informacja o normie czasu pracy
                bool normaInfo = true;
                [Priority(10)]
                [Caption("Podsumowanie normy")]
                public bool NormaInfo {
                    get { return normaInfo; }
                    set {
                        normaInfo = value;
                        OnChanged(EventArgs.Empty);
                    }
                }

                //Czy na wydruku ma być drukowana informacja rzeczywistym czasie
                bool pracaInfo = true;
                [Priority(20)]
                [Caption("Podsumow.czasu pracy")]
                public bool PracaInfo {
                    get { return pracaInfo; }
                    set {
                        pracaInfo = value;
                        OnChanged(EventArgs.Empty);
                    }
                }

                //Informacja o rzeczywistym czasie pracy wg naliczonych wynagrodzeń
                bool pracaInfoWgWypłat = false;
                [Priority(30)]
                [Caption("... wg wynagrodzeń")]
                public bool PracaInfoWgWypłat {
                    get { return pracaInfoWgWypłat; }
                    set {
                        pracaInfoWgWypłat = value;
                        OnChanged(EventArgs.Empty);
                    }
                }

                public bool IsReadOnlyPracaInfoWgWypłat() {
                    return !pracaInfo;
                }

                //Czy drukować poszczególne składki ZUS
                bool zusInfo = false;
                [Priority(40)]
                [Caption("Szczegółowe skł.ZUS")]
                public bool ZusInfo {
                    get { return zusInfo; }
                    set {
                        zusInfo = value;
                        OnChanged(EventArgs.Empty);
                    }
                }
            }

            [SettingsContext]
            public StaticParams StaticPars {
                set {
                    normaInfo = value.NormaInfo;
                    pracaInfo = value.PracaInfo;
                    pracaInfoWgWypłat = value.PracaInfoWgWypłat;
                    zusInfo = value.ZusInfo;
                }
            }

    static WgParametr wypłatyWgDaty;
	static bool normaInfo;
	static bool pracaInfo;
    static bool pracaInfoWgWypłat;
    static bool zusInfo;        
	
    class Total: IComparable {
    
           abstract class Item: IComparable {
               readonly string nazwa;
               readonly int priorytet;
               readonly protected object[] m = new object[12];
               protected bool narastająco = false;
               protected Item(string nazwa, int priorytet) {
                   this.nazwa = nazwa;
                   this.priorytet = priorytet;
               }
               public string Nazwa {
                   get { return nazwa; }
               }
               public object M1 { get { return m[0]; } }
               public object M2 { get { return m[1]; } }
               public object M3 { get { return m[2]; } }
               public object M4 { get { return m[3]; } }
               public object M5 { get { return m[4]; } }
               public object M6 { get { return m[5]; } }
               public object M7 { get { return m[6]; } }
               public object M8 { get { return m[7]; } }
               public object M9 { get { return m[8]; } }
               public object M10 { get { return m[9]; } }
               public object M11 { get { return m[10]; } }
               public object M12 { get { return m[11]; } }
    
               public abstract object Razem { get; }    
               public abstract void Narastająco();
    
               public int CompareTo(object obj) {
                   if (obj==null)
                       return 1;
                   Item i = obj as Item;
                   if (i==null)
                       throw new ArgumentException();
                   int res = priorytet.CompareTo(i.priorytet);
                   if (res==0)
                       res = nazwa.CompareTo(i.nazwa);
                   return res;
               }
           }
    

			class DecimalItem: Item {				    
               public DecimalItem(string nazwa, int priorytet): base(nazwa, priorytet) {
                   for (int i=0; i<12; i++)
						m[i] = 0m;
               }
               bool any = false;
               public bool Any { get { return any; } }
                		    
               public void Add(decimal v, int miesiąc) {
                   any = true;
					m[miesiąc-1] = (decimal)m[miesiąc-1] + v;
               }
               public override object Razem {
                   get {
                       decimal result = 0;
                       if (!narastająco)
                           for (int i=0; i<12; i++)                           
								result += (decimal)m[i];
                       return result;
                   }
               }
               public override void Narastająco() {
                   narastająco = true;
                   for (int i=1; i<12; i++)
                       m[i] = (decimal)m[i-1] + (decimal)m[i];
               }
               public bool IsEmpty() {
                   for (int i = 0; i < 12; i++)
                       if ((decimal)m[i] != 0m)
                           return false;
                   return true;
               }
            }

			class IntItem: Item {				    
               public IntItem(string nazwa, int priorytet): base(nazwa, priorytet) {
                   for (int i=0; i<12; i++)
						m[i] = 0;
               }				    
               public void Add(int v, int miesiąc) {
					m[miesiąc-1] = (int)m[miesiąc-1] + v;
               }
               public override object Razem {
                   get {
                       int result = 0;
                       if (!narastająco)
                           for (int i=0; i<12; i++)                           
								result += (int)m[i];
                       return result;
                   }
               }    
               public override void Narastająco() {
                   narastająco = true;
                   for (int i=1; i<12; i++)
                       m[i] = (int)m[i-1] + (int)m[i];
               }               
           }

			class TimeItem: Item {				    
               public TimeItem(string nazwa, int priorytet): base(nazwa, priorytet) {
                   for (int i=0; i<12; i++)
						m[i] = Time.Zero;
               }				    
               public void Add(Time v, int miesiąc) {
					m[miesiąc-1] = (Time)m[miesiąc-1] + v;
               }
               public override object Razem {
                   get {
                       Time result = Time.Zero;
                       if (!narastająco)
                           for (int i=0; i<12; i++)                           
								result += (Time)m[i];
                       return result;
                   }
               }    
               public override void Narastająco() {
                   narastająco = true;
                   for (int i=1; i<12; i++)
                       m[i] = (Time)m[i-1] + (Time)m[i];
               }               
           }
                
           readonly public bool liczCzasPracy = false;
           readonly Pracownik pracownik;
           readonly Przychody przychody;
           readonly PracHistoria historia;
           readonly ArrayList result = new ArrayList();
           readonly ArrayList result2 = new ArrayList();
           
           public Total(Pracownik pracownik, FromTo okres, Przychody przychody) {
               this.pracownik = pracownik;
			   this.przychody = przychody;
               this.historia = pracownik[okres.To];
               PlaceModule pl = PlaceModule.GetInstance(pracownik);

               SubTable st;
               switch (wypłatyWgDaty) {
                   case WgParametr.WgMiesiącaZUS:
                       st = pl.WypElementy.WgMiesiacZUS[pracownik]; break;
                   case WgParametr.WgDatyWypłaty:
                       st = pl.WypElementy.WgDaty[pracownik]; break;
                   case WgParametr.WgOkresuListyPłac:
                       st = pl.WypElementy.WgOkresuListy[pracownik]; break;
                   default:
                       st = pl.WypElementy.WgPracownik[pracownik]; break;
               }
               st = new SubTable(st, okres);
               Hashtable elementy = new Hashtable();
               foreach (WypElement e in st) {
                   try {
                       if (Filter(e.Wyplata) && !WypłataPoZgonie(e.Wyplata)) {
						    liczCzasPracy |= e.Wyplata is WyplataEtat;
                            ArrayList al = (ArrayList)elementy[e.Definicja];
                            if (al==null) {
                                al = new ArrayList();
                                elementy.Add(e.Definicja, al);
                            }
                            al.Add(e);
                       }
                   }
                   catch { Msg(false); }
               }
                       
               if (elementy.Count>0) {
                   result.Add(new DecimalItem("<b>WYNAGRODZENIE i POTRĄCENIA</b>", 0));
                              
                   DecimalItem brutto = new DecimalItem("<b>Razem brutto</b>", 10);
                   result.Add(brutto);
                   DecimalItem podstawaZUS = new DecimalItem("Podstawa składek na ub. społeczne (narastająco)", 20);
                   result.Add(podstawaZUS);
                   DecimalItem zus = new DecimalItem("Składki na ubezpieczenia społeczne", 30);
                   DecimalItem emer = new DecimalItem("Składki na ubezpieczenie emerytalne", 31);
                   DecimalItem rent = new DecimalItem("Składki na ubezpieczenie rentowe", 32);
                   DecimalItem chor = new DecimalItem("Składki na ubezpieczenie chorobowe", 33);
                   DecimalItem wyp = new DecimalItem("Składki na ubezpieczenie wypadkowe", 34);
                   if (!zusInfo)
                       result.Add(zus);
                   else {
                       result.Add(emer);
                       result.Add(rent);
                       result.Add(chor);
                       result.Add(wyp);
                   }
                   DecimalItem koszty = new DecimalItem("Koszty uzyskania", 40);
                   result.Add(koszty);
                   DecimalItem podstawa = new DecimalItem("<b>Podstawa opodatkowania</b>", 50);
                   result.Add(podstawa);
                   DecimalItem ulga = new DecimalItem("Ulga podatkowa", 60);
                   result.Add(ulga);
                   DecimalItem zdrow775 = new DecimalItem("<b>Składka na ubezp. zdrowotne do '7,75%'</b>", 70);
                   result.Add(zdrow775);
                   DecimalItem zdrow025 = new DecimalItem("<b>Składka na ubezp. zdrowotne ponad '7,75%'</b>", 80);
                   result.Add(zdrow025);
                   DecimalItem zan = new DecimalItem("Zaniechanie poboru zaliczki podatku", 90);
                   result.Add(zan);
                   DecimalItem pit = new DecimalItem("<b>Zaliczka podatku do odprowadz. do US</b>", 100);
                   result.Add(pit);
                   DecimalItem netto = new DecimalItem("Wynagrodzenie netto miesięczne", 110);
                   result.Add(netto);
                   DecimalItem narastająco = new DecimalItem("Wynagrodzenie netto narastająco", 120);
                   result.Add(narastająco);
                   DecimalItem wypłata = new DecimalItem("Wypłata", 130);
                   result.Add(wypłata);

                   foreach (DefinicjaElementu def in elementy.Keys) {
                       bool opodat = def.Info.Opodatkowany;
                       DecimalItem itemO = new DecimalItem(def.Nazwa, 0);
                       DecimalItem itemN = new DecimalItem(def.Nazwa, 11);
                       foreach (WypElement e in (IEnumerable)elementy[def]) {
                           int m;
                           switch (wypłatyWgDaty) {
                               case WgParametr.WgMiesiącaZUS:
                                   m = e.MiesiacZUS.Month; break;
                               case WgParametr.WgDatyWypłaty:
                                   m = e.Data.Month; break;
                               case WgParametr.WgOkresuListyPłac:
                                   m = e.OkresListy.To.Month; break;
                               default:
                                   m = e.Okres.To.Month; break;
                           }
                           if (e.DoOpodatkowania != 0)
                               itemO.Add(e.DoOpodatkowania, m);
                           if (e.NiePodlegaOpodatkowaniu != 0)
                               itemN.Add(e.NiePodlegaOpodatkowaniu, m);

                           decimal sz = e.Podatki.KosztyZUS;
                           //TID: 3997, tyle że tutaj akurat był to błąd
                           //decimal z775 = e.Podatki.ZdrowotneFaktycznieOdliczon e;
                           decimal z775 = e.Podatki.ZdrowotneDoOdliczenia;
                           decimal z025 = e.Podatki.Zdrowotna.Prac - z775;

                           if (opodat) {
                               //TID: 7859
                               //decimal w = e.Wartosc;
                               decimal w = e.DoOpodatkowania;
                               decimal k = e.Podatki.KosztyPIT;
                               decimal zf = e.Podatki.Zaniechanie;
                               decimal f = e.Podatki.ZalFIS;
                               decimal n = w - sz - z775 - z025 - f;
                               brutto.Add(w, m);
                               koszty.Add(k, m);
                               podstawa.Add(w - sz - k, m);
                               ulga.Add(e.Podatki.Ulga, m);
                               zan.Add(zf, m);
                               pit.Add(f, m);
                               netto.Add(n, m);
                               narastająco.Add(n, m);
                           }

                           decimal pzus = e.Podatki.Emerytalna.Podstawa;
                           podstawaZUS.Add(pzus, m);

                           zus.Add(sz, m);
                           emer.Add(e.Podatki.Emerytalna.Prac, m);
                           rent.Add(e.Podatki.Rentowa.Prac, m);
                           chor.Add(e.Podatki.Chorobowa.Prac, m);
                           wyp.Add(e.Podatki.Wypadkowa.Prac, m);

                           zdrow775.Add(z775, m);
                           zdrow025.Add(z025, m);

                           wypłata.Add(e.DoWypłaty, m);
                       }
                       if (itemO.Any)
                           result.Add(itemO);
                       if (itemN.Any)
                           result.Add(itemN);
                   }
    
					if (liczCzasPracy)
						LiczCzasPracy(okres);
						
					narastająco.Narastająco();
					podstawaZUS.Narastająco();
					result.Sort();

                    if (wyp.IsEmpty())
                        result.Remove(wyp);
				}
			}
			bool Filter(Soneta.Place.Wyplata w) {
				switch(przychody) {
					case Przychody.PracownikaZleceniobiorcy:
						return true;
					default:
						return (w.Typ==TypWyplaty.Umowa)==(przychody==Przychody.Zleceniobiorcy);
				}
			}
			void LiczCzasPracy(FromTo okres) {
				IntItem ndni = null;
				TimeItem nczas = null;
				if (normaInfo) {
					result2.Add(new IntItem("<b>NORMA CZASU PRACY</b>", 0));
					ndni = new IntItem("Dni pracy", 1);
					result2.Add(ndni);
					nczas = new TimeItem("Czas pracy", 2);
					result2.Add(nczas);
                }
                
                IntItem dni = null;
                TimeItem akordy = null;
                TimeItem czas = null;
                TimeItem n50 = null;
                TimeItem n100 = null;
                if (pracaInfo) {
					result2.Add(new IntItem("<b>RZECZYWISTY CZAS PRACY</b>", 3));
					dni = new IntItem("Dni pracy", 4);
					result2.Add(dni);
					akordy = new TimeItem("Czas pracy na akordach", 5);
					result2.Add(akordy);
					czas = new TimeItem("Pozostały czas pracy", 6);
					result2.Add(czas);
					n50 = new TimeItem("&nbsp;&nbsp;&nbsp;&nbsp;w tym czas pracy z dopłatą 50%", 7);
					result2.Add(n50);
					n100 = new TimeItem("&nbsp;&nbsp;&nbsp;&nbsp;w tym czas pracy z dopłatą 100%", 8);
					result2.Add(n100);
				}
                
                Periods zatrudniony = Periods.Empty;
                foreach (PracHistoria ph in pracownik.Historia.GetIntersectedRows(okres))
					zatrudniony += ph.Etat.EfektywnyOkres;
				zatrudniony = zatrudniony.ToFlat();
				zatrudniony *= okres;
				zatrudniony = zatrudniony.BreakByMonth();
				
				KalkulatorPracownika kalk = new KalkulatorPracownika(pracownik);
					
				foreach (FromTo zatr in zatrudniony) {
					int m = zatr.To.Month;
				
					if (pracaInfo)
						try {
                            if (pracaInfoWgWypłat) {
                                SubTable st = PlaceModule.GetInstance(pracownik).WypElementy.WgPracownik[pracownik];
                                st = new SubTable(st, zatr);
                                foreach (WypElement element in st) {
                                    try {
                                        switch (element.RodzajZrodla) {
                                            case RodzajŹródłaWypłaty.NadgodzinyI:
                                                n50.Add(element.Czas, m); break;
                                            case RodzajŹródłaWypłaty.NadgodzinyII:
                                            case RodzajŹródłaWypłaty.NadgodzinyŚw:
                                                n100.Add(element.Czas, m); break;
                                            case RodzajŹródłaWypłaty.Etat:
                                                dni.Add(element.Dni, m);
                                                czas.Add(element.Czas, m);
                                                foreach (WypSkladnikOdchyłka.AkordMinus sam in element[RodzajSkładnikaWypłaty.OdchyłkaAkordMinus])
                                                    akordy.Add(-sam.Czas, m);
                                                break;
                                        }
                                    }
                                    catch { Msg(false); }
                                } 
                            }
                            else {
                                CzasDni cd = kalk.Praca(zatr);
                                ZestawienieNadgodzin nad = kalk.Nadgodziny(zatr);
                                Odchylka odch = kalk.KalkPracy.Odchylki(zatr);

                                dni.Add(cd.Dni, m);
                                akordy.Add(odch.Akordy, m);
                                czas.Add(cd.Czas - odch.Akordy, m);
                                n50.Add(nad.N50, m);
                                n100.Add(nad.N100 + nad.NSW, m);
                            }
						}
						catch {
						}
					
					if (normaInfo) {
						CzasDni ncd = kalk.Norma(zatr);	
						ndni.Add(ncd.Dni, m);
						nczas.Add(ncd.Czas, m);
					}					
				}
           }
           public Pracownik Pracownik {
               get { return pracownik; }
           }
           public PracHistoria Historia {
               get { return historia; }
           }
           public Przychody Przychody {
               get { return przychody; }
           }
           public bool Wchodzi {
               get { return result.Count>0; }
           }
           public IEnumerable Elementy {
               get { return result; }
           }
           public IEnumerable Praca {
               get { return result2; }
           }
           public int CompareTo(object obj) {
               if (obj==null)
                   return 1;
               Total t = obj as Total;
               if (t==null)
                   throw new ArgumentException();
               return pracownik.CompareTo(t.pracownik);
           }
       }
       
		[Flags]
		public enum Przychody {
			Pracownika					= 0x01, 
			Zleceniobiorcy				= 0x02, 
			[Caption("Pracownika/Zleceniobiorcy")]
			PracownikaZleceniobiorcy	= Pracownika|Zleceniobiorcy,
			Razem						= 0x99,
		}
    
       public class PrnParams: Soneta.Business.ContextBase {
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

           Przychody przychody = Przychody.Pracownika;
           [Priority(2)]
           public Przychody Przychody {
                get { return przychody; }
                set { 
                    przychody = value; 
                    OnChanged(EventArgs.Empty);
                }
            }

            //Wydruk ma być drukowany wg daty wypłaty (true),
            //czy wg okresu za który zostały one zrealizowane (false)                
            WgParametr wypłatyWgDaty = WgParametr.WgDatyWypłaty;
            [Priority(3)]
            [Caption("Wypłaty")]
            public WgParametr WypłatyWgDaty {
                get { return wypłatyWgDaty; }
                set {
                    wypłatyWgDaty = value;
                    OnChanged(EventArgs.Empty);
                }
            }
       }
    
		PrnParams pars;
		[Soneta.Business.Context(Required=true)]
		public PrnParams Params {
			get { return pars; }
			set {
                wypłatyWgDaty = value.WypłatyWgDaty;
                pars = value;
            }
		}
    
		string nazwaOkresu;
       
		void OnContextLoad(Object sender, EventArgs args) {
            report = ReportHeader1;
			if (pars.Okres == FromTo.Year(pars.Okres.From.Year))
				nazwaOkresu = pars.Okres.From.Year + " rok";
			else
				nazwaOkresu = "okres " + pars.Okres.ToString();

			Row[] rows = (Row[])dc[typeof(Row[])];
			ArrayList result = new ArrayList();
			foreach (Pracownik idx in rows) 
				if (pars.Przychody==Przychody.Razem)
					Przelicz(result, idx, Przychody.PracownikaZleceniobiorcy);
				else {
					Przelicz(result, idx, Przychody.Pracownika);
					Przelicz(result, idx, Przychody.Zleceniobiorcy);
				}

			DataRepeater1.DataSource = result;
		}
    
		void Przelicz(ArrayList lista, Pracownik pracownik, Przychody przychody) {
			if ((pars.Przychody&przychody)!=0) {
				Total t = new Total(pracownik, pars.Okres, przychody);
				if (t.Wchodzi)
					lista.Add(t);
			}
		}
    
		void OnBeforeRow(Object sender, EventArgs args) {
           Total t = (Total)DataRepeater1.CurrentRow;
           
			if (!t.liczCzasPracy) {
				Grid1.ShowHeader = ShowHeader.Default;
				Grid2.Visible = false;
			}
			else {
				Grid1.ShowHeader = ShowHeader.None;
				Grid2.Visible = true;
			}
			
			string info;
			if (t.Przychody!=Przychody.PracownikaZleceniobiorcy)
				info = " " + t.Przychody.ToString().ToLower();
			else
				info = "";
			
           string msg = Msg(true);
           ReportHeader1.Title = string.Format("Karta wynagrodzeń{7} za {0} ({8})|{1}|</strong>Urodzony: <strong>{2}</strong>, <strong>{3}|</strong>NIP: <strong>{4}</strong>, PESEL: <strong>{5}|</strong>Adres: <strong>{6}|{9}",
               nazwaOkresu,
               t.Pracownik.NazwiskoImię,
               t.Historia.Urodzony.Data, t.Historia.Urodzony.Miejsce,
               t.Historia.NIP, t.Historia.PESEL,
               t.Historia.Adres,
               info,
               CaptionAttribute.EnumToString(wypłatyWgDaty).ToLower(),
               msg);
       }
    
    public static bool WypłataPoZgonie(Soneta.Place.Wyplata wypłata) {
		WyplataUmowa wu = wypłata as WyplataUmowa;
		Ubezpieczenia ubezpieczenia = null;
		if (wu!=null) {
			Umowa umowa = wu.Umowa;
			if (umowa!=null)
                ubezpieczenia = umowa[wypłata.Data].Ubezpieczenia;
		}
		else
			ubezpieczenia = wypłata.Pracownik[wypłata.ListaPlac.Okres.To].Etat.Ubezpieczenia;
		
		return ubezpieczenia!=null && ubezpieczenia.Zdrowotne.ZgonPracownika(wypłata.Data);
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

		</SCRIPT>

<META content="text/html; charset=unicode" http-equiv=Content-Type>
<META name=GENERATOR content="Microsoft Visual Studio 7.0">
<META name=CODE_LANGUAGE content=C#>
<META name=vs_defaultClientScript content=JavaScript>
<META name=vs_targetSchema 
content=http://schemas.microsoft.com/intellisense/ie5></HEAD>
<BODY>
<FORM id=KartaWynagrodzeń method=post runat="server"><ea:datacontext id="dc" runat="server" oncontextload="OnContextLoad"
				Landscape="True"></ea:datacontext><ea:datarepeater id="DataRepeater1" runat="server" onbeforerow="OnBeforeRow" Width="100%" Height="140px">
				<ea:PageBreak id="PageBreak1" runat="server" BreakFirstTimes="False"></ea:PageBreak>
				<FONT face="Tahoma">
					<cc1:ReportHeader NagłówekOddziału="NagłówekOddziału" id="ReportHeader1" title="Karta wynagrodzeń" runat="server"></cc1:ReportHeader></FONT>
				<ea:Grid id="Grid2" runat="server" DataMember="Praca">
					<Columns>
						<ea:GridColumn Width="42" DataMember="Nazwa" Caption="Nazwa" NoWrap="True"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M1" Caption="I" HideZero="True" Format="{0}"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M2" Caption="II" HideZero="True" Format="{0}"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M3" Caption="III" HideZero="True" Format="{0}"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M4" Caption="IV" HideZero="True" Format="{0}"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M5" Caption="V" HideZero="True" Format="{0}"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M6" Caption="VI" HideZero="True" Format="{0}"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M7" Caption="VII" HideZero="True" Format="{0}"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M8" Caption="VIII" HideZero="True" Format="{0}"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M9" Caption="IX" HideZero="True" Format="{0}"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M10" Caption="X" HideZero="True" Format="{0}"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M11" Caption="XI" HideZero="True" Format="{0}"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M12" Caption="XII" HideZero="True" Format="{0}"></ea:GridColumn>
						<ea:GridColumn Width="12" Align="Right" DataMember="Razem" Caption="Razem" HideZero="True" Format="{0}"></ea:GridColumn>
					</Columns>
				</ea:Grid>
				<ea:Grid id="Grid1" runat="server" DataMember="Elementy">
					<Columns>
						<ea:GridColumn Width="42" DataMember="Nazwa" Caption="Nazwa" NoWrap="True"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M1" Caption="I" HideZero="True" Format="{0:n}"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M2" Caption="II" HideZero="True" Format="{0:n}"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M3" Caption="III" HideZero="True" Format="{0:n}"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M4" Caption="IV" HideZero="True" Format="{0:n}"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M5" Caption="V" HideZero="True" Format="{0:n}"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M6" Caption="VI" HideZero="True" Format="{0:n}"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M7" Caption="VII" HideZero="True" Format="{0:n}"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M8" Caption="VIII" HideZero="True" Format="{0:n}"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M9" Caption="IX" HideZero="True" Format="{0:n}"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M10" Caption="X" HideZero="True" Format="{0:n}"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M11" Caption="XI" HideZero="True" Format="{0:n}"></ea:GridColumn>
						<ea:GridColumn Align="Right" DataMember="M12" Caption="XII" HideZero="True" Format="{0:n}"></ea:GridColumn>
						<ea:GridColumn Width="12" Align="Right" DataMember="Razem" Caption="Razem" HideZero="True" Format="{0:n}"></ea:GridColumn>
					</Columns>
				</ea:Grid>
				<cc1:ReportFooter id="ReportFooter1" runat="server"></cc1:ReportFooter>
			</ea:datarepeater> 
</FORM></BODY></HTML>
