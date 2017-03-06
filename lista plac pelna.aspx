<%@ Page Language="c#" CodePage="1200" %>
<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %>
<%@ Register TagPrefix="cc1" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %>
<%@ import Namespace="Soneta.Business" %>
<%@ import Namespace="Soneta.Tools" %>
<%@ import Namespace="Soneta.Types" %>
<%@ import Namespace="Soneta.Kalend" %>
<%@ import Namespace="Soneta.Kadry" %>
<%@ import Namespace="Soneta.Place" %>
<%@ import Namespace="System.Collections.Generic" %>
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
        [Priority(1)]
        public bool Paski {
            get { return paski; }
            set { paski = value; }
        }
    
        bool sumy = false;
        [Caption("Suma dla pracownika")]
        [Priority(2)]
        public bool Sumy {
            get { return sumy; }
            set { sumy = value; }
        }
    }

    public class SrParams : SerializableContextBase {
        public SrParams(Context context) : base(context) {
        }

        //static bool fundusze = false;
        bool fundusze = true;
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
        
        //static bool procentInfo = false;
        bool procentInfo = false;
        [Priority(3)]
        [Caption("Informacja procentowa")]
        public bool ProcentInfo {
            get { return procentInfo; }
            set {
                procentInfo = value;
                OnChanged(EventArgs.Empty);
            }
        }
        
        //static bool skladnikiInfo = false;
        bool skladnikiInfo = false;
        [Priority(4)]
        [Caption("Składniki")]
        public bool SkladnikiInfo {
            get { return skladnikiInfo; }
            set {
                skladnikiInfo = value;
                OnChanged(EventArgs.Empty);
            }
        }
        
        //static bool nieobecnościInfo = false;
        bool nieobecnościInfo = false;
        [Priority(5)]
        [Caption("Nieobecności")]
        public bool NieobecnościInfo {
            get { return nieobecnościInfo; }
            set {
                nieobecnościInfo = value;
                OnChanged(EventArgs.Empty);
            }
        }
                
        //static bool nazwaWNaglowku = false;
        bool nazwaWNaglowku = false;
        [Priority(6)]
        [Caption("Nazwa w nagłówku")]
        public bool NazwaWNaglowku {
            get { return nazwaWNaglowku; }
            set {
                nazwaWNaglowku = value;
                OnChanged(EventArgs.Empty);
            }
        }
        
        //static bool zdrowotneInfo = false;
        bool zdrowotneInfo = true;
        [Priority(7)]
        [Caption("Ubezp. zdrowotne")]
        public bool ZdrowotneInfo {
            get { return zdrowotneInfo; }
            set {
                zdrowotneInfo = value;
                OnChanged(EventArgs.Empty);
            }
        }
        
        //static bool procentPit = false;
        bool procentPit = false;
        [Priority(8)]
        [Caption("Procent PIT")]
        public bool ProcentPit {
            get { return procentPit; }
            set {
                procentPit = value;
                OnChanged(EventArgs.Empty);
            }
        }
                
        //static bool pracaInfo = false;
        bool pracaInfo = false;
        [Priority(9)]
        [Caption("Informacja o pracy")]
        public bool PracaInfo {
            get { return pracaInfo; }
            set {
                pracaInfo = value;
                OnChanged(EventArgs.Empty);
            }
        }

        bool planInfo = false;
        [Priority(10)]
        [Caption("Informacja o normie")]
        public bool PlanInfo {
            get { return planInfo; }
            set {
                planInfo = value;
                OnChanged(EventArgs.Empty);
            }
        }
                        
        //static bool stawkaZaszeregowaniaInfo = false;
        bool stawkaZaszeregowaniaInfo = false;
        [Priority(11)]
        [Caption("Stawka zaszeregowania")]
        public bool StawkaZaszeregowaniaInfo {
            get { return stawkaZaszeregowaniaInfo; }
            set {
                stawkaZaszeregowaniaInfo = value;
                OnChanged(EventArgs.Empty);
            }
        }
        
        //static bool zestawieniePrzelewów = false;
        bool zestawieniePrzelewów = false;
        [Priority(12)]
        [Caption("Zestawienie przelewów")]
        public bool ZestawieniePrzelewów {
            get { return zestawieniePrzelewów; }
            set {
                zestawieniePrzelewów = value;
                OnChanged(EventArgs.Empty);
            }
        }
        
        //Jeżeli flaga jest ustawiona na TAK to flagi procentInfo oraz nieobecnościInfo są ignorowane
        //static bool sumujElementyWgDefinicji = false;
        bool sumujElementyWgDefinicji = false;
        [Priority(13)]
        [Caption("Sumuj elem. wg definicji")]
        public bool SumujElementyWgDefinicji {
            get { return sumujElementyWgDefinicji; }
            set {
                sumujElementyWgDefinicji = value;
                OnChanged(EventArgs.Empty);
            }
        }

        //static bool stanowiskoInfo = false;
        bool stanowiskoInfo = false;
        [Priority(14)]
        [Caption("Stanowiska")]
        public bool StanowiskoInfo {
            get { return stanowiskoInfo; }
            set {
                stanowiskoInfo = value;
                OnChanged(EventArgs.Empty);
            }
        }
        
        bool pelneStanowisko = false;
        [Priority(15)]
        [Caption("Stanowisko pełna nazwa")]
        public bool PelneStanowisko {
            get { return pelneStanowisko; }
            set {
                pelneStanowisko = value;
                OnChanged(EventArgs.Empty);
            }
        }

        public bool IsReadOnlyPelneStanowisko() {
            return !stanowiskoInfo;
        }

        bool skladki = false;
        [Caption("Podstawy składek")]
        [Priority(16)]
        public bool Skladki {
            get { return skladki; }
            set { skladki = value; }
        }

        bool zero = false;
        [Caption("Elementy zerowe")]
        [Priority(17)]
        public bool Zero {
            get { return zero; }
            set { zero = value; }
        }
    }
		    
    SrParams srpars;
    [SettingsContext]
    public SrParams SrPars {
        get { return srpars; }
        set { srpars = value; }
    }		
		                                    
    Currency brutto = 0;
    Hashtable elements = new Hashtable();

    decimal sumaEmerPodst = 0;
    decimal sumaRentPodst = 0;
    decimal sumaChorPodst = 0;
    decimal sumaWypadPodst = 0;
    decimal sumaZdrowPodst = 0;
    decimal sumaFPPodst = 0;
    decimal sumaFGSPPodst = 0;
    decimal sumaFEPPodst = 0;
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
    Dictionary<string, decimal> sumaGotowka = new Dictionary<string, decimal>();
    Dictionary<string, decimal> sumaROR = new Dictionary<string, decimal>();
    Dictionary<string, decimal> wyplata = new Dictionary<string, decimal>();
    
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
		        
	static readonly string prefix = "&nbsp;&nbsp;";
    
    private void Grid_BeforeRow(object sender, Soneta.Web.RowEventArgs args) {
        Wyplata wypłata = (Wyplata)args.Row;
    
        string ss = string.Format("<strong>{0}<br>{1}</strong>",
            wypłata.PracHistoria.Nazwisko,
            wypłata.PracHistoria.Imie);
    
		if (srpars.StanowiskoInfo)
			ss += "<br>" + GetStanowisko(wypłata.Pracownik[wypłata.ListaPlac.Okres.To]);

        bool kurs = wypłata.ListaPlac.Definicja.WalutaPlatnosci.Symbol != Currency.SystemSymbol;
        if (srpars.PracaInfo || srpars.ProcentPit || kurs || srpars.StawkaZaszeregowaniaInfo) {
			
			string c1 = "";
			string c2 = "";

            if (kurs) {
                c1 = "Kurs waluty:";
                c2 = wypłata.Kurs.ToString();
            }

            if (srpars.StawkaZaszeregowaniaInfo) {
                if (c1 != "" || c2 != "") {
                    c1 += "<br>";
                    c2 += "<br>";
                }
                
                Date dataStawki = Date.Empty;

                foreach (WypElement element in wypłata.Elementy)
                    if (element.RodzajZrodla == RodzajŹródłaWypłaty.Etat && element.Okres.To > dataStawki)
                        dataStawki = element.Okres.To;

                if (dataStawki != Date.Empty) {
                    Etat etat = wypłata.Pracownik[dataStawki].Etat;
                    if (etat.Zaszeregowanie.RodzajStawki == RodzajStawkiZaszeregowania.Godzinowa)
                        c1 += "Stawka godz.:";
                    else
                        c1 += " Stawka mies.:";

                    if (etat.Zaszeregowanie.Stawka.Symbol == Currency.SystemSymbol)
                        c2 += etat.Zaszeregowanie.Stawka.Value.ToString("n");
                    else
                        c2 += etat.Zaszeregowanie.Stawka;
                }
            }

            if (srpars.ProcentPit) {
                if (c1 != "" || c2 != "") {
                    c1 += "<br>";
                    c2 += "<br>";
                }
                
				Percent ppit = wypłata.Pracownik.PrógPodatkowy(new YearMonth(wypłata.Data));
				c1 += "Procent zal.podatku:";
				c2 += ppit.ToString();
			}
			
			if (srpars.PracaInfo) {
				string who = wypłata.Pracownik.Last.Plec==PłećOsoby.Kobieta ? "Przepracowała" : "Przepracował";
				Time czas = Time.Zero;
				Time noc = Time.Zero;
				Time n50 = Time.Zero;
				Time n100 = Time.Zero;
                int dni = 0;
                int ch = 0, chk = 0;
				int uw = 0, uwk = 0;
				int pn = 0, pnk = 0;
                Time chg = Time.Zero, uwg = Time.Zero, png = Time.Zero;
				
				foreach (WypElement element in wypłata.Elementy)
					switch (element.RodzajZrodla) {
						case RodzajŹródłaWypłaty.Etat:
							czas += element.Czas;
                            dni += element.Dni;
                            foreach (WypSkladnik skl in element.Skladniki) {
                                WypSkladnikPomniejszenie pomn = skl as WypSkladnikPomniejszenie;
                                if (pomn != null && pomn.Nieobecnosc != null)
                                    if (pomn.Nieobecnosc.Definicja.Typ == TypNieobecnosci.NieobecnośćZUS) {
                                        ch -= pomn.Dni;
                                        chk += pomn.Okres.Days;
                                        chg -= pomn.Czas;
                                    }
                                    else if (pomn.Nieobecnosc.Definicja.Przyczyna == PrzyczynaNieobecnosci.UrlopWypoczynkowy) {
                                        uw -= pomn.Dni;
                                        uwk += pomn.Okres.Days;
                                        uwg -= pomn.Czas;
                                    }
                                    else {
                                        pn -= pomn.Dni;
                                        pnk += pomn.Okres.Days;
                                        png -= pomn.Czas;
                                    }
                                else if (skl is WypSkladnikOdchyłka.AkordMinus) {
                                    czas -= skl.Czas;
                                    dni -= skl.Dni;
                                }
                            }
							break;						
						case RodzajŹródłaWypłaty.Nocne:
							noc += element.Czas;
							break;						
						case RodzajŹródłaWypłaty.NadgodzinyI:
							n50 += element.Czas;
							break;						
						case RodzajŹródłaWypłaty.NadgodzinyII:
						case RodzajŹródłaWypłaty.NadgodzinyŚw:
							n100 += element.Czas;
							break;
                        case RodzajŹródłaWypłaty.Odchyłki:
                            czas += element.Czas;
                            dni += element.Dni;
                            break;
					}

				if (c1!="" || c2!="") {
					c1 += "<br>";
					c2 += "<br>";
				}
				
				c1 += who + ":";
                c2 += "" + czas + "/" + dni;
				
				if (noc!=Time.Zero) {
					c1 += "<br>&nbsp;&nbsp;nocne:";
					c2 += "<br>" + noc;
				}
				
				if (n50!=Time.Zero) {
					c1 += "<br>&nbsp;&nbsp;nadgodziny 50%:";
					c2 += "<br>" + n50;
				}
				
				if (n100!=Time.Zero) {
					c1 += "<br>&nbsp;&nbsp;nadgodziny 100%:";
					c2 += "<br>" + n100;
				}

				if (chk!=0 || uwk!=0 || pnk!=0) 
					if (chk==0 && uwk==0) {
						c1 += "<br>Nieobecności:";
                        c2 += string.Format("<br>{0}/{1}", pn, pnk, png);
					}
					else {
						c1 += "<br>Nieobecności";
						c2 += "<br>";
						
						if (chk!=0) {
							c1 += "<br>&nbsp;&nbsp;zwol.lekarskie:";
                            c2 += string.Format("<br>{0}/{1}", ch, chk, chg);
						}
						if (uwk!=0) {
							c1 += "<br>&nbsp;&nbsp;url.wypoczynkowe:";
                            c2 += string.Format("<br>{0}/{1}", uw, uwk, uwg);
                        }
						if (pnk!=0) {
							c1 += "<br>&nbsp;&nbsp;pozostałe:";
                            c2 += string.Format("<br>{0}/{1}", pn, pnk, png);
                        }
					}
			}

            if (srpars.PlanInfo) {
                string who = "Norma";

                Time czas = Time.Zero;
                int dni = 0;
                foreach (WypElement element in wypłata.Elementy)
                    if (element.RodzajZrodla == RodzajŹródłaWypłaty.Etat)
                        foreach (WypSkladnik skl in element.Skladniki)
                            if (skl.Rodzaj == RodzajSkładnikaWypłaty.Główny) {
                                czas += skl.Czas;
                                dni += skl.Dni;
                            }

                if (c1 != "" || c2 != "") {
                    c1 += "<br>";
                    c2 += "<br>";
                }

                c1 += who + ":";
                c2 += "" + czas + "/" + dni;
            }
            
			ss += "<table width='100%'>";
            string[] col1 = c1.Split(new string[] { "<br>" }, StringSplitOptions.None);
            string[] col2 = c2.Split(new string[] { "<br>" }, StringSplitOptions.None);
            int maxl = System.Math.Max(col1.Length, col2.Length);
            for (int i = 0; i < maxl; i++)
                ss += string.Format("<tr><td><font size=1>{0}</font></td><td align='right'><font size=1>{1}</td></tr>",
                    i<col1.Length ? col1[i] : "",
                    i<col2.Length ? col2[i] : "");
			ss += "</table>";
        }
    
        colNazImie.EditValue = ss;
    
        colOkres.EditValue = wypłata.ListaPlac.Okres;

        decimal emerD = 0, rentD = 0, chorD = 0, wypadD = 0;
        decimal emerP = 0, rentP = 0, chorP = 0, wypadP = 0;
        decimal emerF = 0, rentF = 0, chorF = 0, wypadF = 0;
        decimal fis = 0, zdrowD = 0, zdrow = 0, zdrowOdlicz = 0, koszty = 0, ulga = 0;
        decimal sumaOpodat = 0, sumaNieOpodat = 0;
        decimal fpD = 0, fgspD = 0, fepD = 0;
        decimal fp = 0, fgsp = 0, fep = 0;
        decimal temp;

        Dictionary<DefinicjaElementu, KeyValuePair<decimal, decimal>> sumyWartości = new Dictionary<DefinicjaElementu, KeyValuePair<decimal, decimal>>();
        if (srpars.SumujElementyWgDefinicji)
            foreach (WypElement element in wypłata.ElementyWgKolejności)
                if (element.Wartosc != 0 || srpars.Zero) {
                    KeyValuePair<decimal, decimal> v;
                    sumyWartości.TryGetValue(element.Definicja, out v);
                    sumyWartości[element.Definicja] = new KeyValuePair<decimal, decimal>(v.Key + element.DoOpodatkowania, v.Value + element.NiePodlegaOpodatkowaniu);
                }
        
        foreach (WypElement element in wypłata.ElementyWgKolejności) {
			bool opodatkowany = element.Definicja.Deklaracje.Zaliczka.Typ!=TypZaliczkiPodatku.NieNaliczać;
            if (srpars.SumujElementyWgDefinicji) {
                KeyValuePair<decimal, decimal> v;
                if (sumyWartości.TryGetValue(element.Definicja, out v)) {
                    sumyWartości.Remove(element.Definicja);
                    colElementy.AddLine(element.Nazwa);

                    if (v.Key != 0)
                        colOpodat.AddLine("{0:n}", v.Key);
                    else
                        colOpodat.AddLine();

                    if (v.Value != 0)
                        colNieOpodat.AddLine("{0:n}", v.Value);
                    else
                        colNieOpodat.AddLine();
                }
            }
            else if (!srpars.SkladnikiInfo) {
                if (element.DoOpodatkowania != 0 || element.NiePodlegaOpodatkowaniu != 0 || srpars.Zero) {
                    if (srpars.ProcentInfo && element.SkładnikGłówny != null && element.SkładnikGłówny.Procent != 0) {
                        Percent v = element.SkładnikGłówny.Procent;
                        if (Soneta.Tools.Math.RoundCy((decimal)v) == (decimal)v)
                            colElementy.AddLine(element.Nazwa + ",&nbsp;" + (int)(100 * (decimal)v) + "%");
                        else
                            colElementy.AddLine(element.Nazwa + ",&nbsp;" + v);
                    }
                    else
                        colElementy.AddLine(element.Nazwa);
                    
                    if (element.DoOpodatkowania != 0)
                        colOpodat.AddLine("{0:n}", element.DoOpodatkowania);
                    else
                        colOpodat.AddLine();

                    if (element.NiePodlegaOpodatkowaniu != 0)
                        colNieOpodat.AddLine("{0:n}", element.NiePodlegaOpodatkowaniu);
                    else
                        colNieOpodat.AddLine();

                    if (srpars.NieobecnościInfo && element is WypElementNieobecność) {
                        colElementy.AddLine(prefix + "(" + element.Okres + ")");
                        colOpodat.AddLine();
                        colNieOpodat.AddLine();
                    }
                }
            }
            else
                foreach (WypSkladnik sk in element.Skladniki) {
                    WypSkladnikGłówny skg = sk as WypSkladnikGłówny;
                    bool addempty = false;
                    if (skg != null) {
                        if (srpars.ProcentInfo && skg.Procent != 0) {
                            Percent v = skg.Procent;
                            if (Soneta.Tools.Math.RoundCy((decimal)v) == (decimal)v)
                                colElementy.AddLine(element.Nazwa + ",&nbsp;" + (int)(100 * (decimal)v) + "%");
                            else
                                colElementy.AddLine(element.Nazwa + ",&nbsp;" + v);
                        }
                        else
                            colElementy.AddLine(element.Nazwa);

                        if (srpars.NieobecnościInfo && element is WypElementNieobecność) {
                            colElementy.AddLine(prefix + "(" + element.Okres + ")");
                            addempty = true;
                        }
                    }
                    else {
                        WypSkladnikPomniejszenie skp = sk as WypSkladnikPomniejszenie;
                        if (skp != null) {
                            colElementy.AddLine(prefix + skp.Nieobecnosc.Definicja.Nazwa);
                            colElementy.AddLine(prefix + prefix + "(" + skp.Okres + ")");
                            addempty = true;
                        }
                        else
                            colElementy.AddLine(prefix + CaptionAttribute.EnumToString(sk.Rodzaj));
                    }

                    decimal opodat = 0;
                    decimal nieopodat = 0;
                    if (sk.Wartosc == element.Wartosc) {
                        opodat = element.DoOpodatkowania;
                        nieopodat = element.NiePodlegaOpodatkowaniu;
                    }
                    else if (opodatkowany)
                        opodat = sk.Wartosc;
                    else
                        nieopodat = sk.Wartosc;
                        
                    if (opodat != 0)
                        colOpodat.AddLine("{0:n}", opodat);
                    else
                        colOpodat.AddLine();
                    
                    if (nieopodat != 0)
                        colNieOpodat.AddLine("{0:n}", nieopodat);
                    else
                        colNieOpodat.AddLine();

                    if (addempty) {
                        colNieOpodat.AddLine();
                        colOpodat.AddLine();
                    }
                }

            brutto += element.DoOpodatkowania;
            sumaOpodat += element.DoOpodatkowania;
            sumaNieOpodat += element.NiePodlegaOpodatkowaniu;

            emerD += element.Podatki.Emerytalna.Podstawa;
            rentD += element.Podatki.Rentowa.Podstawa;
            chorD += element.Podatki.Chorobowa.Podstawa;
            wypadD += element.Podatki.Wypadkowa.Podstawa;
            
            emerP += element.Podatki.Emerytalna.Prac;
            rentP += element.Podatki.Rentowa.Prac;
            chorP += element.Podatki.Chorobowa.Prac;
            wypadP += element.Podatki.Wypadkowa.Prac;
    
            emerF += element.Podatki.Emerytalna.Firma;
            rentF += element.Podatki.Rentowa.Firma;
            chorF += element.Podatki.Chorobowa.Firma;
            wypadF += element.Podatki.Wypadkowa.Firma;
    
            fis += element.Podatki.ZalFIS;
            zdrowD += element.Podatki.Zdrowotna.Podstawa;
            zdrow += element.Podatki.Zdrowotna.Prac;
            zdrowOdlicz += element.Podatki.ZdrowotneDoOdliczenia;
            koszty += element.Podatki.KosztyPIT;
            ulga += element.Podatki.Ulga;

            fpD += element.Podatki.FP.Podstawa;
            fgspD += element.Podatki.FGSP.Podstawa;
            fepD += element.Podatki.FEP.Podstawa;
            
            fp += element.Podatki.FP.Skladka;
            fgsp += element.Podatki.FGSP.Skladka;
            fep += element.Podatki.FEP.Skladka;
    
            Elem elem = (Elem)elements[element.Definicja];
            if (elem==null) {
                elem = new Elem(element.Definicja);
                elements[element.Definicja] = elem;
            }
            elem.Add(element.Wartosc);

            sumaEmerPodst += element.Podatki.Emerytalna.Podstawa;
            sumaRentPodst += element.Podatki.Rentowa.Podstawa;
            sumaChorPodst += element.Podatki.Chorobowa.Podstawa;
            sumaWypadPodst += element.Podatki.Wypadkowa.Podstawa;
            sumaZdrowPodst += element.Podatki.Zdrowotna.Podstawa;
            
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

            sumaFPPodst += element.Podatki.FP.Podstawa;
            sumaFGSPPodst += element.Podatki.FGSP.Podstawa;
            sumaFEPPodst += element.Podatki.FEP.Podstawa;
                
            sumaFP += element.Podatki.FP.Skladka;
            sumaFGSP += element.Podatki.FGSP.Skladka;
            sumaFEP += element.Podatki.FEP.Skladka;

            sumaZaliczka += element.Podatki.ZalFIS;
            sumaKoszty += element.Podatki.KosztyPIT;
            sumaUlga += element.Podatki.Ulga;
        }
        
        colNieOpodatSum.EditValue = sumaNieOpodat;
        colOpodatSum.EditValue = sumaOpodat;

        colPodstSkl.AddLine("{0:n} E", emerD);
        colPodstSkl.AddLine("{0:n} R", rentD);
        colPodstSkl.AddLine("{0:n} C", chorD);
        colPodstSkl.AddLine("{0:n} W", wypadD);
        colPodstSkl.AddLine("{0:n} Z", zdrowD);
        if (srpars.Fundusze) {
            colPodstSkl.AddLine("{0:n} F", fpD);
            colPodstSkl.AddLine("{0:n} G", fgspD);
            colPodstSkl.AddLine("{0:n} P", fepD);
        }
        colPodstSklSum.EditValue = "";
            
        colZUS.AddLine("{0:n} E", emerP);
        colZUS.AddLine("{0:n} R", rentP);
        colZUS.AddLine("{0:n} C", chorP);
        if (wypadP != 0)
            colZUS.AddLine("{0:n} W", wypadP);
        colZUSSum.EditValue = emerP + rentP + chorP + wypadP;
    
        colZUSFirmy.AddLine("{0:n} E", emerF);
        colZUSFirmy.AddLine("{0:n} R", rentF);
        if (chorF != 0)
            colZUSFirmy.AddLine("{0:n} C", chorF);
        colZUSFirmy.AddLine("{0:n} W", wypadF);
        if (srpars.Fundusze) {
            colZUSFirmy.AddLine("{0:n} F", fp);
            colZUSFirmy.AddLine("{0:n} G", fgsp);
            colZUSFirmy.AddLine("{0:n} P", fep);
        }
        colZUSFirmySum.EditValue = emerF + rentF + chorF + wypadF + (srpars.Fundusze ? fp + fgsp + fep: 0m);
    
        colPodatki.AddLine("{0:n} &nbsp;&nbsp;", fis);
        if (srpars.ZdrowotneInfo) {
            colPodatki.AddLine("{0:n} Z", zdrowOdlicz);
            colPodatki.AddLine("{0:n} z", zdrow - zdrowOdlicz);
        }
        else
            colPodatki.AddLine("{0:n} Z", zdrow);        
        colPodatki.AddLine("{0:n} K", koszty);
        colPodatki.AddLine("{0:n} U", ulga);
        colPodatkiSum.EditValue = fis+zdrow;

        Currency ror;
        if (srpars.ZestawieniePrzelewów) {
            ArrayList kwoty = new ArrayList();
            Currency zero = new Currency(0m, wypłata.WartoscCy.Symbol);
            ror = zero;
            foreach (Soneta.Kasa.Platnosc z in wypłata.Platnosci)
                if (z.SposobZaplaty.Typ != Soneta.Kasa.TypySposobowZaplaty.Gotówka) {
                    Currency x = z.Kierunek == Soneta.Core.KierunekPlatnosci.Rozchod ? z.Kwota : -z.Kwota;
                    ror += x;
                    kwoty.Add(x);
                }
            if (kwoty.Count == 0)
                kwoty.Add(zero);

            colPodpis.AddLine(wypłata.WartoscCy - ror);
            foreach (Currency k in kwoty)
                colPodpis.AddLine(k);
            
            if (srpars.Fundusze && chorF != 0 && kwoty.Count==1)
                colPodpis.AddLine("");
        }
        else {
            ror = wypłata.Inne;
            colPodpis.AddLine(wypłata.WartoscCy - ror);
            colPodpis.AddLine(ror);
            colPodpis.AddLine("");
            if (srpars.Fundusze && chorF != 0)
                colPodpis.AddLine("");
        }
        
        colPodpis.AddLine("<center>.........................<br>(podpis)</center>");

        Currency gotowka = wypłata.WartoscCy - ror;
        string symbol = wypłata.WartoscCy.Symbol;
        if (!sumaGotowka.TryGetValue(symbol, out temp))
            sumaGotowka.Add(symbol, gotowka.Value);
        else
            sumaGotowka[symbol] += gotowka.Value;

        if (!sumaROR.TryGetValue(ror.Symbol, out temp))
            sumaROR.Add(ror.Symbol, ror.Value);
        else
            sumaROR[ror.Symbol] += ror.Value;
        if (!wyplata.TryGetValue(symbol, out temp))
            wyplata.Add(symbol, wypłata.WartoscCy.Value);
        else
            wyplata[symbol] += wypłata.WartoscCy.Value;
    }

    string GetStanowisko(PracHistoria ph) {
        string stanowiskoPelne = "";
        if (srpars.PelneStanowisko)
            stanowiskoPelne = ph.Etat.StanowiskoPełne;
        if (stanowiskoPelne.Length == 0)
            stanowiskoPelne = ph.Etat.Stanowisko;
        return stanowiskoPelne;
    }
        
    private void Grid_AfterRender(object sender, System.EventArgs e) {
        string strBrutto = string.Format("{0:n} {1}, słownie: {2:t}", brutto, brutto.Symbol, brutto); 
        cellBrutto.Format1 = strBrutto != "" ? strBrutto : "0";
        cellBrutto.Format2 = "";

        string strNetto = "";
        foreach (string key in wyplata.Keys)
            strNetto += (strNetto != "" ? "<br/>" : "") +
                string.Format("{0:n} {1}, słownie: {2:t}", wyplata[key], key, new Currency(wyplata[key], key)); 
        cellNetto.Format1 = strNetto != "" ? strNetto : "0";
        cellNetto.Format2 = "";

        labelEmerPodst.EditValue = sumaEmerPodst;
        labelRentPodst.EditValue = sumaRentPodst;
        labelChorPodst.EditValue = sumaChorPodst;
        labelWypadPodst.EditValue = sumaWypadPodst;
        labelZdrowPodst.EditValue = sumaZdrowPodst;
                
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

        labelFPPodst.EditValue = sumaFPPodst;
        labelFGSPPodst.EditValue = sumaFGSPPodst;
        labelFEPPodst.EditValue = sumaFEPPodst;
                
        labelFP.EditValue = sumaFP;
        labelFGSP.EditValue = sumaFGSP;
        labelFEP.EditValue = sumaFEP;
        
        labelZaliczka.EditValue = sumaZaliczka;
        labelKoszty.EditValue = sumaKoszty;
        labelUlga.EditValue = sumaUlga;

        string strGotowka = "";
        foreach (string key in sumaGotowka.Keys)
            strGotowka += (strGotowka != "" ? "<br/>" : "") + sumaGotowka[key] + " " + key;
        labelGotowka.EditValue = strGotowka != "" ? strGotowka : "0";

        string strROR = "";
        foreach (string key in sumaROR.Keys)
            strROR += (strROR != "" ? "<br/>" : "") + sumaROR[key] + " " + key;
        labelROR.EditValue = strROR != "" ? strROR : "0";

        string strRazem = "";
        foreach (string key in wyplata.Keys)
            strRazem += (strRazem != "" ? "<br/>" : "") + wyplata[key] + " " + key;
        labelRazem.EditValue = strRazem != "" ? strRazem : "0";
        
        labelPrac.EditValue = sumaEmerPrac + sumaRentPrac + sumaChorPrac + sumaWypadPrac;
        labelFirma.EditValue = sumaEmerFirma + sumaRentFirma + sumaChorFirma + sumaWypadFirma + sumaFP + sumaFGSP+sumaFEP;
    
        ArrayList arr = new ArrayList(elements.Values);
        arr.Sort();
        Grid2.DataSource = arr;
        Grid2.RowTypeName = typeof(Elem).AssemblyQualifiedName;
    }

    bool sumy = false;
    
    [Context(Required=true)]
    public Params Parametry {
        set {
            sumy = value.Sumy;
            
            if (value.Paski)
                Grid.ShowHeader = ShowHeader.EveryRow;
    
            if (!value.Sumy) {
                colOkres.Visible = false;
                colElementySum.Visible = false;
                colOpodatSum.Visible = false;
                colNieOpodatSum.Visible = false;
                colPodstSklSum.Visible = false;
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

        if (srpars.ZestawieniePrzelewów)
            colPodpis.Caption += "(y)";

        dc.Landscape = colPodstSkl.Visible = srpars.Skladki;
        colPodstSklSum.Visible = srpars.Skladki && sumy;
        skl1.Visible = skl2.Visible = skl3.Visible = skl4.Visible = skl5.Visible = skl6.Visible =
            skl7.Visible = skl8.Visible = skl9.Visible = skl10.Visible = srpars.Skladki;
    }
    
    static void Msg(object value) {
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
				<ea:datacontext id="dc" runat="server" OnContextLoad="dc_ContextLoad" TypeName="Soneta.Place.ListaPlac, Soneta.KadryPlace"
					LeftMargin="-1" RightMargin="-1"></ea:datacontext>
                <cc1:reportheader NagłówekOddziału="NagłówekOddziału" id="ReportHeader1" title="Lista płac {0}|%NAZWA%%BUFOR%</strong>Wydział:<strong> {1}|</strong>Za okres:<strong> {2}|</strong>Data wypłaty:<strong> {3}"
					runat="server" DataMember3="DataWyplaty" DataMember0="Numer" DataMember1="Wydzial" DataMember2="Okres"></cc1:reportheader>
                <ea:Section runat="server" ID="section1"></ea:Section>
                <ea:Section runat="server" ID="section2" SectionType="Body">
                <ea:grid id="Grid" runat="server" DataMember="Wyplaty" RowTypeName="Soneta.Place.WyplataEtat, Soneta.KadryPlace"
					RowsInRow="2" onbeforerow="Grid_BeforeRow" onafterrender="Grid_AfterRender">
					<Columns>
						<ea:GridColumn Width="4" BottomBorder="Single" Align="Right" DataMember="Numer.Numer" Caption="Lp"
							ID="colLP"></ea:GridColumn>
						<ea:GridColumn ColSpan="2" Format="Za: {0}" ID="colOkres" NoWrap="True"></ea:GridColumn>

						<ea:GridColumn Width="26" BottomBorder="Single" Caption="Nazwisko i imię" ID="colNazImie" VAlign="Middle"></ea:GridColumn>
						<ea:GridColumn Width="26" BottomBorder="Single" Caption="Elementy płacy" ID="colElementy" NoWrap="True"
							VAlign="Top"></ea:GridColumn>

						<ea:GridColumn Align="Center" Format="Suma:" ID="colElementySum"></ea:GridColumn>
						<ea:GridColumn BottomBorder="Single" Align="Right" Caption="Elementy~opodatkowane" ID="colOpodat"
							VAlign="Top"></ea:GridColumn>

						<ea:GridColumn Align="Right" Format="{0:n}" ID="colOpodatSum"></ea:GridColumn>
						<ea:GridColumn BottomBorder="Single" Align="Right" Caption="Elementy~nieopodatk." ID="colNieOpodat"
							VAlign="Top"></ea:GridColumn>

						<ea:GridColumn Align="Right" Format="{0:n}" ID="colNieOpodatSum"></ea:GridColumn>
						<ea:GridColumn Width="18" BottomBorder="Single" Align="Right" Caption="Podstawa składek" ID="colPodstSkl"
                            VAlign="Top"></ea:GridColumn>
						                        
						<ea:GridColumn Align="Right" Format="{0:n}" ID="colPodstSklSum"></ea:GridColumn>
                        <ea:GridColumn BottomBorder="Single" Align="Right" Caption="Składki ZUS~pracownika" ID="colZUS"
							VAlign="Top"></ea:GridColumn>

						<ea:GridColumn Align="Right" Format="{0:n}" ID="colZUSSum"></ea:GridColumn>
						<ea:GridColumn BottomBorder="Single" Align="Right" Caption="Składki ZUS~pracodawcy" ID="colZUSFirmy"
							VAlign="Top"></ea:GridColumn>

						<ea:GridColumn Align="Right" Format="{0:n}" ID="colZUSFirmySum"></ea:GridColumn>
						<ea:GridColumn BottomBorder="Single" Align="Right" Caption="Zal.US/Zdrow.|Koszty/Ulga" ID="colPodatki"
							VAlign="Top"></ea:GridColumn>

						<ea:GridColumn Align="Right" Format="{0:n} N" ID="colPodatkiSum"></ea:GridColumn>
						<ea:GridColumn Align="Right" Caption="Got&#243;wka|ROR" ID="colPodpis" RowSpan="2" VAlign="Top"></ea:GridColumn>
					</Columns>
				</ea:grid><ea:sectionmarker id="SectionMarker2" runat="server"></ea:sectionmarker><font face="Tahoma" size="2"><STRONG>Podsumowanie:</STRONG></font>
				<table id="Table4" style="FONT-SIZE: 8pt; FONT-FAMILY: Tahoma; BORDER-COLLAPSE: collapse"
					borderColor="silver" width="70%" border="1">
					<tbody>
						<tr>
							<td align="center" width="20%">Składka</td>
                            <ea:Section ID="skl1" runat="server">
							    <td align="center" width="16%">Podstawa składek</td>
                            </ea:Section>
							<td align="center" width="16%">Składki pracownika</td>
							<td align="center" width="16%">Składki pracodawcy</td>
							<td align="center" width="16%"></td>
							<td align="center" width="16%"></td>
						</tr>
						<tr>
							<td>Emerytalna:</td>
                            <ea:Section ID="skl2" runat="server">
    							<td align="right"><ea:datalabel id="labelEmerPodst" runat="server" Format="{0:n}"></ea:datalabel></td>
                            </ea:Section>
							<td align="right"><ea:datalabel id="labelEmerPrac" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td align="right"><ea:datalabel id="labelEmerFirma" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td>Zaliczka podatku:</td>
							<td align="right"><ea:datalabel id="labelZaliczka" runat="server" Format="{0:n}"></ea:datalabel></td>
						</tr>
						<tr>
							<td>Rentowa:</td>
                            <ea:Section ID="skl3" runat="server">
    							<td align="right"><ea:datalabel id="labelRentPodst" runat="server" Format="{0:n}"></ea:datalabel></td>
                            </ea:Section>
							<td align="right"><ea:datalabel id="labelRentPrac" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td align="right"><ea:datalabel id="labelRentFirma" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td>Koszty uzyskania:</td>
							<td align="right"><ea:datalabel id="labelKoszty" runat="server" Format="{0:n}"></ea:datalabel></td>
						</tr>
						<tr>
							<td>Chorobowa:</td>
                            <ea:Section ID="skl4" runat="server">
    							<td align="right"><ea:datalabel id="labelChorPodst" runat="server" Format="{0:n}"></ea:datalabel></td>
                            </ea:Section>
							<td align="right"><ea:datalabel id="labelChorPrac" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td align="right"><ea:datalabel id="labelChorFirma" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td>Ulga podatkowa:</td>
							<td align="right"><ea:datalabel id="labelUlga" runat="server" Format="{0:n}"></ea:datalabel></td>
						</tr>
						<tr>
							<td>Wypadkowa:</td>
                            <ea:Section ID="skl5" runat="server">
    							<td align="right"><ea:datalabel id="labelWypadPodst" runat="server" Format="{0:n}"></ea:datalabel></td>
                            </ea:Section>
							<td align="right"><ea:datalabel id="labelWypadPrac" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td align="right"><ea:datalabel id="labelWypadFirma" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td><strong>Gotówka:</strong></td>
							<td align="right"><ea:datalabel id="labelGotowka" runat="server"></ea:datalabel></td>
						</tr>
						<tr>
							<td>FP:</td>
                            <ea:Section ID="skl6" runat="server">
    							<td align="right"><ea:datalabel id="labelFPPodst" runat="server" Format="{0:n}"></ea:datalabel></td>
                            </ea:Section>
							<td></td>
							<td align="right"><ea:datalabel id="labelFP" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td><strong>ROR:</strong></td>
							<td align="right"><ea:datalabel id="labelROR" runat="server"></ea:datalabel></td>
						</tr>
						<tr>
							<td>FGŚP:</td>
                            <ea:Section ID="skl7" runat="server">
    							<td align="right"><ea:datalabel id="labelFGSPPodst" runat="server" Format="{0:n}"></ea:datalabel></td>
                            </ea:Section>
							<td></td>
							<td align="right"><ea:datalabel id="labelFGSP" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td><STRONG>Razem:</STRONG></td>
							<td align="right"><ea:datalabel id="labelRazem" runat="server"></ea:datalabel></td>
						</tr>
						<tr>
							<td>FEP:</td>
                            <ea:Section ID="skl8" runat="server">
    							<td align="right"><ea:datalabel id="labelFEPPodst" runat="server" Format="{0:n}"></ea:datalabel></td>
                            </ea:Section>
							<td align="right">&nbsp;</td>
							<td align="right"><font face="Tahoma"><ea:datalabel id="labelFEP" runat="server" Format="{0:n}"></ea:datalabel></font></td>
							<td></td>
							<td></td>
						</tr>
						<tr>
							<td><strong>Razem składki:</strong></td>
                            <ea:Section ID="skl9" runat="server">
    							<td></td>
                            </ea:Section>
							<td align="right"><ea:datalabel id="labelPrac" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td align="right"><ea:datalabel id="labelFirma" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td></td>
							<td></td>
						</tr>
						<tr>
							<td>Zdrowotna:</td>
                            <ea:Section ID="skl10" runat="server">
    							<td align="right"><ea:datalabel id="labelZdrowPodst" runat="server" Format="{0:n}"></ea:datalabel></td>
                            </ea:Section>
							<td align="right"><ea:datalabel id="labelZdrowPrac" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td align="right"><ea:datalabel id="labelZdrowFirma" runat="server" Format="{0:n}"></ea:datalabel></td>
							<td></td>
							<td></td>
						</tr>
					</tbody>
				</table>
				<ea:sectionmarker id="SectionMarker1" runat="server"></ea:sectionmarker><font face="Tahoma" size="2"><STRONG>Zestawienie 
						elementów:</STRONG></font>
				<br>
				<ea:grid id="Grid2" runat="server">
                    <Columns>
                    <ea:GridColumn runat="server" DataMember="#" Width="4" Caption="Lp" ID="col2LP" Align="Right"></ea:GridColumn>
                    <ea:GridColumn runat="server" DataMember="Name" Width="30" Caption="Nazwa" ID="col2Name" Total="Info"></ea:GridColumn>
                    <ea:GridColumn runat="server" HideZero="True" DataMember="Counter" Width="10" Caption="Liczba" ID="col2Counter" Total="Sum" Align="Right"></ea:GridColumn>
                    <ea:GridColumn runat="server" HideZero="True" DataMember="Dodatki" Width="12" Format="{0:n}" ID="col2Dodatki" Total="Sum" Align="Right"></ea:GridColumn>
                    <ea:GridColumn runat="server" HideZero="True" DataMember="Potrącenia" Width="12" Format="{0:n}" ID="col2Potr" Total="Sum" Align="Right"></ea:GridColumn>
                    <ea:GridColumn runat="server" HideZero="True" DataMember="Razem" Width="12" Format="{0:n}" ID="col2Razem" Total="Sum" Align="Right"></ea:GridColumn>
                    </Columns>
                </ea:grid>
                </ea:Section>                
				<cc1:reportfooter id="ReportFooter1" runat="server">
					<Cells>
						<cc1:FooterCell Caption="Opodatkowane (brutto):" ID="cellBrutto"></cc1:FooterCell>
						<cc1:FooterCell Caption="Do wypłaty (netto):" ID="cellNetto"></cc1:FooterCell>
					</Cells>
					<Subtitles>
						<cc1:FooterSubtitle Caption="Sprawdzono pod względem merytorycznym" SubtitleType="DataPodpis" Width="50"></cc1:FooterSubtitle>
						<cc1:FooterSubtitle Caption="Sprawdzono pod względem formalno prawnym" SubtitleType="DataPodpis" Width="50"></cc1:FooterSubtitle>
						<cc1:FooterSubtitle ID="stOperator" SubtitleType="Operator"></cc1:FooterSubtitle>
						<cc1:FooterSubtitle Caption="data"></cc1:FooterSubtitle>
						<cc1:FooterSubtitle Caption="gł&#243;wny księgowy"></cc1:FooterSubtitle>
						<cc1:FooterSubtitle Caption="kierownik jednostki"></cc1:FooterSubtitle>
					</Subtitles>
				</cc1:reportfooter></form>
		</font>
	</body>
</HTML>
