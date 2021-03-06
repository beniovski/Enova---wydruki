<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ import Namespace="Soneta.Business" %>
<%@ import Namespace="Soneta.Types" %>
<%@ import Namespace="Soneta.Kadry" %>
<%@ import Namespace="Soneta.Place" %>
<%@ import Namespace="Soneta.Kalend" %>
<%@ import Namespace="Soneta.Tools" %>
<%@ import Namespace="Soneta.Core" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ Register TagPrefix="n0" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %><%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %><%@ Page Language="c#" CodePage="1200" %><HTML><HEAD><TITLE>Paski wypłat</TITLE>
<STYLE type=text/css>
        </STYLE>

<SCRIPT runat="server">
    
	//Umożliwia drukowanie pasków o stałej wysokości (w milimetrach)
	//Wartość 1 oznacza drukowanie klasyczne
	//120 to dwa paski na stronę. Można tą watość zmieniać, tak, aby drugi pasek
	//driukował się na dolnej połowie strony, zależy to od ustawień drukarki.
	const int wysokośćPaska = 0;	//milimetrów

    // static string divheighttag = "<DIV style=\"WIDTH: 100%; HEIGHT: "+wysokośćPaska+"mm\">";
    static string divheighttag = wysokośćPaska == 0 ? "": "<DIV style=\"WIDTH: 100%; HEIGHT: " + wysokośćPaska + "mm\">";
    static string divendtag = wysokośćPaska == 0 ? "" : "</DIV>";
	
	[DefaultWidth(20)]
    public enum ZakresDanych {
		Wszystkie, TylkoGotówką
    }

    public enum PageFormat {
        [Caption("Razem")]
        Razem,
        [Caption("Każdy na osobnej stronie")]
        Osobno,
        [Caption("Nowy wydział od nowej strony")]
        Opcja
    }
    
    public class Params: ContextBase {
		public Params(Context context): base(context) {
		}
		
		ZakresDanych zakres = ZakresDanych.Wszystkie;
		[Caption("Drukuj wypłaty")]
		[Priority(1)]
        [DefaultWidth(22)]
        public ZakresDanych Zakres {
			get { return zakres; }
			set { 
				zakres = value; 
				OnChanged(EventArgs.Empty);
			}
		}

        PageFormat forceBreak = PageFormat.Razem;
		[Caption("Paski wypłat")]
		[Priority(2)]
        [DefaultWidth(22)]
        public PageFormat ForceBreak {
			get { return forceBreak; }
			set { 
				forceBreak = value; 
				OnChanged(EventArgs.Empty);
			}
		}

        bool sumujWyplaty = false;
        [Caption("Sumuj wypłaty")]
        [Priority(3)]
        public bool SumujWyplaty {
            get { return sumujWyplaty; }
            set {
                sumujWyplaty = value;
                OnChanged(EventArgs.Empty);
            }
        }

        public bool IsReadOnlySumujWyplaty() {
            return sumujWyplatyWgMiesiac;
        }
                
        bool sumujWyplatyWgMiesiac = false;
        [Caption("Sumuj wg miesiąca")]
        [Priority(4)]
        public bool SumujWyplatyWgMiesiac {
            get { return sumujWyplatyWgMiesiac; }
            set {
                sumujWyplatyWgMiesiac = value;
                OnChanged(EventArgs.Empty);
            }
        }

        public bool IsReadOnlySumujWyplatyWgMiesiac() {
            return sumujWyplaty;
        }
    }

    public class SrParams : SerializableContextBase {
        public SrParams(Context context) : base(context) {
        }

        //static bool procentInfo = false;
        bool procentInfo = false;
        [Priority(1)]
        [Caption("Kolumna %")]
        public bool ProcentInfo {
            get { return procentInfo; }
            set {
                procentInfo = value;
                OnChanged(EventArgs.Empty);
            }
        }
                
        //static bool skladnikiInfo = false;
        bool skladnikiInfo = false;
        [Priority(2)]
        [Caption("Szczegółowe dane")]
        public bool SkladnikiInfo {
            get { return skladnikiInfo; }
            set {
                skladnikiInfo = value;
                OnChanged(EventArgs.Empty);
            }
        }
                
        //static bool procentPit = false;
        bool procentPit = false;
        [Priority(3)]
        [Caption("Kolumna % PIT")]
        public bool ProcentPit {
            get { return procentPit; }
            set {
                procentPit = value;
                OnChanged(EventArgs.Empty);
            }
        }
                
        //Włącza drukowanie podsumowania funduszy pożyczkowych. UWAGA! Informacja wg stanu
        //aktualnego a nie na dzień wypłaty.
        //static bool funduszePożyczkowe = false;
        bool funduszePożyczkowe = false;
        [Priority(4)]
        [Caption("Fundusze pożyczkowe")]
        public bool FunduszePożyczkowe {
            get { return funduszePożyczkowe; }
            set {
                funduszePożyczkowe = value;
                OnChanged(EventArgs.Empty);
            }
        }
                
        //static bool daneFirmy = true;
        bool daneFirmy = true;
        [Priority(5)]
        [Caption("Dane firmy")]
        public bool DaneFirmy {
            get { return daneFirmy; }
            set {
                daneFirmy = value;
                OnChanged(EventArgs.Empty);
            }
        }
                
        //static bool fundusze = false;
        bool fundusze = true;
        [Priority(6)]
        [Caption("Fundusze")]
        public bool Fundusze {
            get { return fundusze; }
            set {
                fundusze = value;
                OnChanged(EventArgs.Empty);
            }
        }

        bool infoNorma = false;
        [Priority(7)]
        [Caption("Informacja o normie")]
        public bool InfoNorma {
            get { return infoNorma; }
            set {
                infoNorma = value;
                OnChanged(EventArgs.Empty);
            }
        }

        bool oswiadczenie = true;
        [Priority(8)]
        [Caption("Oświadczenie płatnika")]
        public bool Oswiadczenie {
            get { return oswiadczenie; }
            set {
                oswiadczenie = value;
                OnChanged(EventArgs.Empty);
            }
        }

        bool kolejnosc = true;
        [Priority(9)]
        [Caption("Kolejność wg def. elem.")]
        public bool Kolejnosc {
            get { return kolejnosc; }
            set {
                kolejnosc = value;
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

    SrParams srpars;
    [SettingsContext]
    public SrParams SrPars {
        get { return srpars; }
        set { srpars = value; }
    }

    class WdzComparer : IComparer {        
        public int Compare(object a, object b) {
            ListaPlac la = (ListaPlac)a;
            ListaPlac lb = (ListaPlac)b;
            int result = la.Wydzial.CompareTo(lb.Wydzial);
            if (result == 0)
                result = la.Numer.NumerPelny.CompareTo(lb.Numer.NumerPelny);
            return result;                
        }
    }
    
    void dc_OnContextLoad(Object sender, EventArgs args) {
        List<List<Wyplata>> wyplaty = new List<List<Wyplata>>();

        CoreModule coreNIP = CoreModule.GetInstance(dc);
        colNipTitle.Format = "NIP:&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp " + coreNIP.Config.Firma.Pieczątka.NIP;
        
		if (!srpars.ProcentPit)
			colPitInfo.Format = "";

        section2.Visible = srpars.Oswiadczenie;
                
        Row[] rows = (Row[])dc[typeof(Row[])];
        ArrayList al = new ArrayList();
        foreach (ListaPlac lista in rows)
            al.Add(lista);
        if (Pars.ForceBreak == PageFormat.Opcja)
            al.Sort(new WdzComparer());                
        
        foreach (ListaPlac lista in al)
            foreach (Wyplata wp in lista.Wyplaty) {
                if (pars.Zakres == ZakresDanych.TylkoGotówką && wp.Gotówka == Currency.Zero)
                    continue;
                if (!pars.SumujWyplaty && !pars.SumujWyplatyWgMiesiac) {
                    List<Wyplata> lw = new List<Wyplata>();
                    lw.Add(wp);
                    wyplaty.Add(lw);
                }
                else {
                    List<Wyplata> lw = null;
                    foreach (List<Wyplata> l in wyplaty) {
                        foreach (Wyplata w in l) {
                            bool warunek = pars.SumujWyplatyWgMiesiac ? w.ListaPlac.Okres == wp.ListaPlac.Okres : true;
                            if (w.
                                Guid == wp.Pracownik.Guid &&
                                warunek && w.GetType() == wp.GetType()) {
                                lw = l;
                                break;
                            }
                        }
                        if (lw != null)
                            break;
                    }
                    if (lw == null) {
                        lw = new List<Wyplata>();
                        wyplaty.Add(lw);
                    }
                    lw.Add(wp);
                }
            }
        repeater.DataSource = wyplaty;
		
        
		colProcent.Visible = srpars.ProcentInfo;
		
		if (srpars.DaneFirmy) {
			GridFirma.DataSource = new object [] { dc.Session };
			CoreModule core = CoreModule.GetInstance(dc);
			string ss = core.Config.Firma.Pieczątka.NUSP;
			if (ss == "") {
				colNuspTitle.Format = "REGON:";
				ss = core.Config.Firma.Pieczątka.REGON;
			}
			colNUSP.Format = ss;
		}
        else
			GridFirma.Visible = srpars.DaneFirmy;

        
        if (!srpars.Fundusze) {
            gridHeader.RowsInRow -= 3;

            optEmptyBegin.Visible = false;
            optPodstawa.Visible = false;
            optSkladka.Visible = false;

            optFP.Visible = false;
            optFPPodstawa.Visible = false;
            optFPSkladka.Visible = false;

            optFGSP.Visible = false;
            optFGSPPodstawa.Visible = false;
            optFGSPSkladka.Visible = false;

            optFEP.Visible = false;
            optFEPPodstawa.Visible = false;
            optFEPSkladka.Visible = false;

            optEmptyEnd.Visible = false;
        }
        // ZB: wyłączenie WithSection=false w przypadku drukowania każdego paska na oddzielnej stronie
        // Poprawka zastosowana ze względów wydajnościowych
        if (Pars.ForceBreak == PageFormat.Osobno) {
            GridFirma.WithSections = true;
            gridHeader.WithSections = true;
            gridElements.WithSections = true;
            gridFundusze.WithSections = true;
            GridOperator.WithSections = true;
        }
	}

    Wydzial prevWdz = null;
    
    private void repeater_BeforeRow(object sender, System.EventArgs e) {
        List<Wyplata> lw = (List<Wyplata>)repeater.CurrentRow;

        gridHeader.DataSource = GridOperator.DataSource = new object[] { lw[0] };
        List<FundPozyczkowy> fundusze = new List<FundPozyczkowy>();
        foreach (Wyplata w in lw)
            if (w is WyplataEtat)
                foreach (FundPozyczkowy f in w.Pracownik.FunduszePozyczkowe)
                    if (!fundusze.Contains(f))
                        fundusze.Add(f);
        gridFundusze.Visible = !(fundusze.Count == 0 || !srpars.FunduszePożyczkowe);
        gridFundusze.DataSource = fundusze;
        List<WypElement> elementy = new List<WypElement>();
        foreach (Wyplata w in lw)
            foreach (WypElement we in srpars.Kolejnosc ? w.ElementyWgKolejności : w.Elementy)
                elementy.Add(we);
        gridElements.DataSource = elementy;

        if (Pars.ForceBreak == PageFormat.Opcja) {
            Wydzial wdz = lw[0].ListaPlac.Wydzial;
            PageBreak.Required = wdz != prevWdz;
            prevWdz = wdz;
        }
        else
            PageBreak.Required = Pars.ForceBreak == PageFormat.Osobno;
        labelPlec.EditValue = lw[0].PracHistoria.Plec == PłećOsoby.Kobieta ? "świadoma" : "świadomy";        
    }

    private string Korygowany(WypElement element) {
        string korektaTxt = " (korekta)";
        string depozytTxt = " (depozyt)";
        string nazwa = element.Nazwa;
        if (element.Definicja.Korygowany && nazwa.EndsWith(korektaTxt))
            nazwa = nazwa.Replace(korektaTxt, "");
        else if (element is WypElementZajęcieKomornicze && nazwa.EndsWith(depozytTxt))
            nazwa = nazwa.Replace(depozytTxt, "");
        return nazwa;
    }
    
    static readonly string prefix = "&nbsp;&nbsp;&nbsp;&nbsp;";
    private void gridElements_BeforeRow(object sender, Soneta.Web.RowEventArgs args) {
        WypElement element = (WypElement)args.Row;

        if (!srpars.SkladnikiInfo) {
            if (element.Wartosc == 0)
                args.VisibleRow = false;
            else {
                colNazwa.AddLine(Korygowany(element));
                WypSkladnikGłówny skg = element.SkładnikGłówny;
                colProcent.AddLine(skg == null ? Percent.Zero : skg.Procent);
                colCzas.AddLine(element.Czas);
                colDni.AddLine(element.Dni);
                AddWartosc(element.Wartosc);
            }
        }
        else
            foreach (WypSkladnik sk in element.Skladniki) {
                WypSkladnikGłówny skg = sk as WypSkladnikGłówny;
                if (skg != null) {
                    colNazwa.AddLine(Korygowany(element));
                    colProcent.AddLine(skg.Procent);
                    colCzas.AddLine(skg.Czas);
                    colDni.AddLine(skg.Dni);
                    AddWartosc(skg.Wartosc);
                }
                else {
                    WypSkladnikPomniejszenie skp = sk as WypSkladnikPomniejszenie;
                    if (skp != null) {
                        colNazwa.AddLine(prefix + skp.Nieobecnosc.Definicja.Nazwa + " (" + skp.Okres + ")");
                        colProcent.AddLine(skp.Procent);
                        colCzas.AddLine(skp.Czas);
                        colDni.AddLine(skp.Dni);
                        colDodatek.AddLine(skp.Wartosc);
                        colPotracenie.AddLine(0m);
                    }
                    else {
                        colNazwa.AddLine(prefix + CaptionAttribute.EnumToString(sk.Rodzaj));
                        colProcent.AddLine(sk.Procent);
                        colCzas.AddLine(sk.Czas);
                        colDni.AddLine(sk.Dni);
                        colDodatek.AddLine(sk.Wartosc);
                        colPotracenie.AddLine(0m);
                    }
                }
            }
    }

    void AddWartosc(decimal v) {
        if (v >= 0) {
            colDodatek.AddLine(v);
            colPotracenie.AddLine(0m);
        }
        else {
            colDodatek.AddLine(0m);
            colPotracenie.AddLine(-v);
        }
    }
    
    private void gridHeader_BeforeRow(object sender, Soneta.Web.RowEventArgs args) {
        List<Wyplata> lw = (List<Wyplata>)repeater.CurrentRow;
        Wyplata wp = lw[0];

        string value = "";
        List<FromTo> okresy = new List<FromTo>();
        KalkulatorPracownika kalk = new KalkulatorPracownika(wp.Pracownik);
        foreach (Wyplata w in lw) {
            FromTo ft = w.ListaPlac.Okres;
            if (okresy.Contains(ft))
                continue;
            CzasDni norma = kalk.Norma(ft);
            if (value != "")
                value += ", ";
            value += "<b>" + ft + "</b>";
            if (srpars.InfoNorma)
                value += " (Norma: <b>" + norma.Czas + " / " + norma.Dni + "</b>)";
            okresy.Add(ft);
        }
        colOkresInfo.EditValue = value;

        WyplataEtat we = wp as WyplataEtat;
        Wyplata.ZUSInfoWorker zusinfo = new Wyplata.ZUSInfoWorker();
        zusinfo.Wypłata = wp;
        if (we != null)
            colPracInfo.EditValue = string.Format("PESEL: <strong>{0}</strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Wymiar etatu: <strong>{1}</strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Tytuł ubezpieczenia: <strong>{2}</strong>",
                wp.PracHistoria.PESEL,
                wp.PracHistoria.Etat.Zaszeregowanie.Wymiar,
                zusinfo.TytułUbezpieczenia);
        else {
            Umowa umowa = wp is WyplataUmowa ? ((WyplataUmowa)wp).Umowa : null;
            if (umowa != null)
                colPracInfo.EditValue = string.Format("PESEL: <strong>{0}</strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Tytuł ubezpieczenia: <strong>{1}</strong>",
                    wp.PracHistoria.PESEL,
                    zusinfo.TytułUbezpieczenia);
            else
                colPracInfo.EditValue = string.Format("PESEL: <strong>{0}</strong>",
                    wp.PracHistoria.PESEL);
        }

        decimal emPodstawa = 0, emPrac = 0, emFirma = 0;
        decimal fpPodstawa = 0, fpSkladka = 0;
        decimal rnPodstawa = 0, rnPrac = 0, rnFirma = 0;
        decimal fgspPodstawa = 0, fgspSkladka = 0;
        decimal chPodstawa = 0, chPrac = 0, chFirma = 0;
        decimal fepPodstawa = 0, fepSkladka = 0;
        decimal wpPodstawa = 0, wpPrac = 0, wpFirma = 0;
        decimal zdPodstawa = 0, zdPrac = 0, zdFirma = 0;
        string numer = "", oddzialNFZ = "";
        decimal kosztyZUS = 0, firmaZUS = 0;
        decimal pitProcent = 0, pitKoszty = 0, pitKoszty50 = 0, pitKoszty50N = 0, pitUlga = 0;
        decimal pitZdDoOdliczenia = 0, pitZdPracownika = 0, pitZalFIS = 0;
        Dictionary<string, decimal> gotówka = new Dictionary<string, decimal>();
        Dictionary<string, decimal> inne = new Dictionary<string, decimal>();
        decimal temp;
        foreach (Wyplata w in lw) {
            WyplataSkładkiWorker wsw = new WyplataSkładkiWorker();
            wsw.Wypłata = w;
            emPodstawa += wsw.Razem.Emerytalna.Podstawa;
            emPrac += wsw.Razem.Emerytalna.Prac;
            emFirma += wsw.Razem.Emerytalna.Firma;
            fpPodstawa += wsw.Razem.FP.Podstawa;
            fpSkladka += wsw.Razem.FP.Firma;
            rnPodstawa += wsw.Razem.Rentowa.Podstawa;
            rnPrac += wsw.Razem.Rentowa.Prac;
            rnFirma += wsw.Razem.Rentowa.Firma;
            fgspPodstawa += wsw.Razem.FGSP.Podstawa;
            fgspSkladka += wsw.Razem.FGSP.Firma;
            chPodstawa += wsw.Razem.Chorobowa.Podstawa;
            chPrac += wsw.Razem.Chorobowa.Prac;
            chFirma += wsw.Razem.Chorobowa.Firma;
            fepPodstawa += wsw.Razem.FEP.Podstawa;
            fepSkladka += wsw.Razem.FEP.Firma;
            wpPodstawa += wsw.Razem.Wypadkowa.Podstawa;
            wpPrac += wsw.Razem.Wypadkowa.Prac;
            wpFirma += wsw.Razem.Wypadkowa.Firma;
            numer += w.Numer + "<br/>";
            kosztyZUS += wsw.Razem.KosztyZUS;
            firmaZUS += wsw.Razem.FirmaZUS;
            if (!oddzialNFZ.Contains(w.PracHistoria.OddzialNFZ.Kod))
                oddzialNFZ += w.PracHistoria.OddzialNFZ.Kod + "<br/>";
            zdPodstawa += wsw.Razem.Zdrowotna.Podstawa;
            zdPrac += wsw.Razem.Zdrowotna.Prac;
            zdFirma += wsw.Razem.Zdrowotna.Firma;
            Wyplata.PITInfoWorker piw = new Wyplata.PITInfoWorker();
            piw.Wypłata = w;
            pitProcent = piw.ProcentPit;
            foreach (WypElement e in w.Elementy)
                switch (e.Definicja.Deklaracje.Koszty.Typ) {
                    case TypKosztowUzyskaniaPrzychodu.Procentowe:
                    case TypKosztowUzyskaniaPrzychodu.Procentowe50:
                    case TypKosztowUzyskaniaPrzychodu.ProcentoweWarunkowo:
                        if (e.Definicja.Deklaracje.Koszty.Procent == new Percent(0.5M)) {
                            if (e.Podatki.Koszty > 0)
                                pitKoszty50 += e.Podatki.Koszty;
                            else
                                pitKoszty50 += e.Podatki.Koszty50;
                        }
                        else {
                            pitKoszty += e.Podatki.Koszty;
                            pitKoszty50 += e.Podatki.Koszty50;
                        }
                        break;
                    default:
                        pitKoszty += e.Podatki.Koszty;
                        pitKoszty50 += e.Podatki.Koszty50;
                        break;
                }
            pitUlga += piw.Ulga;
            pitZdDoOdliczenia += piw.ZdrowotneDoOdliczenia;
            pitZdPracownika += piw.ZdrowotnePracownika;
            pitZalFIS += piw.ZalFIS;
            if (!gotówka.TryGetValue(w.Gotówka.Symbol, out temp))
                gotówka.Add(w.Gotówka.Symbol, w.Gotówka.Value);
            else
                gotówka[w.Gotówka.Symbol] += w.Gotówka.Value;
            if (!inne.TryGetValue(w.Inne.Symbol, out temp))
                inne.Add(w.Inne.Symbol, w.Inne.Value);
            else
                inne[w.Inne.Symbol] += w.Inne.Value;
        }
        colPracownik.EditValue = wp.Pracownik;        
        colEmPodstawa.EditValue = emPodstawa;
        colEmPrac.EditValue = emPrac;
        colEmFirma.EditValue = emFirma;
        optFPPodstawa.EditValue = fpPodstawa;
        optFPSkladka.EditValue = fpSkladka;
        colRnPodstawa.EditValue = rnPodstawa;
        colRnPrac.EditValue = rnPrac;
        colRnFirma.EditValue = rnFirma;
        optFGSPPodstawa.EditValue = fgspPodstawa;
        optFGSPSkladka.EditValue = fgspSkladka;
        colChPodstawa.EditValue = chPodstawa;
        colChPrac.EditValue = chPrac;
        colChFirma.EditValue = chFirma;
        optFEPPodstawa.EditValue = fepPodstawa;
        optFEPSkladka.EditValue = fepSkladka;
        colWpPodstawa.EditValue = wpPodstawa;
        colWpPrac.EditValue = wpPrac;
        colWpFirma.EditValue = wpFirma;
        colNumer.EditValue = numer;
        colKosztyZUS.EditValue = kosztyZUS;
        colFirmaZUS.EditValue = firmaZUS;
        colOddzialNFZ.EditValue = oddzialNFZ;
        if (srpars.ProcentPit)
            colPitProcent.EditValue = new Percent(pitProcent);
        colZdPodstawa.EditValue = zdPodstawa;
        colZdPrac.EditValue = zdPrac;
        colZdFirma.EditValue = zdFirma;
        colKosztyFormat.Format = "";
        colPitKoszty.EditValue = "";        
        if (pitKoszty != 0) {
            colKosztyFormat.Format = "Koszty uz.:";
            colPitKoszty.EditValue = pitKoszty;
        }
        if (pitKoszty50 != 0) {
            colKosztyFormat.Format += (pitKoszty != 0 ? "<br/>" : "") + "Koszty uz.50%:";
            colPitKoszty.EditValue += (pitKoszty != 0 ? "<br/>" : "") + pitKoszty50;
        }
        FromTo ow = new FromTo(wp.Data.FirstDayYear(), wp.Data);
        PlaceModule pm = PlaceModule.GetInstance(wp.Pracownik);
        SubTable st = new SubTable(pm.WypElementy.WgDaty[wp.Pracownik], ow);
        foreach (WypElement e in st) {
            try {
                switch (e.Definicja.Deklaracje.Koszty.Typ) {
                    case TypKosztowUzyskaniaPrzychodu.Procentowe:
                    case TypKosztowUzyskaniaPrzychodu.Procentowe50:
                    case TypKosztowUzyskaniaPrzychodu.ProcentoweWarunkowo:
                        if (e.Definicja.Deklaracje.Koszty.Procent == new Percent(0.5M)) {
                            if (e.Podatki.Koszty > 0)
                                pitKoszty50N += e.Podatki.Koszty;
                            else
                                pitKoszty50N += e.Podatki.Koszty50;
                        }
                        else
                            pitKoszty50N += e.Podatki.Koszty50;
                        break;
                    default:
                        pitKoszty50N += e.Podatki.Koszty50;
                        break;
                }
            }
            catch { }
        }
        if (pitKoszty50N != 0) {
            colKosztyFormat.Format += (pitKoszty != 0 || pitKoszty50 != 0 ? "<br/>" : "") + "Narast.k.uz.50%:";
            colPitKoszty.EditValue += (pitKoszty != 0 || pitKoszty50 != 0 ? "<br/>" : "") + pitKoszty50N;
        }
        colPitUlga.EditValue = pitUlga;
        colPitZdDoOdliczenia.EditValue = pitZdDoOdliczenia;
        colPitZdPracownika.EditValue = pitZdPracownika;
        colPitZalFIS.EditValue = pitZalFIS;
        string strGotowka = "";
        foreach (string key in gotówka.Keys)
            strGotowka += (strGotowka != "" ? "<br/>" : "") + gotówka[key] + " " + key;
        colGotowka.EditValue = strGotowka != "" ? strGotowka : "0";
        string strROR = "";
        foreach (string key in inne.Keys)
            strROR += (strROR != "" ? "<br/>" : "") + inne[key] + " " + key;
        colROR.EditValue = strROR != "" ? strROR : "0";
    }
    
    private void GridFundusze_BeforeRow(object sender, Soneta.Web.RowEventArgs args) {
        FundPozyczkowy fundusz = (FundPozyczkowy)args.Row;
        
        colDefinicja.EditValue = fundusz.Definicja.Nazwa;
        FundPożyczkowyWorker fpw = new FundPożyczkowyWorker();
        fpw.Fundusz = fundusz;
        colWkład.EditValue = fpw.Wkład;
        colDoSpłaty.EditValue = fpw.DoSpłaty;
    }

    private void GridOperator_BeforeRow(object sender, Soneta.Web.RowEventArgs args) {
        colToday.EditValue = Date.Today;
        colOperator.EditValue = dc.Session.Login.Operator.FullName;
    }

		</SCRIPT>

<META content="text/html; charset=unicode" http-equiv=Content-Type>
<META name=GENERATOR content="Microsoft Visual Studio 7.0">
<META name=CODE_LANGUAGE content=C#>
<META name=vs_defaultClientScript content=JavaScript>
<META name=vs_targetSchema 
content=http://schemas.microsoft.com/intellisense/ie5></HEAD>
<BODY><FONT face=Tahoma>
<FORM id=form method=post runat="server"><ea:datacontext id="dc" runat="server" oncontextload="dc_OnContextLoad" TypeName="Soneta.KadryPlace"
					LeftMargin="-1" RightMargin="-1"></ea:datacontext><ea:datarepeater id="repeater" runat="server" Height="294px" Width="875px" RowTypeName="Soneta.Place.WyplataEtat,Soneta.KadryPlace"
						onbeforerow="repeater_BeforeRow" WithSections="false">
			    
                <ea:PageBreak id="PageBreak" runat="server" Required="False" BreakFirstTimes="False"></ea:PageBreak>
                <ea:Section runat="server" SectionType="Header"><div style="height:1px;"></div></ea:Section>
                <ea:Section runat="server" ID="section1" SectionType="Body">
				    <%=divheighttag%>
                    
					<ea:Grid id="GridFirma" runat="server" RowTypeName="Soneta.Business.Session,Soneta.Business"
						WithSections="False" ShowHeader="None" RowsInRow="4">
						<Columns>
							<ea:GridColumn RightBorder="None" Format="Nazwa firmy: " ID="colFirmaTitle"></ea:GridColumn>
							<ea:GridColumn RightBorder="Single" ColSpan="5" ID="colNipTitle"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" Format="NUSP:" ID="colNuspTitle"></ea:GridColumn>
							<ea:GridColumn ID="c1" runat="server"></ea:GridColumn>
							<ea:GridColumn ColSpan="4" BottomBorder="None" DataMember="Core.Config.Firma.Pieczątka.Nazwa" Format="&lt;strong&gt;{0}&lt;/strong&gt;"
								ID="colNazwaFirmy"></ea:GridColumn>
							<ea:GridColumn ColSpan="4" Format="&lt;strong&gt;{0}&lt;/strong&gt;" ID="colNUSP"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" ID="lewy_i_prawy"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" ID="c3"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" ID="c4"></ea:GridColumn>
							<ea:GridColumn ID="c5"></ea:GridColumn>
							<ea:GridColumn ID="colStempel" RowSpan="4" VAlign="Bottom" BottomBorder="Single" ColSpan="4" Align="Center" Format="&lt;font size=1&gt;......................................&lt;br&gt;(pieczęć firmy)&lt;/font&gt;"></ea:GridColumn>
						</Columns>
					</ea:Grid>
					<ea:grid id="gridHeader" runat="server" onbeforerow="gridHeader_BeforeRow"
						WithSections="False" ShowHeader="None" RowsInRow="10">
						<Columns>
							<ea:GridColumn RightBorder="None" Format="Pracownik:" runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" Format="Za okres:" runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn ColSpan="5" BottomBorder="Single" ID="colPracInfo" runat="server" CssClass="c4"></ea:GridColumn>
							<ea:GridColumn runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Format="Podstawa:" runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Format="Ubezpieczony:" runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Format="Płatnik:" BottomBorder="Single" runat="server" CssClass="c4"></ea:GridColumn>
                            <ea:GridColumn ID="optEmptyBegin" runat="server" CssClass="c0"></ea:GridColumn>
                            <ea:GridColumn ID="optPodstawa" runat="server" Format="Podstawa:" CssClass="c0"></ea:GridColumn>
                            <ea:GridColumn ID="optSkladka" runat="server" Format="Składka:" CssClass="c3"></ea:GridColumn>
							<ea:GridColumn ColSpan="4" ID="colPracownik" Format="&lt;strong&gt;{0}&lt;/strong&gt;" runat="server" CssClass="c1"></ea:GridColumn>
							<ea:GridColumn ColSpan="4" ID="colOkresInfo" runat="server" CssClass="c1"></ea:GridColumn>
							<ea:GridColumn Align="Center" Format="Emerytalne" runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Align="Right" ID="colEmPodstawa" Format="{0:n}" runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Align="Right" ID="colEmPrac" Format="{0:n}" runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Align="Right" ID="colEmFirma" Format="{0:n}" BottomBorder="Single" runat="server" CssClass="c4"></ea:GridColumn>
                            <ea:GridColumn ID="optFP" runat="server" Align="Center" Format="FP" CssClass="c0"></ea:GridColumn>
                            <ea:GridColumn ID="optFPPodstawa" runat="server" Align="Right" Format="{0:n}" CssClass="c0"></ea:GridColumn>
                            <ea:GridColumn ID="optFPSkladka" runat="server" Align="Right" Format="{0:n}" CssClass="c3"></ea:GridColumn>
							<ea:GridColumn Align="Center" Format="Rentowe" runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Align="Right" ID="colRnPodstawa" Format="{0:n}" runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Align="Right" ID="colRnPrac" Format="{0:n}" runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Align="Right" ID="colRnFirma" Format="{0:n}" BottomBorder="Single" runat="server" CssClass="c4"></ea:GridColumn>
                            <ea:GridColumn ID="optFGSP" runat="server" Align="Center" Format="FGŚP" BottomBorder="None" CssClass="c0"></ea:GridColumn>
                            <ea:GridColumn ID="optFGSPPodstawa" runat="server" Align="Right" Format="{0:n}" CssClass="c0"></ea:GridColumn>
                            <ea:GridColumn ID="optFGSPSkladka" runat="server" Align="Right" Format="{0:n}" CssClass="c3"></ea:GridColumn>
							<ea:GridColumn Align="Center" Format="Chorobowe" runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Align="Right" ID="colChPodstawa" Format="{0:n}" runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Align="Right" ID="colChPrac" Format="{0:n}" runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Align="Right" ID="colChFirma" Format="{0:n}" BottomBorder="Single" runat="server" CssClass="c4"></ea:GridColumn>
                            <ea:GridColumn ID="optFEP" runat="server" Align="Center" Format="FEP" CssClass="c0"></ea:GridColumn>
                            <ea:GridColumn ID="optFEPPodstawa" runat="server" Align="Right" Format="{0:n}" CssClass="c0"></ea:GridColumn>
                            <ea:GridColumn ID="optFEPSkladka" runat="server" Align="Right" Format="{0:n}" CssClass="c3"></ea:GridColumn>
							<ea:GridColumn Align="Center" Format="Wypadkowe" runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Align="Right" ID="colWpPodstawa" Format="{0:n}" runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Align="Right" ID="colWpPrac" Format="{0:n}" runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Align="Right" ID="colWpFirma" Format="{0:n}" runat="server" BottomBorder="Single" CssClass="c4"></ea:GridColumn>
                            <ea:GridColumn ID="optEmptyEnd" runat="server" ColSpan="5" RowSpan="3" CssClass="c3"></ea:GridColumn>
							<ea:GridColumn ColSpan="2" ID="colNumer" Format="&lt;strong&gt;{0}&lt;/strong&gt;" runat="server"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" Format="Oddział NFZ:" runat="server"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" BottomBorder="Single" Format="Procent zal. PIT:" ID="colPitInfo" runat="server" CssClass="c5"></ea:GridColumn>
							<ea:GridColumn Align="Center" Format="Razem" runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Align="Right" ID="colKosztyZUS" Format="{0:n}" runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Align="Right" ID="colFirmaZUS" Format="{0:n}" runat="server" BottomBorder="Single" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn ID="colOddzialNFZ" runat="server" CssClass="c1"></ea:GridColumn>
							<ea:GridColumn BottomBorder="Single" ID="colPitProcent" runat="server" CssClass="c2"></ea:GridColumn>
							<ea:GridColumn Align="Center" Format="Zdrowotne" runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Align="Right" ID="colZdPodstawa" Format="{0:n}" runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Align="Right" ID="colZdPrac" Format="{0:n}" runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Align="Right" ID="colZdFirma" Format="{0:n}" runat="server" BottomBorder="Single" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" ID="colKosztyFormat" NoWrap="True" runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" Format="Ulga podatkowa:" NoWrap="True" runat="server"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" Format="Zdrow.do odlicz.:" NoWrap="True" runat="server"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" Format="Zdrow. prac.:" NoWrap="True" runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" Format="Zal. podatku:" NoWrap="True" runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" Format="Got&#243;wka:" NoWrap="True" runat="server" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" Format="ROR:" NoWrap="True" runat="server" BottomBorder="Single" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Align="Right" ID="colPitKoszty" Format="{0:n}" runat="server" CssClass="c1"></ea:GridColumn>
							<ea:GridColumn Align="Right" ID="colPitUlga" Format="{0:n}" runat="server" CssClass="c1"></ea:GridColumn>
							<ea:GridColumn Align="Right" ID="colPitZdDoOdliczenia" Format="{0:n}" runat="server" CssClass="c1"></ea:GridColumn>
							<ea:GridColumn Align="Right" ID="colPitZdPracownika" Format="{0:n}" runat="server" CssClass="c1"></ea:GridColumn>
							<ea:GridColumn Align="Right" ID="colPitZalFIS" Format="{0:n}" runat="server" CssClass="c1"></ea:GridColumn>
							<ea:GridColumn Align="Right" Format="&lt;strong&gt;{0}&lt;/strong&gt;" ID="colGotowka" runat="server" CssClass="c1"></ea:GridColumn>
							<ea:GridColumn Align="Right" Format="&lt;strong&gt;{0}&lt;/strong&gt;" ID="colROR" runat="server" BottomBorder="Single" CssClass="c1"></ea:GridColumn>
						</Columns>
					</ea:grid>
					<ea:Grid id="gridElements" runat="server" WithSections="False" onbeforerow="gridElements_BeforeRow"
                        DataMember="ElementyWgKolejności">
						<Columns>
							<ea:GridColumn Width="4" BottomBorder="None" Align="Right" DataMember="#" Caption="L.p." VAlign="Top" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn BottomBorder="None" Total="Info" ID="colNazwa" NoWrap="True" VAlign="Top" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Width="10" BottomBorder="None" Align="Right" Caption="Procent" HideZero="True" ID="colProcent"
								VAlign="Top" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Width="10" BottomBorder="None" Align="Right" Caption="godz:min" HideZero="True"
								ID="colCzas" VAlign="Top" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Width="10" BottomBorder="None" Align="Right" Caption="Dni" HideZero="True" ID="colDni"
								VAlign="Top" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Width="15" BottomBorder="None" Align="Right" Total="Sum" Caption="Dodatek" HideZero="True"
								Format="{0:n}" ID="colDodatek" VAlign="Top" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Width="15" BottomBorder="None" Align="Right" Total="Sum" Caption="Potrącenie" HideZero="True"
								Format="{0:n}" ID="colPotracenie" VAlign="Top" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn Width="25" BottomBorder="None" Caption="Data i podpis" CssClass="c3"></ea:GridColumn>
						</Columns>
					</ea:Grid>
					<ea:Grid id="gridFundusze" runat="server" onbeforerow="GridFundusze_BeforeRow" WithSections="False">
						<Columns>
							<ea:GridColumn Width="4" Align="Right" DataMember="#" Caption="L.p."></ea:GridColumn>
							<ea:GridColumn Width="30" ID="colDefinicja" Caption="Fundusz" NoWrap="True"></ea:GridColumn>
							<ea:GridColumn Width="15" Align="Right" ID="colWkład" Caption="Wkład"
								HideZero="True" Format="{0:n}"></ea:GridColumn>
							<ea:GridColumn Width="15" Align="Right" ID="colDoSpłaty" Caption="Do spłaty"
								HideZero="True" Format="{0:n}"></ea:GridColumn>
						</Columns>
					</ea:Grid>
					<ea:Grid id="GridOperator" runat="server" onbeforerow="GridOperator_BeforeRow" WithSections="False"
						ShowHeader="None">
						<Columns>
							<ea:GridColumn Align="Center" Format="Data sporządzenia: {0}" ID="colToday" CssClass="c4"></ea:GridColumn>
							<ea:GridColumn Align="Center" Format="Sporządził: {0}" ID="colOperator" CssClass="c4"></ea:GridColumn>
							<ea:GridColumn Align="Center" Format="&lt;br&gt;.................................&lt;br&gt;&lt;font size=1&gt;podpis&lt;/font&gt;" CssClass="c2"></ea:GridColumn>
						</Columns>
					</ea:Grid>
                   
                    <ea:Section ID="section2" runat="server">
                        <font size="1">
                        <br /><strong>Oświadczenie płatnika składek</strong><br /><br />
                        Oświadczam, że dane zawarte w formularzu są zgodne ze stanem prawnym i faktycznym.
                        Jestem
				        <ea:DataLabel id="labelPlec" runat="server" Bold="False"></ea:DataLabel>
                        odpowiedzialności karnej za zeznanie nieprawdy lub zatajenie prawdy.<br />
                        </font>
                    </ea:Section>                                
					<n0:ReportFooter id="ReportFooter1" runat="server" TheEnd="False"></n0:ReportFooter>
                    <ea:PageBreak ID="PageBreak1" runat="server" Required="false"></ea:PageBreak>
				    <%=divendtag%>
                    </ea:Section>                    
				</ea:datarepeater> 
</FORM></FONT></BODY></HTML>
