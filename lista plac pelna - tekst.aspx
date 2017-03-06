<%@ Page Language="c#" CodePage="1200" %>
<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %>
<%@ Register TagPrefix="cc1" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %>
<%@ import Namespace="Soneta.Place" %>
<%@ import Namespace="Soneta.Kadry" %>
<%@ import Namespace="Soneta.Kalend" %>
<%@ import Namespace="Soneta.Types" %>
<%@ import Namespace="Soneta.Tools" %>
<%@ import Namespace="Soneta.Business" %>
<%@ import Namespace="System.Collections.Generic" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<HTML>
	<HEAD>
		<title></title>
		<script runat="server">

    static bool fundusze = false;
    static bool hideOperator = false;
    static bool procentInfo = false;
    static bool skladnikiInfo = false;
    static bool nieobecnościInfo = false;
    static bool nazwaWNaglowku = false;
    static bool zdrowotneInfo = false;		    
    
    static bool procentPit = false;
    static bool pracaInfo = false;
    static bool stawkaZaszeregowaniaInfo = false;    

    static bool zestawieniePrzelewów = false;

    //Jeżeli flaga jest ustawiona na TAK to flagi procentInfo oraz nieobecnościInfo są ignorowane
            static bool sumujElementyWgDefinicji = false;           
		    
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

        //static bool stanowiskoInfo = false;
        bool stanowiskoInfo = false;
        [Priority(1)]
        [Caption("Stanowiska")]
        public bool StanowiskoInfo {
            get { return stanowiskoInfo; }
            set {
                stanowiskoInfo = value;
                OnChanged(EventArgs.Empty);
            }
        }
        
        bool pelneStanowisko = false;
        [Priority(2)]
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
    
	static readonly string prefix = "  ";
    
    private void Grid_BeforeRow(object sender, Soneta.Web.RowEventArgs args) {
        Wyplata wypłata = (Wyplata)args.Row;
    
        string ss = string.Format("{0}|{1}",
            wypłata.PracHistoria.Nazwisko,
            wypłata.PracHistoria.Imie);

        if (srpars.StanowiskoInfo)
            ss += "|" + GetStanowisko(wypłata.Pracownik[wypłata.ListaPlac.Okres.To]);
        
        bool kurs = wypłata.ListaPlac.Definicja.WalutaPlatnosci.Symbol != Currency.SystemSymbol;
        if (kurs)
            ss += "|Kurs waluty:" + Right(wypłata.Kurs.ToString(), 13);

        if (stawkaZaszeregowaniaInfo) {
            Date dataStawki = Date.Empty;

            foreach (WypElement element in wypłata.Elementy)
                if (element.RodzajZrodla == RodzajŹródłaWypłaty.Etat && element.Okres.To > dataStawki)
                    dataStawki = element.Okres.To;

            if (dataStawki != Date.Empty) {
                Etat etat = wypłata.Pracownik[dataStawki].Etat;
                if (etat.Zaszeregowanie.RodzajStawki == RodzajStawkiZaszeregowania.Godzinowa)
                    ss += "|St.godz.:";
                else
                    ss += "|St.mies.:";

                if (etat.Zaszeregowanie.Stawka.Symbol == Currency.SystemSymbol)
                    ss += Right(etat.Zaszeregowanie.Stawka.Value.ToString("n"), 16);
                else
                    ss += Right(etat.Zaszeregowanie.Stawka, 16);
            }
        }
        
		if (procentPit) {
			Percent ppit = wypłata.Pracownik.PrógPodatkowy(new YearMonth(wypłata.Data));
			ss += "|Procent zal.podat.:" + Right(ppit, 6);
		}

		if (pracaInfo) {
			string who = wypłata.Pracownik.Last.Plec==PłećOsoby.Kobieta ? "Przepracowała:" : "Przepracował: ";
			Time czas = Time.Zero;
			Time noc = Time.Zero;
			Time n50 = Time.Zero;
			Time n100 = Time.Zero;
            int ch = 0, chk = 0;
            int uw = 0, uwk = 0;
            int pn = 0, pnk = 0;
			
			foreach (WypElement element in wypłata.Elementy)
				switch (element.RodzajZrodla) {
					case RodzajŹródłaWypłaty.Etat:
						czas += element.Czas;
						foreach (WypSkladnik skl in element.Skladniki) {
							WypSkladnikPomniejszenie pomn = skl as WypSkladnikPomniejszenie;
							if (pomn!=null && pomn.Nieobecnosc!=null)
                                if (pomn.Nieobecnosc.Definicja.Typ == TypNieobecnosci.NieobecnośćZUS) {
                                    ch -= pomn.Dni;
                                    chk += pomn.Okres.Days;
                                }
                                else if (pomn.Nieobecnosc.Definicja.Przyczyna == PrzyczynaNieobecnosci.UrlopWypoczynkowy) {
                                    uw -= pomn.Dni;
                                    uwk += pomn.Okres.Days;
                                }
                                else {
                                    pn -= pomn.Dni;
                                    pnk += pomn.Okres.Days;
                                }
                            else if (skl is WypSkladnikOdchyłka.AkordMinus)
                                czas -= skl.Czas;
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
				}
							
			ss += "|" + who + "     " + Right(czas, 6);
			
			if (noc!=Time.Zero)
				ss += "|  nocne:             " + Right(noc, 6);
			
			if (n50!=Time.Zero)
				ss += "|  nadgodziny 50%:    " + Right(n50, 6);
			
			if (n100!=Time.Zero)
				ss += "|  nadgodziny 100%:   " + Right(n100, 6);

			if (chk!=0 || uwk!=0 || pnk!=0) {
				ss += "|Nieobecności";
                if (chk != 0)
                    ss += "|  zwol.lekarskie:     " + Right(ch, 2) +"/" + Right(chk, 2);
                if (uwk != 0)
                    ss += "|  url.wypoczynkowe:   " + Right(uw, 2) +"/" + Right(uwk, 2);
                if (pnk != 0)
                    ss += "|  pozostałe:          " + Right(pn, 2) +"/" + Right(pnk, 2);
			}
		}

        colNazImie.EditValue = ss;
    
        colOkres.EditValue = wypłata.ListaPlac.Okres;
    
        decimal emerP = 0, rentP = 0, chorP = 0, wypadP = 0;
        decimal emerF = 0, rentF = 0, chorF = 0, wypadF = 0;
        decimal fis = 0, zdrow = 0, zdrowOdlicz = 0, koszty = 0, ulga = 0;
        decimal sumaOpodat = 0, sumaNieOpodat = 0;
        decimal fp = 0, fgsp = 0, fep=0;

        Dictionary<DefinicjaElementu, decimal> sumyWartości = new Dictionary<DefinicjaElementu, decimal>();
        if (sumujElementyWgDefinicji)
            foreach (WypElement element in wypłata.ElementyWgKolejności)
                if (element.Wartosc != 0) {
                    decimal wartość;
                    sumyWartości.TryGetValue(element.Definicja, out wartość);
                    sumyWartości[element.Definicja] = wartość + element.Wartosc;
                }
        
        foreach (WypElement element in wypłata.ElementyWgKolejności) {
			bool opodatkowany = element.Definicja.Deklaracje.Zaliczka.Typ!=TypZaliczkiPodatku.NieNaliczać;
            if (sumujElementyWgDefinicji) {
                decimal wartość;
                if (sumyWartości.TryGetValue(element.Definicja, out wartość)) {
                    sumyWartości.Remove(element.Definicja);
                    colElementy.AddLine(element.Nazwa);
                    if (opodatkowany) {
                        brutto += wartość;
                        colOpodat.AddLine("{0:n}", wartość);
                        colNieOpodat.AddLine("");
                        sumaOpodat += wartość;
                    }
                    else {
                        colNieOpodat.AddLine("{0:n}", wartość);
                        colOpodat.AddLine("");
                        sumaNieOpodat += wartość;
                    }
                }
            }
            else if (!skladnikiInfo) {
                if (element.Wartosc != 0) {
                    if (procentInfo && element.SkładnikGłówny != null && element.SkładnikGłówny.Procent != 0) {
                        Percent v = element.SkładnikGłówny.Procent;
                        if (Soneta.Tools.Math.RoundCy((decimal)v) == (decimal)v)
                            colElementy.AddLine(element.Nazwa + ", " + (int)(100 * (decimal)v) + "%");
                        else
                            colElementy.AddLine(element.Nazwa + ", " + v);
                    }
                    else
                        colElementy.AddLine(element.Nazwa);

                    if (opodatkowany) {
                        brutto += element.Wartosc;
                        colOpodat.AddLine("{0:n}", element.Wartosc);
                        colNieOpodat.AddLine("");
                        sumaOpodat += element.Wartosc;
                    }
                    else {
                        colNieOpodat.AddLine("{0:n}", element.Wartosc);
                        colOpodat.AddLine("");
                        sumaNieOpodat += element.Wartosc;
                    }

                    if (nieobecnościInfo && element is WypElementNieobecność) {
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
                        if (procentInfo && skg.Procent != 0) {
                            Percent v = skg.Procent;
                            if (Soneta.Tools.Math.RoundCy((decimal)v) == (decimal)v)
                                colElementy.AddLine(element.Nazwa + ", " + (int)(100 * (decimal)v) + "%");
                            else
                                colElementy.AddLine(element.Nazwa + ", " + v);
                        }
                        else
                            colElementy.AddLine(element.Nazwa);

                        if (nieobecnościInfo && element is WypElementNieobecność) {
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

                    if (opodatkowany) {
                        brutto += sk.Wartosc;
                        colOpodat.AddLine("{0:n}", sk.Wartosc);
                        colNieOpodat.AddLine("");
                        sumaOpodat += sk.Wartosc;
                    }
                    else {
                        colNieOpodat.AddLine("{0:n}", sk.Wartosc);
                        colOpodat.AddLine("");
                        sumaNieOpodat += sk.Wartosc;
                    }

                    if (addempty) {
                        colNieOpodat.AddLine("");
                        colOpodat.AddLine("");
                    }
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
            zdrowOdlicz += element.Podatki.ZdrowotneDoOdliczenia;
            koszty += element.Podatki.KosztyPIT;
            ulga += element.Podatki.Ulga;
    
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
        if (fundusze) {
            colZUSFirmy.AddLine("{0:n} F", fp);
            colZUSFirmy.AddLine("{0:n} G", fgsp);
            colZUSFirmy.AddLine("{0:n} P", fep);
        }
        colZUSFirmySum.EditValue = emerF + rentF + chorF + wypadF + (fundusze ? fp + fgsp + fep: 0m);
    
        colPodatki.AddLine("{0:n}   ", fis);
        if (zdrowotneInfo) {
            colPodatki.AddLine("{0:n} Z", zdrowOdlicz);
            colPodatki.AddLine("{0:n} z", zdrow - zdrowOdlicz);

        }
        else
            colPodatki.AddLine("{0:n} Z", zdrow);
        colPodatki.AddLine("{0:n} K", koszty);
        colPodatki.AddLine("{0:n} U", ulga);
        colPodatkiSum.EditValue = fis+zdrow;

        Currency ror;
        if (zestawieniePrzelewów) {
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

            if (fundusze && chorF != 0 && kwoty.Count == 1)
                colPodpis.AddLine("");
        }
        else {
            ror = wypłata.Inne;
            colPodpis.AddLine(wypłata.WartoscCy - ror);
            colPodpis.AddLine(ror);
            colPodpis.AddLine("");
            if (fundusze && chorF != 0)
                colPodpis.AddLine("");
        }
        
        colPodpis.AddLine("...........| (podpis)");
    
        sumaGotowka += wypłata.WartoscCy-ror;
        sumaROR += ror;
    
        wyplata += wypłata.WartoscCy;
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
        labelBrutto.EditValue = brutto;
        labelNetto.EditValue = wyplata;
        labelBrutto2.EditValue = brutto;
        labelNetto2.EditValue = wyplata;
    
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
        
        if (sumaGotowka.Symbol == Currency.SystemSymbol) {
            labelGotowka.EditValue = sumaGotowka.Value;
            labelROR.EditValue = sumaROR.Value;
            labelRazem.EditValue = sumaROR.Value + sumaGotowka.Value;
        }
        else {
            labelGotowka.Format = "";
            labelROR.Format = "";
            labelRazem.Format = "";
            labelGotowka.EditValue = sumaGotowka;
            labelROR.EditValue = sumaROR;
            labelRazem.EditValue = sumaROR + sumaGotowka;
        }
        
        labelPrac.EditValue = sumaEmerPrac + sumaRentPrac + sumaChorPrac + sumaWypadPrac;
        labelFirma.EditValue = sumaEmerFirma + sumaRentFirma + sumaChorFirma + sumaWypadFirma + sumaFP + sumaFGSP + sumaFEP;
    
        ArrayList arr = new ArrayList(elements.Values);
        arr.Sort();
        Grid2.DataSource = arr;
        Grid2.RowTypeName = typeof(Elem).AssemblyQualifiedName;
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
            dlBufor.EditValue = "\n&nbsp;&nbsp;&nbsp;&nbsp;<i><u>Lista nie została zatwierdzona!</u></i>";
            
        if (nazwaWNaglowku)
            dlNazwa.EditValue = "\n&nbsp;&nbsp;&nbsp;&nbsp;" + lista.Definicja.Nazwa;
          
        if (!hideOperator) {
			labelData.EditValue = "Data wydruku: " + dc.Session.Login.CurrentDate;
			labelOperator.EditValue = "Operator: " + dc.Session.Login.Operator.Name;
		}

        if (zestawieniePrzelewów)
            colPodpis.Caption += "(y)";

        wyplata = sumaGotowka = sumaROR = lista.Definicja.WalutaPlatnosci.Zero;                 
        
        labelCopyright.EditValue = dc.Copyright;
    }
    
    static void Msg(object value) {
    }
    
    static string Right(object value, int len) {
        string format = "{0," + len + "}";
		return string.Format(format, value);
    }

		</script>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<meta content="Microsoft Visual Studio 7.0" name="GENERATOR">
		<meta content="C#" name="CODE_LANGUAGE">
		<meta content="JavaScript" name="vs_defaultClientScript">
		<meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema">
	</HEAD>
	<body>
		<font face="Courier New" size="smaller">
			<form id="PełnaListaPłac" method="post" runat="server">
				<ea:datacontext id="dc" runat="server" OnContextLoad="dc_ContextLoad" TypeName="Soneta.Place.ListaPlac, Soneta.KadryPlace"></ea:datacontext>
				<small></small><u></u><b></b>
				<ea:Section id="Section3" runat="server" Width="100%">
				&nbsp;&nbsp;&nbsp;&nbsp; Lista płac:&nbsp;&nbsp;&nbsp; 
<ea:datalabel id="Datalabel1" runat="server" Format="<u>{0}</u>" DataMember="Numer"></ea:datalabel>
<ea:datalabel id="dlNazwa" runat="server"></ea:datalabel>
<ea:datalabel id="dlBufor" runat="server"></ea:datalabel><BR>&nbsp;&nbsp;&nbsp;&nbsp; 
Wydział:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
<ea:datalabel id="Datalabel2" runat="server" DataMember="Wydzial" EncodeHTML="True"></ea:datalabel><BR>&nbsp; 
&nbsp;&nbsp;&nbsp;Za okres:&nbsp;&nbsp;&nbsp;&nbsp; 
<ea:datalabel id="Datalabel3" runat="server" DataMember="Okres" EncodeHTML="True"></ea:datalabel><BR>&nbsp;&nbsp;&nbsp;&nbsp; 
Data wypłaty: 
<ea:datalabel id="Datalabel4" runat="server" DataMember="DataWyplaty" EncodeHTML="True"></ea:datalabel><BR><SMALL>
						+--------------------------------------------------------------------------------------------------------------------------------+</SMALL><BR>
<ea:datalabel id="DataLabel8" runat="server" DataMember="Session.Core.Config.Firma.Pieczątka.NazwaWieleLinii"
						EncodeHTML="True" LeftMargin="4"></ea:datalabel><BR>
<ea:datalabel id="DataLabel9" runat="server" DataMember="Session.Core.Config.Firma.AdresSiedziby.Linia1"
						EncodeHTML="True" LeftMargin="4"></ea:datalabel><BR>
<ea:datalabel id="DataLabel10" runat="server" DataMember="Session.Core.Config.Firma.AdresSiedziby.Linia2"
						EncodeHTML="True" LeftMargin="4"></ea:datalabel><BR>&nbsp;&nbsp;&nbsp;&nbsp;NIP: 
<ea:datalabel id="DataLabel11" runat="server" DataMember="Session.Core.Config.Firma.Pieczątka.NIP"></ea:datalabel><br>
				</ea:Section>
				<small>
					<ea:textgrid id="Grid" runat="server" DataMember="Wyplaty" RowTypeName="Soneta.Place.WyplataEtat, Soneta.KadryPlace"
						RowsInRow="2" onbeforerow="Grid_BeforeRow" onafterrender="Grid_AfterRender">
						<Columns>
							<ea:GridColumn Width="3" BottomBorder="Single" Align="Right" DataMember="Numer.Numer" Caption="Lp"
								ID="colLP" runat="server"></ea:GridColumn>
							<ea:GridColumn ColSpan="2" Format="Za: {0}" ID="colOkres" NoWrap="True" runat="server"></ea:GridColumn>
							<ea:GridColumn Width="26" BottomBorder="Single" Caption="Nazwisko i imię" ID="colNazImie" VAlign="Middle" runat="server"></ea:GridColumn>
							<ea:GridColumn Width="26" BottomBorder="Single" Caption="Elementy płacy" ID="colElementy" NoWrap="True"
								VAlign="Top" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Center" Format="Suma:" ID="colElementySum" runat="server"></ea:GridColumn>
							<ea:GridColumn BottomBorder="Single" Align="Right" Caption="Elementy|opodat." ID="colOpodat" VAlign="Top" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" Format="{0:n}" ID="colOpodatSum" runat="server"></ea:GridColumn>
							<ea:GridColumn BottomBorder="Single" Align="Right" Caption="Elementy|nieopodat." ID="colNieOpodat"
								VAlign="Top" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" Format="{0:n}" ID="colNieOpodatSum" runat="server"></ea:GridColumn>
							<ea:GridColumn BottomBorder="Single" Align="Right" Caption="Składki ZUS|pracownika" ID="colZUS"
								VAlign="Top" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" Format="{0:n}" ID="colZUSSum" runat="server"></ea:GridColumn>
							<ea:GridColumn BottomBorder="Single" Align="Right" Caption="Składki ZUS|pracodawcy" ID="colZUSFirmy"
								VAlign="Top" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" Format="{0:n}" ID="colZUSFirmySum" runat="server"></ea:GridColumn>
							<ea:GridColumn BottomBorder="Single" Align="Right" Caption="Zal.US/Zdrow.|Koszty/Ulga" ID="colPodatki"
								VAlign="Top" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" Format="{0:n} N" ID="colPodatkiSum" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" Caption="Got&#243;wka|ROR" ID="colPodpis" RowSpan="2" VAlign="Top" runat="server" Width="12"></ea:GridColumn>
						</Columns>
					</ea:textgrid><br>
				</small>
				<ea:Section id="Section1" runat="server" Width="100%" Pagination="True">
						Podsumowanie:<SMALL>
						<BR>
						+------------------+------------------+------------------+------------------+------------------+<BR>
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Składka&nbsp;&nbsp;&nbsp;&nbsp; |Składki 
						pracownika|Składki 
						pracodawcy|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|<BR>
						+------------------+------------------+------------------+------------------+------------------+<BR>
						|Emerytalna:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |
						<ea:datalabel id="labelEmerPrac" runat="server" Format="{0:n}" Align="Right" WidthChars="17"></ea:datalabel>|
						<ea:datalabel id="labelEmerFirma" runat="server" Format="{0:n}" Align="Right" WidthChars="17"></ea:datalabel>|Zaliczka 
						podatku: |
						<ea:datalabel id="labelZaliczka" runat="server" Format="{0:n}" Align="Right" WidthChars="17"></ea:datalabel>|<BR>
						+------------------+------------------+------------------+------------------+------------------+<BR>
						|Rentowa:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |
						<ea:datalabel id="labelRentPrac" runat="server" Format="{0:n}" Align="Right" WidthChars="17"></ea:datalabel>|
						<ea:datalabel id="labelRentFirma" runat="server" Format="{0:n}" Align="Right" WidthChars="17"></ea:datalabel>|Koszty 
						uzyskania: |
						<ea:datalabel id="labelKoszty" runat="server" Format="{0:n}" Align="Right" WidthChars="17"></ea:datalabel>|<BR>
						+------------------+------------------+------------------+------------------+------------------+<BR>
						|chorobowa:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |
						<ea:datalabel id="labelChorPrac" runat="server" Format="{0:n}" Align="Right" WidthChars="17"></ea:datalabel>|
						<ea:datalabel id="labelChorFirma" runat="server" Format="{0:n}" Align="Right" WidthChars="17"></ea:datalabel>|Ulga 
						podatkowa:&nbsp;&nbsp; |
						<ea:datalabel id="labelUlga" runat="server" Format="{0:n}" Align="Right" WidthChars="17"></ea:datalabel>|<BR>
						+------------------+------------------+------------------+------------------+------------------+<BR>
						|Wypadkowa:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |
						<ea:datalabel id="labelWypadPrac" runat="server" Format="{0:n}" Align="Right" WidthChars="17"></ea:datalabel>|
						<ea:datalabel id="labelWypadFirma" runat="server" Format="{0:n}" Align="Right" WidthChars="17"></ea:datalabel>|<U>GOTÓWKA:</U>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|
						<ea:datalabel id="labelGotowka" runat="server" Format="{0:n}" Align="Right" WidthChars="17"></ea:datalabel>|<BR>
						+------------------+------------------+------------------+------------------+------------------+<BR>
						|FP:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|
						<ea:datalabel id="labelFP" runat="server" Format="{0:n}" Align="Right" WidthChars="17"></ea:datalabel>|<U>ROR:</U>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|
						<ea:datalabel id="labelROR" runat="server" Format="{0:n}" Align="Right" WidthChars="17"></ea:datalabel>|<BR>
						+------------------+------------------+------------------+------------------+------------------+<BR>
						                                    |FGŚP:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| <ea:datalabel id="labelFGSP" runat="server" Format="{0:n}" Align="Right" WidthChars="17"></ea:datalabel>|<U>RAZEM:</U>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|<ea:datalabel id="labelRazem" runat="server" Format="{0:n}" Align="Right" WidthChars="17"></ea:datalabel>&nbsp;|<BR>
						+------------------+------------------+------------------+------------------+------------------+<BR>
                        |FEP:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        |&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        |
                                                                <ea:DataLabel ID="labelFEP" runat="server" Align="Right" Format="{0:n}" 
                                                                    WidthChars="17">
                                                                </ea:DataLabel>|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |<br>
                                                                    +------------------+------------------+------------------+------------------+------------------+<br>
                                                                    </br>
                                                                |<u>RAZEM SKŁADKI:</u>&nbsp;&nbsp;&nbsp; |
                                                                <ea:DataLabel ID="labelPrac" runat="server" Align="Right" Format="{0:n}" 
                                                                    WidthChars="17">
                                                                </ea:DataLabel>
                                                                |
                                                                <ea:DataLabel ID="labelFirma" runat="server" Align="Right" Format="{0:n}" 
                                                                    WidthChars="17">
                                                                </ea:DataLabel>
                                                                |&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |<br>
                                                                    +------------------+------------------+------------------+------------------+------------------+<br>
                                                                        |Zdrowotna:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |
                                                                        <ea:DataLabel ID="labelZdrowPrac" runat="server" Align="Right" Format="{0:n}" 
                                                                            WidthChars="17">
                                                                        </ea:DataLabel>
                                                                        |
                                                                        <ea:DataLabel ID="labelZdrowFirma" runat="server" Align="Right" 
                                                                            Format="{0:n}" WidthChars="17">
                                                                        </ea:DataLabel>
                                                                        |&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |<br>
                                                                            +------------------+------------------+------------------+------------------+------------------+<br>
                                                                <br></br>
                                                                <br>
                                                                <br></br>
                                                                <br>
                                                                <br></br>
                                                                <br>
                                                                <br></br>
                                                                <br></br>
                                                                <br></br>
                                                                <br></br>
                                                                <br></br>
                                                                </br>
                                                                </br>
                                                                </br>
                                                                </br>
                                                                </br>
                                                                    </br>
                                                                </br>
                                                            </br>
                        </SMALL><br><br>
					</ea:Section>
				<ea:Section id="Section2" runat="server" Width="100%" Pagination="True">
						Zestawienie elementów:<SMALL>
						<BR>
						<ea:textgrid id="Grid2" runat="server" Pagination="False">
							<Columns>
								<ea:GridColumn Width="4" Align="Right" DataMember="#" Caption="Lp" ID="col2LP"></ea:GridColumn>
								<ea:GridColumn Width="30" DataMember="Name" Total="Info" Caption="Nazwa" ID="col2Name"></ea:GridColumn>
								<ea:GridColumn Width="10" Align="Right" DataMember="Counter" Total="Sum" Caption="Liczba" ID="col2Counter"></ea:GridColumn>
								<ea:GridColumn Width="12" Align="Right" DataMember="Dodatki" Total="Sum" Format="{0:n}" ID="col2Dodatki"></ea:GridColumn>
								<ea:GridColumn Width="12" Align="Right" DataMember="Potrącenia" Total="Sum" Format="{0:n}" ID="col2Potr"></ea:GridColumn>
								<ea:GridColumn Width="12" Align="Right" DataMember="Razem" Total="Sum" Format="{0:n}" ID="col2Razem"></ea:GridColumn>
							</Columns>
						</ea:textgrid></SMALL><br>
					</ea:Section>
				<ea:Section id="Section4" runat="server" Width="100%">
				Zatwierdzono 
na kwotę:<BR>Opodatkowane (brutto):
<ea:datalabel id="labelBrutto" runat="server" Format="{0:u}" Align="Right" WidthChars="17"></ea:datalabel><BR>&nbsp;&nbsp;&nbsp;<SMALL>
						słownie:
						<ea:datalabel id="labelBrutto2" runat="server" Format="{0:t}" Align="Right"></ea:datalabel></SMALL><BR>
                    Do wypłaty (netto): &nbsp;
<ea:datalabel id="labelNetto" runat="server" Format="{0:u}" Align="Right" WidthChars="17"></ea:datalabel><BR>&nbsp;&nbsp;&nbsp;<SMALL>
						słownie:
						<ea:datalabel id="labelNetto2" runat="server" Format="{0:t}" Align="Right"></ea:datalabel></SMALL><SMALL><BR>
						<BR>
						+--------------------------------------------------------------------------------------------------------------------------------+<BR>
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Sprawdzono pod względem 
						merytorycznym&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						Sprawdzono pod względem formalno 
						prawnym&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|<BR>
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|<BR>
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;...............&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						...............&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;...............&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						...............&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|<BR>
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						data&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;podpis&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						data&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;podpis&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|<BR>
						+--------------------------------------------------------------------------------------------------------------------------------+<BR>
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|<BR>
						|
						<ea:datalabel id="labelData" runat="server" Format="{0:n}" Align="Left" WidthChars="31"></ea:datalabel>|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|<BR>
						|
						<ea:datalabel id="labelOperator" runat="server" Format="{0:n}" Align="Left" WidthChars="31"></ea:datalabel>|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						...............&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						...............&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						...............&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |<BR>
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;data&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;główny 
						księgowy&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;kierownik 
						jednostki&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |<BR>
						+--------------------------------------------------------------------------------------------------------------------------------+</SMALL><BR><SMALL>
						<ea:datalabel id="labelCopyright" runat="server" Align="Right" WidthChars="130" Bold="False"></ea:datalabel></SMALL>
				</ea:Section>
				<ea:PageBreak id="PageBreak1" runat="server"></ea:PageBreak>
			</form>
		</font>
	</body>
</HTML>
